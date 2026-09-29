/// health_profile_service.dart
///
/// Loads, caches, and saves the user's HealthProfile. This is the ONE
/// place every screen should go through to read or update profile data
/// -- don't call the backend directly from individual screens, so we
/// have a single place to add offline support, retry logic, etc. later.
///
/// Requires two packages in pubspec.yaml:
///   shared_preferences: ^2.2.0
///   http: ^1.1.0
/// (You likely already have `http` from pcos_api_service.dart /
/// eligibility_api_service.dart.)
library;

import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/health_profile.dart';

class HealthProfileService {
  static const _deviceIdKey = 'health_profile_device_id';
  static const _localProfileKeyPrefix = 'health_profile_cache_';

  // Written by CycleProvider on sign-in/out -- read directly here so
  // every screen that already constructs `HealthProfileService()` picks
  // up authenticated sync automatically, with no call-site changes.
  static const _authUserIdKey = 'authUserId';
  static const _authTokenKey = 'authToken';
  static const _authTokenExpiresAtKey = 'authTokenExpiresAt';

  String? _cachedUserId;
  HealthProfile? _cachedProfile;

  /// Returns the anonymous device id, generating and persisting one on
  /// first ever call. Used as a fallback identity for local-only usage
  /// before the user signs in; once signed in, [_effectiveUserId] uses
  /// the real account id instead so profile data actually reaches the
  /// backend under an identity the server will authorize.
  Future<String> getDeviceId() async {
    if (_cachedUserId != null) return _cachedUserId!;

    final prefs = await SharedPreferences.getInstance();
    var id = prefs.getString(_deviceIdKey);
    if (id == null) {
      id = _generateId();
      await prefs.setString(_deviceIdKey, id);
    }
    _cachedUserId = id;
    return id;
  }

