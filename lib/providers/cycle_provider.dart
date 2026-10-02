import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cycle_data.dart';
import '../models/daily_log.dart';

class CycleProvider extends ChangeNotifier {
  CycleData _cycleData = CycleData(
    lastPeriodStart: DateTime.now().subtract(const Duration(days: 14)),
  );

  bool _isLoaded = false;
  bool _remindersEnabled = true;

  // --- Auth / profile state ---
  bool _isLoggedIn = false;
  String _userName = '';
  String? _userId;
  String? _authToken;
  DateTime? _tokenExpiresAt;

  // Accounts now live on the backend server (see /signup, /signin,
  // /reset_password) so they survive app reinstalls and work across
  // devices. Only the "remember me" flag + name are cached locally
  // below, purely so the splash screen can skip sign-in on relaunch.
  static const String _authBaseUrl =
      'https://areeshasadaf56.pythonanywhere.com';

  Map<String, DailyLog> _dailyLogs = {};

  DateTime? _selectedPeriodDate;

  CycleData get cycleData => _cycleData;
  bool get isLoaded => _isLoaded;
  Map<String, DailyLog> get dailyLogs => _dailyLogs;
  DateTime? get selectedPeriodDate => _selectedPeriodDate;

  int get currentCycleDay => _cycleData.getCurrentCycleDay();
  String get currentPhase => _cycleData.getPhase();
  int get daysUntilNextPeriod => _cycleData.daysUntilNextPeriod();
  int get cycleLength => _cycleData.cycleLength;
  int get periodDuration => _cycleData.periodDuration;

  bool get remindersEnabled => _remindersEnabled;

  bool get isLoggedIn => _isLoggedIn;
  String get userName => _userName;
  String? get userId => _userId;
  String? get authToken => _authToken;

  /// True once we have a token that isn't (as far as we know) expired
  /// yet. Callers that hit authenticated endpoints should check this
  /// before bothering to attach the Authorization header.
  bool get hasValidSession =>
      _authToken != null &&
      (_tokenExpiresAt == null || _tokenExpiresAt!.isAfter(DateTime.now()));

  CycleProvider() {
    _loadData();
  }

  String _keyFor(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  DailyLog getLogFor(DateTime date) {
    return _dailyLogs[_keyFor(date)] ?? DailyLog();
  }

  bool isSelectedDay(DateTime date) {
    if (_selectedPeriodDate == null) return false;
    return _isSameDay(_selectedPeriodDate!, date);
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();

    final lastPeriodMillis = prefs.getInt('lastPeriodStart');
    final cycleLength = prefs.getInt('cycleLength');
    final periodDuration = prefs.getInt('periodDuration');

    if (lastPeriodMillis != null) {
      _cycleData = CycleData(
        lastPeriodStart: DateTime.fromMillisecondsSinceEpoch(lastPeriodMillis),
        cycleLength: cycleLength ?? 28,
        periodDuration: periodDuration ?? 5,
      );
      _selectedPeriodDate = _cycleData.lastPeriodStart;
    }

    final logsJson = prefs.getString('dailyLogs');
    if (logsJson != null) {
      try {
        final Map<String, dynamic> decoded = jsonDecode(logsJson);
        _dailyLogs = decoded.map(
          (key, value) => MapEntry(key, DailyLog.fromJson(value)),
        );
      } catch (_) {
        _dailyLogs = {};
      }
    }

    _remindersEnabled = prefs.getBool('remindersEnabled') ?? true;

    // Restore auth/profile state so a returning user skips sign-in.
    _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    _userName = prefs.getString('userName') ?? '';
    _userId = prefs.getString('authUserId');
    _authToken = prefs.getString('authToken');
    final expiresMillis = prefs.getInt('authTokenExpiresAt');
    _tokenExpiresAt = expiresMillis != null
        ? DateTime.fromMillisecondsSinceEpoch(expiresMillis)
        : null;

    // A token that has already expired is useless -- clear it so the
    // rest of the app correctly treats this as "no session" rather than
    // attaching a dead Authorization header to every request.
    if (_authToken != null && !hasValidSession) {
      _authToken = null;
      _userId = null;
      _tokenExpiresAt = null;
    }

    _isLoaded = true;
    notifyListeners();
  }

  void toggleReminders(bool value) async {
    _remindersEnabled = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('remindersEnabled', value);
  }

  /// Call on successful sign in / sign up. Persists the logged-in flag,
  /// the name, and -- when the server returned one -- the account's
  /// opaque user id + session token, so authenticated endpoints
  /// (profile sync, AI chat) can attach a valid Authorization header.
  Future<void> login(
    String name, {
    String? userId,
    String? token,
    DateTime? tokenExpiresAt,
  }) async {
    _isLoggedIn = true;
    _userName = name;
    if (userId != null) _userId = userId;
    if (token != null) _authToken = token;
    if (tokenExpiresAt != null) _tokenExpiresAt = tokenExpiresAt;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('userName', name);
    if (userId != null) await prefs.setString('authUserId', userId);
    if (token != null) await prefs.setString('authToken', token);
    if (tokenExpiresAt != null) {
      await prefs.setInt(
        'authTokenExpiresAt',
        tokenExpiresAt.millisecondsSinceEpoch,
      );
    }
  }

  String _normalizeEmail(String email) => email.trim().toLowerCase();

  /// Creates a new account on the server. Returns null on success, or
  /// an error message string on failure (e.g. email already taken, or
  /// no internet connection).
  Future<String?> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_authBaseUrl/signup'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'name': name,
              'email': _normalizeEmail(email),
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 30));

      final body = jsonDecode(response.body);

      if (response.statusCode != 200) {
        return body['detail'] ?? 'Something went wrong. Please try again.';
      }

      await login(
        body['name'] ?? name,
        userId: body['user_id']?.toString(),
        token: body['token'] as String?,
        tokenExpiresAt: body['expires_at'] != null
            ? DateTime.tryParse(body['expires_at'] as String)
            : null,
      );
      return null;
    } catch (e) {
      debugPrint('signUp error: $e');
      return 'Could not reach the server. Please check your internet connection and try again.';
    }
  }

  /// Validates credentials against the server. Returns null on success,
  /// or an error message string on failure.
  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_authBaseUrl/signin'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': _normalizeEmail(email),
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 30));

      final body = jsonDecode(response.body);

      if (response.statusCode != 200) {
        return body['detail'] ?? 'Something went wrong. Please try again.';
      }

      await login(
        body['name'] ?? '',
        userId: body['user_id']?.toString(),
        token: body['token'] as String?,
        tokenExpiresAt: body['expires_at'] != null
            ? DateTime.tryParse(body['expires_at'] as String)
            : null,
      );
      return null;
    } catch (e) {
      debugPrint('signIn error: $e');
      return 'Could not reach the server. Please check your internet connection and try again.';
    }
  }

  /// Resets the password for an existing account on the server. Returns
  /// null on success, or an error message string on failure.
  Future<String?> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_authBaseUrl/reset_password'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': _normalizeEmail(email),
              'new_password': newPassword,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        final body = jsonDecode(response.body);
        return body['detail'] ?? 'Something went wrong. Please try again.';
      }

      return null;
    } catch (_) {
      return 'Could not reach the server. Please check your internet connection and try again.';
    }
  }

  /// Call from the Settings logout button. Clears the flag so Splash
  /// routes back to Sign In next launch, but keeps cycle/log data intact.
  /// Also best-effort invalidates the session token server-side and
  /// clears it locally so no stale Authorization header lingers around.
  Future<void> logout() async {
    final tokenToInvalidate = _authToken;

    _isLoggedIn = false;
    _userId = null;
    _authToken = null;
    _tokenExpiresAt = null;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    await prefs.remove('authUserId');
    await prefs.remove('authToken');
    await prefs.remove('authTokenExpiresAt');

    if (tokenToInvalidate != null) {
      try {
        await http
            .post(
              Uri.parse('$_authBaseUrl/logout'),
              headers: {'Authorization': 'Bearer $tokenToInvalidate'},
            )
            .timeout(const Duration(seconds: 8));
      } catch (_) {
        // Best-effort only -- the local session is already cleared
        // above regardless of whether this network call succeeds.
      }
    }
  }

  void updateUserName(String name) async {
    _userName = name;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', name);
  }

  Future<void> _saveCycleData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      'lastPeriodStart',
      _cycleData.lastPeriodStart.millisecondsSinceEpoch,
    );
    await prefs.setInt('cycleLength', _cycleData.cycleLength);
    await prefs.setInt('periodDuration', _cycleData.periodDuration);
  }

  Future<void> _saveDailyLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, dynamic> encoded = _dailyLogs.map(
      (key, value) => MapEntry(key, value.toJson()),
    );
    await prefs.setString('dailyLogs', jsonEncode(encoded));
  }

  void updateLastPeriodStart(DateTime date) {
    _cycleData.lastPeriodStart = date;
    _saveCycleData();
    notifyListeners();
  }

  void updateCycleLength(int length) {
    _cycleData.cycleLength = length;
    _saveCycleData();
    notifyListeners();
  }

  void updatePeriodDuration(int duration) {
    _cycleData.periodDuration = duration;
    _saveCycleData();
    notifyListeners();
  }

  void logPeriodStartToday() {
    selectPeriodDate(DateTime.now());
  }

  void selectPeriodDate(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);

    if (_selectedPeriodDate != null) {
      final oldKey = _keyFor(_selectedPeriodDate!);
      if (_dailyLogs.containsKey(oldKey)) {
        _dailyLogs[oldKey]!.isPeriodDay = false;
      }
    }

    if (_selectedPeriodDate != null &&
        _isSameDay(_selectedPeriodDate!, normalized)) {
      _selectedPeriodDate = null;
    } else {
      _selectedPeriodDate = normalized;
      final newKey = _keyFor(normalized);
      final existing = _dailyLogs[newKey] ?? DailyLog();
      existing.isPeriodDay = true;
      _dailyLogs[newKey] = existing;

      _cycleData.lastPeriodStart = normalized;
      _saveCycleData();
    }

    _saveDailyLogs();
    notifyListeners();
  }

  void logMood(DateTime date, String mood) {
    final key = _keyFor(date);
    final existing = _dailyLogs[key] ?? DailyLog();
    existing.mood = mood;
    _dailyLogs[key] = existing;
    _saveDailyLogs();
    notifyListeners();
  }

  void logSymptoms(DateTime date, List<String> symptoms) {
    final key = _keyFor(date);
    final existing = _dailyLogs[key] ?? DailyLog();
    existing.symptoms = symptoms;
    _dailyLogs[key] = existing;
    _saveDailyLogs();
    notifyListeners();
  }

  void logFlowIntensity(DateTime date, String intensity) {
    final key = _keyFor(date);
    final existing = _dailyLogs[key] ?? DailyLog();
    existing.flowIntensity = intensity;
    _dailyLogs[key] = existing;
    _saveDailyLogs();
    notifyListeners();
  }
}