  /// The id to use for talking to the backend: the signed-in account's
  /// real user id when available (required -- the backend now rejects
  /// `/profile/<id>` calls whose id doesn't match the authenticated
  /// token), falling back to the anonymous per-device id otherwise.
  Future<String> _effectiveUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final accountId = prefs.getString(_authUserIdKey);
    if (accountId != null && accountId.isNotEmpty) return accountId;
    return getDeviceId();
  }

  /// `Authorization: Bearer <token>` header when a still-valid session
  /// exists, or an empty map when signed out / expired -- in which case
  /// backend calls will simply 401 and the existing try/catch fallbacks
  /// keep the UI on local-only data, same as being offline.
  Future<Map<String, String>> _authHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_authTokenKey);
    if (token == null || token.isEmpty) return {};

    final expiresMillis = prefs.getInt(_authTokenExpiresAtKey);
    if (expiresMillis != null &&
        DateTime.fromMillisecondsSinceEpoch(
          expiresMillis,
        ).isBefore(DateTime.now())) {
      return {};
    }
    return {'Authorization': 'Bearer $token'};
  }

  String _generateId() {
    final rand = Random.secure();
    final bytes = List<int>.generate(16, (_) => rand.nextInt(256));
    // Simple UUID-v4-shaped string, good enough as an opaque identifier
    // (doesn't need to be a *real* RFC4122 UUID for our purposes).
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-4${hex.substring(13, 16)}-'
        '${hex.substring(16, 20)}-${hex.substring(20, 32)}';
  }

  /// Loads the profile: LOCAL CACHE FIRST, backend as a background sync.
  ///
  /// This used to check the backend first and fall back to local cache
  /// only on failure. That was backwards in practice: if the backend
  /// ever had an older/emptier profile than what's on-device (e.g. a
  /// previous saveProfile()'s background PUT silently failed due to a
  /// network hiccup, CORS, or the endpoint not being fully live yet),
  /// the *next* loadProfile() would happily fetch that stale backend
  /// copy and overwrite fresh local writes -- so a PCOS result or
  /// contraception choice saved seconds ago could vanish from the
  /// Diary the moment you reopened it, even though it was safely
  /// sitting in local storage the whole time.
  ///
  /// Now: local cache is returned immediately (it's authoritative for
  /// "what did this device just do"), and a backend fetch happens in
  /// the background purely to pick up data saved from a *different*
  /// device -- and even then, it's only adopted if it's actually newer
  /// than what's already local (compared via lastUpdated), so a stale
  /// backend record can never clobber a fresher local one.
  Future<HealthProfile> loadProfile() async {
    final userId = await _effectiveUserId();

    final local = await _loadFromCache(userId);

    // Fire-and-forget: sync from backend if it turns out to be newer.
    // Intentionally not awaited -- the UI should never block on this,
    // and _refreshFromBackendIfNewer() safely no-ops on any failure.
    unawaited(_refreshFromBackendIfNewer(userId, local));

    if (local != null) {
      _cachedProfile = local;
      return local;
    }

    // No local cache at all (first-ever launch on this device) -- in
    // this one case it's worth waiting on the network, since there's
    // nothing better to show yet.
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/profile/$userId');
      final headers = await _authHeaders();
      final response = await http
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final profile = HealthProfile.fromJson(json);
        await _cacheLocally(userId, profile);
        _cachedProfile = profile;
        return profile;
      }
    } catch (_) {
      // Network unavailable / server down / not authenticated yet --
      // fall through to a blank profile below.
    }

    final blank = HealthProfile.empty(userId);
    _cachedProfile = blank;
    return blank;
  }

  /// Background helper for loadProfile(): fetches the backend copy and
  /// only adopts it (overwriting local cache + in-memory cache) if it
  /// is strictly newer than what's already local. This is what makes
  /// cross-device sync safe without risking data loss on this device.
  Future<void> _refreshFromBackendIfNewer(
    String userId,
    HealthProfile? local,
  ) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/profile/$userId');
      final headers = await _authHeaders();
      final response = await http
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) return;

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final remote = HealthProfile.fromJson(json);

      if (local == null || remote.lastUpdated.isAfter(local.lastUpdated)) {
        await _cacheLocally(userId, remote);
        _cachedProfile = remote;
      }
    } catch (_) {
      // Best-effort background sync -- any failure here is silent and
      // harmless, since the local copy is already what's showing.
    }
  }

  /// Saves the profile: writes to local cache immediately (so the UI
  /// never waits on the network), then pushes to the backend in the
  /// background. If the backend call fails, the local cache still has
  /// the update -- the next successful loadProfile()/saveProfile() call
  /// will resync.
  Future<void> saveProfile(HealthProfile profile) async {
    _cachedProfile = profile;
    await _cacheLocally(profile.userId, profile);

    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/profile/${profile.userId}');
      final headers = {
        'Content-Type': 'application/json',
        ...await _authHeaders(),
      };
      await http
          .put(uri, headers: headers, body: jsonEncode(profile.toJson()))
          .timeout(const Duration(seconds: 8));
    } catch (_) {
      // Background sync failed silently -- local cache is still correct,
      // and will be retried on the next saveProfile()/loadProfile() call.
      // (If you want the user to see a "not synced" indicator, surface
      // this instead of swallowing it.)
    }
  }

  /// Convenience: apply a partial update without needing the caller to
  /// hand back a full HealthProfile. Example:
  ///   await service.updateProfile((p) => p.copyWith(
  ///     lifestyle: p.lifestyle.copyWith(regularExercise: true),
  ///   ));
  Future<HealthProfile> updateProfile(
    HealthProfile Function(HealthProfile current) updater,
  ) async {
    final current = _cachedProfile ?? await loadProfile();
    final updated = updater(current);
    await saveProfile(updated);
    return updated;
  }

  /// Appends one turn to the AI conversation log and saves. Kept as a
  /// dedicated method since this will be called frequently once the AI
  /// chat screen exists, and callers shouldn't need to hand-roll the
  /// list-append logic every time.
  Future<HealthProfile> appendConversationEntry(
    String role,
    String message, {
    String? sessionId,
  }) {
    return updateProfile((p) {
      final updatedLog = List<ConversationEntry>.from(p.conversationLog)
        ..add(
          ConversationEntry(
            timestamp: DateTime.now(),
            role: role,
            message: message,
            sessionId: sessionId,
          ),
        );
      return p.copyWith(conversationLog: updatedLog);
    });
  }

  /// Appends a new PCOS result to history (call this right after a
  /// successful /predict call in pcos_screen.dart) instead of only
  /// keeping the latest result in local widget state.
  Future<HealthProfile> appendPcosResult({
    required String prediction,
    required double pcosProbability,
    required String modelUsed,
  }) {
    return updateProfile((p) {
      final updatedHistory = List<PcosCheckResult>.from(p.pcosHistory)
        ..add(
          PcosCheckResult(
            date: DateTime.now(),
            prediction: prediction,
            pcosProbability: pcosProbability,
            modelUsed: modelUsed,
          ),
        );
      return p.copyWith(pcosHistory: updatedHistory);
    });
  }

  /// Appends a new eligibility-check result -- the conditions the user
  /// selected in Protection > My Plan > Eligibility tool, plus the
  /// per-method category results the check returned -- to the diary.
  /// Without this, running the eligibility tool never left a trace
  /// anywhere once the user navigated away from that screen.
  Future<HealthProfile> appendEligibilityCheck({
    required List<String> conditions,
    required List<EligibilityResultEntry> results,
  }) {
    return updateProfile((p) {
      final updatedHistory =
          List<EligibilityCheckResult>.from(p.eligibilityHistory)..add(
            EligibilityCheckResult(
              date: DateTime.now(),
              conditions: conditions,
              results: results,
            ),
          );
      return p.copyWith(eligibilityHistory: updatedHistory);
    });
  }

  Future<void> _cacheLocally(String userId, HealthProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '$_localProfileKeyPrefix$userId',
      jsonEncode(profile.toJson()),
    );
  }

  Future<HealthProfile?> _loadFromCache(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_localProfileKeyPrefix$userId');
    if (raw == null) return null;
    try {
      return HealthProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }
}
