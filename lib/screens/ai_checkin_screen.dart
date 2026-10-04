import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:file_picker/file_picker.dart';
import '../theme/app_theme.dart';
import '../models/health_profile.dart';
import '../providers/cycle_provider.dart';
import '../services/health_profile_service.dart';
import '../services/ai_service.dart';

class _ChatSession {
  final String sessionId;
  final List<ConversationEntry> entries;
  _ChatSession(this.sessionId, this.entries);

  DateTime get lastActivity => entries.last.timestamp;

  String get title {
    final firstUser = entries.firstWhere(
      (e) => e.role == 'user',
      orElse: () => entries.first,
    );
    final text = firstUser.message.trim();
    if (text.isEmpty) return 'New chat';
    return text.length > 40 ? '${text.substring(0, 40)}…' : text;
  }
}

class AiCheckinScreen extends StatefulWidget {
  final void Function(String tabName)? onNavigateToTab;

  const AiCheckinScreen({super.key, this.onNavigateToTab});

  @override
  State<AiCheckinScreen> createState() => _AiCheckinScreenState();
}

class _AiCheckinScreenState extends State<AiCheckinScreen> {
  final HealthProfileService _profileService = HealthProfileService();
  final AiService _aiService = AiService();
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  HealthProfile? _profile;
  final List<ConversationEntry> _messages = [];
  String _currentSessionId = '';
  bool _loading = true;
  bool _sending = false;
  bool _showCrisisBanner = false;
  bool _showMedicalEmergencyBanner = false;
  String? _pendingSuggestedTab;
  String? _pendingSuggestedReason;
  String? _errorText;

  // --- Language toggle (English / Urdu) ---
  // Persisted so the choice survives app restarts. The backend must
  // read `language` from the /chat request and reply accordingly --
  // see AiService.sendMessage.
  String _language = 'en';
  static const _languageKey = 'ai_checkin_language';

  // --- Voice input (speech-to-text) ---
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _speechAvailable = false;
  bool _listening = false;

  // --- File/image attachment ---
  PlatformFile? _pendingAttachment;
  bool _pickingFile = false;

  // --- Enter-to-send on desktop/web ---
  final FocusNode _inputFocusNode = FocusNode();

  static const _openingGreeting =
      "Hi there 🌸 I'm Saheli -- I'm here to check in on how you've "
      "really been. Take your time, there's no rush 💜\n\nHow have you "
      "been feeling lately, overall?";

  // Tap-to-reply mood chips shown under the opening greeting.
  static const List<List<String>> _moodChips = [
    ['😊', 'Good', "I'm feeling good lately"],
    ['😌', 'Okay', "I'm doing okay, nothing special"],
    ['😔', 'Low', "I've been feeling low lately"],
    ['😰', 'Anxious', "I've been feeling anxious and stressed"],
    ['😴', 'Tired', "I've been feeling really tired"],
    ['🤒', 'Unwell', "I haven't been feeling well physically"],
  ];

  void _sendQuickReply(String text) {
    if (_sending) return;
    _inputController.text = text;
    _sendMessage();
  }

  String _formatTime(DateTime t) {
    final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m ${t.hour >= 12 ? 'PM' : 'AM'}';
  }

  // --- Pet buddy 🐾 ---------------------------------------------------
  static const List<String> _pets = ['🐱', '🐰', '🐶', '🐼', '🦊', '🐻'];
  static const String _petKey = 'ai_checkin_pet';
  static const List<String> _petPhrases = [
    'purr~ 💕',
    'hehe that tickles! 🥰',
    "you're doing great 🌷",
    "I'm proud of you ✨",
    'sending you a hug 🤗',
    'psst… hold me to change my look 🎀',
    "I'm always here for you 💜",
  ];

  String _petEmoji = '🐱';
  _PetMood _petMood = _PetMood.idle;
  int _petBurst = 0;
  String? _petSpeech;
  Timer? _happyTimer;
  Timer? _speechTimer;
  Timer? _sleepTimer;

  Future<void> _loadPetPreference() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_petKey);
    if (saved != null && _pets.contains(saved) && mounted) {
      setState(() => _petEmoji = saved);
    }
  }

  /// Wakes the pet up and restarts the "fall asleep after a while" timer.
  void _bumpActivity() {
    _sleepTimer?.cancel();
    if (_petMood == _PetMood.sleepy && mounted) {
      setState(() => _petMood = _PetMood.idle);
    }
    _sleepTimer = Timer(const Duration(seconds: 45), () {
      if (mounted && !_sending) setState(() => _petMood = _PetMood.sleepy);
    });
  }

  void _say(String text, {int ms = 2800}) {
    if (!mounted) return;
    setState(() => _petSpeech = text);
    _speechTimer?.cancel();
    _speechTimer = Timer(Duration(milliseconds: ms), () {
      if (mounted) setState(() => _petSpeech = null);
    });
  }

  void _celebrate() {
    if (!mounted) return;
    setState(() {
      _petMood = _PetMood.happy;
      _petBurst++;
    });
    _say('yay~ 💕', ms: 2200);
    _happyTimer?.cancel();
    _happyTimer = Timer(const Duration(milliseconds: 2600), () {
      if (mounted && _petMood == _PetMood.happy) {
        setState(() => _petMood = _PetMood.idle);
      }
    });
  }

  void _onPetTap() {
    HapticFeedback.lightImpact();
    _bumpActivity();
    setState(() => _petBurst++);
    _say(_petPhrases[math.Random().nextInt(_petPhrases.length)]);
  }

  Future<void> _onPetLongPress() async {
    HapticFeedback.mediumImpact();
    final next = _pets[(_pets.indexOf(_petEmoji) + 1) % _pets.length];
    setState(() {
      _petEmoji = next;
      _petBurst++;
    });
    _say('hi, I\'m your new buddy! ✨');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_petKey, next);
  }

  Widget _petRow() {
    final mood = _sending ? _PetMood.thinking : _petMood;
    final speech =
        _petSpeech ??
        (_sending
            ? 'thinking… 💭'
            : (mood == _PetMood.sleepy ? 'zzz… 💤' : null));
    return Padding(
      padding: const EdgeInsets.only(right: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (child, anim) => ScaleTransition(
              scale: anim,
              alignment: Alignment.bottomRight,
              child: FadeTransition(opacity: anim, child: child),
            ),
            child: speech == null
                ? const SizedBox.shrink(key: ValueKey('no-speech'))
                : Container(
                    key: ValueKey(speech),
                    margin: const EdgeInsets.only(bottom: 24),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.25),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      speech,
                      style: AppTextStyles.sans(
                        size: 11.5,
                        weight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
          ),
          const SizedBox(width: 4),
          _PetMascot(
            emoji: _petEmoji,
            mood: mood,
            burst: _petBurst,
            onTap: _onPetTap,
            onLongPress: _onPetLongPress,
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadInitialState();
    _loadLanguagePreference();
    _initSpeech();
    _loadPetPreference();
    _inputController.addListener(_bumpActivity);
    _bumpActivity();
    WidgetsBinding.instance.addPostFrameCallback((_) => _say('hi hi! 🐾'));
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    _inputFocusNode.dispose();
    _happyTimer?.cancel();
    _speechTimer?.cancel();
    _sleepTimer?.cancel();
    if (_listening) _speech.stop();
    super.dispose();
  }

  Future<void> _loadLanguagePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_languageKey);
    if (saved != null && mounted) {
      setState(() => _language = saved);
    }
  }

  Future<void> _toggleLanguage() async {
    final next = _language == 'en' ? 'ur' : 'en';
    setState(() => _language = next);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, next);
  }

  /// Sets up the 2speech recognizer. On Flutter web this uses the
  /// browser's built-in Web Speech API -- it works in Chrome/Edge but
  /// isn't supported in every browser, hence the availability check.
  Future<void> _initSpeech() async {
    final available = await _speech.initialize(
      onError: (err) {
        if (!mounted) return;
        setState(() {
          _listening = false;
          _errorText = 'Voice input error: ${err.errorMsg}';
        });
      },
      onStatus: (status) {
        if (!mounted) return;
        if (status == 'done' || status == 'notListening') {
          setState(() => _listening = false);
        }
      },
    );
    if (mounted) setState(() => _speechAvailable = available);
  }

  Future<void> _toggleListening() async {
    if (!_speechAvailable) {
      setState(
        () => _errorText =
            'Voice input isn\'t available in this browser. Try Chrome or Edge.',
      );
      return;
    }

    if (_listening) {
      await _speech.stop();
      setState(() => _listening = false);
      return;
    }

    setState(() {
      _listening = true;
      _errorText = null;
    });

    await _speech.listen(
      localeId: _language == 'ur' ? 'ur_PK' : 'en_US',
      onResult: (result) {
        setState(() {
          // Live-update the text field as words are recognized; final
          // punctuation/casing cleanup is left to the user before send.
          _inputController.text = result.recognizedWords;
          _inputController.selection = TextSelection.collapsed(
            offset: _inputController.text.length,
          );
        });
      },
    );
  }

  /// Opens the file/image picker and stages the result as a pending
  /// attachment shown above the input bar (sent along with the next
  /// message, or removable before then).
  Future<void> _pickAttachment() async {
    if (_pickingFile) return;
    setState(() => _pickingFile = true);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          'png',
          'jpg',
          'jpeg',
          'gif',
          'webp',
          'pdf',
          'doc',
          'docx',
          'txt',
        ],
        withData: true, // needed on web to get raw bytes
      );
      if (result == null || result.files.isEmpty) return;
      final file = result.files.first;
      if (file.bytes == null) {
        setState(() => _errorText = 'Could not read that file. Try again.');
        return;
      }
      // Keep uploads reasonably small -- large base64 payloads can time
      // out the /chat request or exceed the backend's body-size limit.
      const maxBytes = 8 * 1024 * 1024; // 8 MB
      if (file.bytes!.length > maxBytes) {
        setState(() => _errorText = '${file.name} is too large (max 8 MB).');
        return;
      }
      setState(() {
        _pendingAttachment = file;
        _errorText = null;
      });
    } finally {
      if (mounted) setState(() => _pickingFile = false);
    }
  }

  void _removeAttachment() {
    setState(() => _pendingAttachment = null);
  }

  String _mimeTypeFor(String fileName) {
    final ext = fileName.toLowerCase().split('.').last;
    switch (ext) {
      case 'png':
        return 'image/png';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      default:
        return 'text/plain';
    }
  }

  List<_ChatSession> _sessionsFrom(HealthProfile p) {
    final grouped = <String, List<ConversationEntry>>{};
    for (final e in p.conversationLog) {
      final key = e.sessionId ?? 'legacy';
      grouped.putIfAbsent(key, () => []).add(e);
    }
    final sessions = grouped.entries
        .map((e) => _ChatSession(e.key, e.value))
        .toList();
    sessions.sort((a, b) => b.lastActivity.compareTo(a.lastActivity));
    return sessions;
  }

  Future<void> _loadInitialState() async {
    final profile = await _profileService.loadProfile();
    if (!mounted) return;

    final sessions = _sessionsFrom(profile);
    setState(() {
      _profile = profile;
      if (sessions.isNotEmpty) {
        _currentSessionId = sessions.first.sessionId;
        _messages.addAll(sessions.first.entries);
      } else {
        _startFreshSession();
      }
      _loading = false;
    });
  }

  void _startFreshSession() {
    _currentSessionId = DateTime.now().millisecondsSinceEpoch.toString();
    _messages.clear();
    _messages.add(
      ConversationEntry(
        timestamp: DateTime.now(),
        role: 'assistant',
        message: _openingGreeting,
        sessionId: _currentSessionId,
      ),
    );
    _pendingSuggestedTab = null;
    _pendingSuggestedReason = null;
    _showCrisisBanner = false;
    _showMedicalEmergencyBanner = false;
  }

  void _startNewChat() {
    setState(_startFreshSession);
  }

  void _openHistory() {
    final sessions = _sessionsFrom(_profile!);
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(sheetContext).size.height * 0.75,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Chats',
                        style: AppTextStyles.sans(
                          size: 16,
                          weight: FontWeight.w700,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(sheetContext);
                          _startNewChat();
                        },
                        child: Row(
                          children: [
                            Icon(Icons.add, size: 16, color: AppColors.primary),
                            const SizedBox(width: 4),
                            Text(
                              'New chat',
                              style: AppTextStyles.sans(
                                size: 13,
                                weight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: sessions.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            'No past chats yet.',
                            style: AppTextStyles.sans(
                              size: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          itemCount: sessions.length,
                          itemBuilder: (context, index) {
                            final s = sessions[index];
                            final isActive = s.sessionId == _currentSessionId;
                            return ListTile(
                              onTap: () {
                                Navigator.pop(sheetContext);
                                setState(() {
                                  _currentSessionId = s.sessionId;
                                  _messages
                                    ..clear()
                                    ..addAll(s.entries);
                                  _pendingSuggestedTab = null;
                                  _pendingSuggestedReason = null;
                                });
                              },
                              leading: Icon(
                                Icons.chat_bubble_outline,
                                size: 18,
                                color: isActive
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                              ),
                              title: Text(
                                s.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.sans(
                                  size: 13,
                                  weight: isActive
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: isActive
                                      ? AppColors.primary
                                      : AppColors.textPrimary,
                                ),
                              ),
                              subtitle: Text(
                                _formatDate(s.lastActivity),
                                style: AppTextStyles.sans(
                                  size: 11,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime d) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  Future<void> _sendMessage() async {
    final text = _inputController.text.trim();
    final attachment = _pendingAttachment;
    if ((text.isEmpty && attachment == null) || _sending) return;

    _inputController.clear();
    setState(() {
      _sending = true;
      _errorText = null;
      _pendingSuggestedTab = null;
      _pendingSuggestedReason = null;
      _pendingAttachment = null;
    });

    final historyForRequest = _profile!.privacySettings.aiMemoryEnabled
        ? List<ConversationEntry>.from(_messages)
        : <ConversationEntry>[];

    final profileContext = _buildProfileContext();

    // If there's no typed text but there is an attachment, still show
    // something sensible in the chat bubble.
    final displayText = text.isNotEmpty ? text : '📎 ${attachment!.name}';

    final userEntry = ConversationEntry(
      timestamp: DateTime.now(),
      role: 'user',
      message: displayText,
      sessionId: _currentSessionId,
    );
    setState(() => _messages.add(userEntry));
    _scrollToBottom();

    await _profileService.appendConversationEntry(
      'user',
      displayText,
      sessionId: _currentSessionId,
    );

    try {
      final result = await _aiService.sendMessage(
        message: text,
        history: historyForRequest,
        profileContext: profileContext,
        language: _language,
        attachment: attachment == null
            ? null
            : ChatAttachment(
                fileName: attachment.name,
                mimeType: _mimeTypeFor(attachment.name),
                base64Data: base64Encode(attachment.bytes!),
              ),
      );

      final assistantEntry = ConversationEntry(
        timestamp: DateTime.now(),
        role: 'assistant',
        message: result.reply,
        sessionId: _currentSessionId,
      );

      await _profileService.appendConversationEntry(
        'assistant',
        result.reply,
        sessionId: _currentSessionId,
      );

      HealthProfile? updatedProfile;
      if (result.profileUpdates != null) {
        updatedProfile = await _profileService.updateProfile(
          (p) => _applyStructuredUpdates(p, result.profileUpdates!),
        );
      }

      if (!mounted) return;
      setState(() {
        _messages.add(assistantEntry);
        if (updatedProfile != null) _profile = updatedProfile;
        _pendingSuggestedTab = result.suggestedTab;
        _pendingSuggestedReason = result.suggestedTabReason;
        if (result.crisisConcern) _showCrisisBanner = true;
        if (result.medicalEmergencyConcern) _showMedicalEmergencyBanner = true;
        _sending = false;
      });
      // Keep the pet calm (no confetti) when a safety banner is showing.
      if (!result.crisisConcern && !result.medicalEmergencyConcern) {
        _celebrate();
      }
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _sending = false;
        _errorText = e is AuthRequiredException
            ? e.message
            : e is ChatException
            ? e.userMessage
            : "Couldn't reach the check-in assistant. Check your connection and try again.";
      });
      _say('oops… try again 🥺');
    }
  }

  HealthProfile _applyStructuredUpdates(
    HealthProfile current,
    Map<String, dynamic> updates,
  ) {
    var result = current;

    final lifestyleUpdate = updates['lifestyle'] as Map<String, dynamic>?;
    if (lifestyleUpdate != null && lifestyleUpdate.isNotEmpty) {
      final merged = {...result.lifestyle.toJson(), ...lifestyleUpdate};
      result = result.copyWith(lifestyle: Lifestyle.fromJson(merged));
    }

    final mentalHealthUpdate =
        updates['mental_health'] as Map<String, dynamic>?;
    final lifeContextUpdate = updates['life_context'] as Map<String, dynamic>?;
    if ((mentalHealthUpdate != null && mentalHealthUpdate.isNotEmpty) ||
        (lifeContextUpdate != null && lifeContextUpdate.isNotEmpty)) {
      final merged = {
        ...result.mentalHealth.toJson(),
        ...?mentalHealthUpdate,
        if (lifeContextUpdate?['financial_stress'] != null)
          'financial_stress': lifeContextUpdate!['financial_stress'],
        if (lifeContextUpdate?['relationship_status'] != null)
          'relationship_status': lifeContextUpdate!['relationship_status'],
        if (lifeContextUpdate?['relationship_or_marital_difficulty'] != null)
          'relationship_or_marital_difficulty':
              lifeContextUpdate!['relationship_or_marital_difficulty'],
        if (lifeContextUpdate?['family_conflict'] != null)
          'family_conflict': lifeContextUpdate!['family_conflict'],
        if (lifeContextUpdate?['support_system_notes'] != null)
          'support_system_notes': lifeContextUpdate!['support_system_notes'],
        'last_check_in': DateTime.now().toIso8601String(),
      };
      result = result.copyWith(
        mentalHealth: MentalHealthFlags.fromJson(merged),
      );
    }

    final reproUpdate =
        updates['reproductive_history'] as Map<String, dynamic>?;
    if (reproUpdate != null && reproUpdate.isNotEmpty) {
      final merged = {...result.reproductiveHistory.toJson(), ...reproUpdate};
      result = result.copyWith(
        reproductiveHistory: ReproductiveHistory.fromJson(merged),
      );
    }

    return result;
  }

  Map<String, dynamic> _buildProfileContext() {
    final p = _profile!;
    final cycle = context.read<CycleProvider>().cycleData;

    final ctx = <String, dynamic>{
      'demographics': {
        'age_yrs': p.demographics.ageYrs,
        'marital_status': p.demographics.maritalStatus,
      },
      'lifestyle': p.lifestyle.toJson(),
      'mental_health': p.mentalHealth.toJson(),
      'reproductive_history': {
        'cycle_regularity': p.reproductiveHistory.cycleRegularity,
        'current_contraception_method':
            p.reproductiveHistory.currentContraceptionMethod,
      },
      'pcos_history_count': p.pcosHistory.length,
      'latest_pcos_result': p.pcosHistory.isNotEmpty
          ? p.pcosHistory.last.prediction
          : null,
      'cycle': {
        'current_cycle_day': cycle.getCurrentCycleDay(),
        'phase': cycle.getPhase(),
        'days_until_next_period': cycle.daysUntilNextPeriod(),
      },
    };

    if (p.privacySettings.aiCanAccessDiary && p.diaryEntries.isNotEmpty) {
      final recent = p.diaryEntries.length > 5
          ? p.diaryEntries.sublist(p.diaryEntries.length - 5)
          : p.diaryEntries;
      ctx['recent_diary_entries'] = recent
          .map(
            (d) => {
              'date': d.date.toIso8601String(),
              'mood': d.mood,
              'symptom_tags': d.symptomTags,
              'text': d.text,
            },
          )
          .toList();
    }

    return ctx;
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final showChips = _messages.length == 1 && !_sending;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF8F1FD), Color(0xFFF4ECFA), Color(0xFFFCEFF6)],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            _topBar(),
            if (_showMedicalEmergencyBanner) _medicalEmergencyBanner(),
            if (_showCrisisBanner) _crisisBanner(),
            Expanded(
              child: Stack(
                children: [
                  const Positioned.fill(
                    child: IgnorePointer(child: _FloatingDecor()),
                  ),
                  ListView(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                    children: [
                      for (final m in _messages) _messageBubble(m),
                      if (showChips) _quickReplies(),
                      if (_sending) _typingBubble(),
                      if (_pendingSuggestedTab != null)
                        _suggestionCard(
                          _pendingSuggestedTab!,
                          _pendingSuggestedReason,
                        ),
                    ],
                  ),
                ],
              ),
            ),
            if (_errorText != null)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(14, 0, 14, 6),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.periodRed.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: AppColors.periodRed.withValues(alpha: 0.25),
                  ),
                ),
                child: Text(
                  '😕  $_errorText',
                  style: AppTextStyles.sans(
                    size: 12,
                    color: AppColors.periodRed,
                  ),
                ),
              ),
            if (_pendingAttachment != null) _attachmentChip(),
            _petRow(),
            _inputBar(),
          ],
        ),
      ),
    );
  }

  Widget _saheliAvatar({double size = 30}) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF3D9EC), Color(0xFFDCC8F2)],
        ),
      ),
      child: Center(
        child: Text('🌸', style: TextStyle(fontSize: size * 0.5)),
      ),
    );
  }

  Widget _quickReplies() {
    return Padding(
      padding: const EdgeInsets.only(left: 38, bottom: 14, top: 2),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final chip in _moodChips)
            ActionChip(
              onPressed: () => _sendQuickReply(chip[2]),
              backgroundColor: AppColors.surface,
              side: BorderSide(
                color: AppColors.primary.withValues(alpha: 0.35),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              label: Text(
                '${chip[0]}  ${chip[1]}',
                style: AppTextStyles.sans(
                  size: 12.5,
                  weight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _typingBubble() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _saheliAvatar(size: 28),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomRight: Radius.circular(18),
                bottomLeft: Radius.circular(4),
              ),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: const _TypingDots(),
          ),
        ],
      ),
    );
  }

  Widget _topBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.85),
        border: Border(bottom: BorderSide(color: AppColors.cardBorder)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              _saheliAvatar(size: 38),
              Positioned(
                right: -1,
                bottom: -1,
                child: Container(
                  width: 11,
                  height: 11,
                  decoration: BoxDecoration(
                    color: AppColors.ovulationTeal,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.surface, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Saheli 💜',
                  style: AppTextStyles.sans(size: 15, weight: FontWeight.w700),
                ),
                Text(
                  _sending
                      ? 'typing…'
                      : (_language == 'ur'
                            ? 'آپ کی ساتھی'
                            : 'Your caring check-in buddy'),
                  style: AppTextStyles.sans(
                    size: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _toggleLanguage,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              margin: const EdgeInsets.only(right: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.translate, size: 14, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Text(
                    _language == 'en' ? 'EN' : 'اردو',
                    style: AppTextStyles.sans(
                      size: 12,
                      weight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            onPressed: _openHistory,
            icon: const Icon(Icons.history_rounded),
            color: AppColors.textSecondary,
            iconSize: 20,
            tooltip: 'Chat history',
          ),
          IconButton(
            onPressed: _startNewChat,
            icon: const Icon(Icons.add_comment_outlined),
            color: AppColors.textSecondary,
            iconSize: 20,
            tooltip: 'New chat',
          ),
        ],
      ),
    );
  }

  Widget _medicalEmergencyBanner() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.periodRed.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.periodRed.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_rounded, size: 18, color: AppColors.periodRed),
              const SizedBox(width: 8),
              Text(
                'This may need urgent medical care',
                style: AppTextStyles.sans(
                  size: 13,
                  weight: FontWeight.w700,
                  color: AppColors.periodRed,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'What you\'ve described could be a medical emergency. Please '
            'seek in-person medical attention now -- an emergency room or '
            'urgent care -- rather than continuing to rely on this chat.',
            style: AppTextStyles.sans(
              size: 12,
              color: AppColors.textSecondary,
            ).copyWith(height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _crisisBanner() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.periodRed.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.periodRed.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.favorite, size: 16, color: AppColors.periodRed),
              const SizedBox(width: 8),
              Text(
                'You matter, and support is available',
                style: AppTextStyles.sans(
                  size: 12.5,
                  weight: FontWeight.w700,
                  color: AppColors.periodRed,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'If things feel like too much right now, please consider reaching '
            'out to a crisis helpline in your area, or to someone you trust.',
            style: AppTextStyles.sans(
              size: 12,
              color: AppColors.textSecondary,
            ).copyWith(height: 1.5),
          ),
          const SizedBox(height: 4),
          Text(
            'Befrienders Worldwide (befrienders.org) lists crisis lines by country.',
            style: AppTextStyles.sans(
              size: 11,
              color: AppColors.periodRed,
            ).copyWith(fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Widget _messageBubble(ConversationEntry entry) {
    final isUser = entry.role == 'user';
    final maxW = MediaQuery.of(context).size.width * 0.74;

    final bubble = Container(
      constraints: BoxConstraints(maxWidth: maxW),
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
      decoration: BoxDecoration(
        gradient: isUser
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF9A6FCB), Color(0xFF8B5FBF)],
              )
            : null,
        color: isUser ? null : AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(18),
          topRight: const Radius.circular(18),
          bottomLeft: Radius.circular(isUser ? 18 : 4),
          bottomRight: Radius.circular(isUser ? 4 : 18),
        ),
        border: isUser ? null : Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: isUser ? 0.18 : 0.07),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              entry.message,
              style: AppTextStyles.sans(
                size: 14,
                color: isUser ? Colors.white : AppColors.textPrimary,
              ).copyWith(height: 1.5),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            _formatTime(entry.timestamp),
            style: AppTextStyles.sans(
              size: 9.5,
              color: isUser
                  ? Colors.white.withValues(alpha: 0.7)
                  : AppColors.textSecondary.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );

    final row = Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: isUser
            ? [bubble]
            : [_saheliAvatar(size: 28), const SizedBox(width: 8), bubble],
      ),
    );

    // Cute "pop" entrance for every new message.
    return TweenAnimationBuilder<double>(
      key: ValueKey(entry.timestamp.microsecondsSinceEpoch),
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutBack,
      builder: (context, v, child) => Opacity(
        opacity: v.clamp(0.0, 1.0),
        child: Transform.scale(
          scale: 0.85 + 0.15 * v,
          alignment: isUser ? Alignment.bottomRight : Alignment.bottomLeft,
          child: child,
        ),
      ),
      child: row,
    );
  }

  Widget _suggestionCard(String tab, String? reason) {
    final label = tab == 'pcos'
        ? 'PCOS Detection'
        : 'Contraception & Protection';
    final color = tab == 'pcos' ? AppColors.periodRed : AppColors.ovulationTeal;

    return Container(
      margin: const EdgeInsets.only(bottom: 14, left: 38),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                tab == 'pcos' ? '🔍' : '🛡️',
                style: const TextStyle(fontSize: 15),
              ),
              const SizedBox(width: 6),
              Text(
                'Might be worth a look: $label',
                style: AppTextStyles.sans(
                  size: 12.5,
                  weight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
          if (reason != null) ...[
            const SizedBox(height: 6),
            Text(
              reason,
              style: AppTextStyles.sans(
                size: 12,
                color: AppColors.textSecondary,
              ).copyWith(height: 1.4),
            ),
          ],
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                if (widget.onNavigateToTab != null) {
                  widget.onNavigateToTab!(tab);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Open the $label tab to check this out'),
                    ),
                  );
                }
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: color,
                side: BorderSide(color: color.withValues(alpha: 0.6)),
                padding: const EdgeInsets.symmetric(vertical: 11),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                'Take me there ✨',
                style: AppTextStyles.sans(size: 12.5, weight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _attachmentChip() {
    final file = _pendingAttachment!;
    final isImage = _mimeTypeFor(file.name).startsWith('image/');
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            isImage ? Icons.image_outlined : Icons.insert_drive_file_outlined,
            size: 16,
            color: AppColors.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              file.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.sans(size: 12.5, weight: FontWeight.w600),
            ),
          ),
          GestureDetector(
            onTap: _removeAttachment,
            child: Icon(Icons.close, size: 16, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  /// Intercepts the hardware Enter key on desktop/web so it sends the
  /// message instead of inserting a newline. Shift+Enter still inserts
  /// a newline for multi-line messages.
  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final isEnter =
        event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.numpadEnter;
    if (!isEnter) return KeyEventResult.ignored;

    final shiftHeld = HardwareKeyboard.instance.isShiftPressed;
    if (shiftHeld) return KeyEventResult.ignored; // allow newline

    _sendMessage();
    return KeyEventResult.handled;
  }

  Widget _inputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.9),
        border: Border(top: BorderSide(color: AppColors.cardBorder)),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            IconButton(
              onPressed: _pickingFile ? null : _pickAttachment,
              icon: _pickingFile
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.add),
              color: AppColors.textSecondary,
              iconSize: 20,
              tooltip: 'Attach a photo or document',
            ),
            Expanded(
              child: Focus(
                onKeyEvent: _handleKey,
                child: TextField(
                  controller: _inputController,
                  focusNode: _inputFocusNode,
                  minLines: 1,
                  maxLines: 4,
                  textCapitalization: TextCapitalization.sentences,
                  textDirection: _language == 'ur'
                      ? TextDirection.rtl
                      : TextDirection.ltr,
                  onSubmitted: (_) => _sendMessage(),
                  decoration: InputDecoration(
                    hintText: _listening
                        ? 'Listening…'
                        : (_language == 'ur'
                              ? 'سہیلی کو پیغام بھیجیں…'
                              : 'Tell Saheli how you feel… 💬'),
                    hintStyle: AppTextStyles.sans(
                      size: 13,
                      color: AppColors.textSecondary,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ),
            IconButton(
              onPressed: _toggleListening,
              icon: Icon(
                _listening ? Icons.mic_rounded : Icons.mic_none_rounded,
              ),
              color: _listening ? AppColors.periodRed : AppColors.textSecondary,
              iconSize: 20,
              tooltip: _speechAvailable
                  ? (_listening ? 'Stop recording' : 'Voice message')
                  : 'Voice input not supported in this browser',
            ),
            _sending
                ? const SizedBox(
                    width: 36,
                    height: 36,
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : IconButton(
                    onPressed: _sendMessage,
                    icon: const Icon(Icons.arrow_upward_rounded),
                    color: Colors.white,
                    iconSize: 18,
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      elevation: 2,
                      shadowColor: AppColors.primary,
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(8),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

/// Three softly bouncing dots shown while Saheli is "typing".
class _TypingDots extends StatefulWidget {
  const _TypingDots();

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final t = ((_c.value - i * 0.18) % 1.0).clamp(0.0, 1.0);
            final lift = t < 0.5 ? t * 2 : (1 - t) * 2; // 0..1..0
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2.5),
              transform: Matrix4.translationValues(0, -4 * lift, 0),
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.35 + 0.5 * lift),
              ),
            );
          }),
        );
      },
    );
  }
}

enum _PetMood { idle, thinking, happy, sleepy }

/// A tiny emoji pet that lives above the input bar. It breathes when idle,
/// wobbles while Saheli is thinking, bounces when happy, naps when you've
/// been quiet, and throws out hearts when you tap it.
class _PetMascot extends StatefulWidget {
  final String emoji;
  final _PetMood mood;
  final int burst;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _PetMascot({
    required this.emoji,
    required this.mood,
    required this.burst,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  State<_PetMascot> createState() => _PetMascotState();
}

class _PetMascotState extends State<_PetMascot> with TickerProviderStateMixin {
  late final AnimationController _loop = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  )..repeat();
  late final AnimationController _hop = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 650),
  );
  late final AnimationController _hearts = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  );

  static const _heartEmojis = ['💕', '💜', '✨', '🌸', '💖'];

  @override
  void didUpdateWidget(covariant _PetMascot old) {
    super.didUpdateWidget(old);
    if (widget.burst != old.burst) {
      _hop.forward(from: 0);
      _hearts.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _loop.dispose();
    _hop.dispose();
    _hearts.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: SizedBox(
        width: 60,
        height: 60,
        child: AnimatedBuilder(
          animation: Listenable.merge([_loop, _hop, _hearts]),
          builder: (context, _) {
            final t = _loop.value;
            final wave = math.sin(t * 2 * math.pi);
            double dy = 0, scale = 1, rot = 0, opacity = 1;

            switch (widget.mood) {
              case _PetMood.idle:
                scale = 1 + 0.04 * wave;
                dy = -1.5 * wave;
              case _PetMood.thinking:
                rot = 0.16 * math.sin(t * 4 * math.pi);
              case _PetMood.happy:
                dy = -7 * math.sin(t * 4 * math.pi).abs();
                rot = 0.08 * math.sin(t * 4 * math.pi);
              case _PetMood.sleepy:
                scale = 0.94 + 0.03 * wave;
                opacity = 0.65;
            }

            final hop = math.sin(_hop.value * math.pi);
            dy -= 18 * hop;
            final hp = _hearts.value;
            final showHearts = hp > 0 && hp < 1;

            return Stack(
              clipBehavior: Clip.none,
              children: [
                // soft shadow under the pet
                Positioned(
                  bottom: 2,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      width: 26 * (1 - 0.3 * hop),
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                if (showHearts)
                  for (int i = 0; i < _heartEmojis.length; i++)
                    Positioned(
                      left: 24 + (i - 2) * 13.0 + (i - 2) * 6 * hp,
                      bottom: 34 + 36 * hp + (i % 2) * 6,
                      child: Opacity(
                        opacity: (1 - hp).clamp(0.0, 1.0),
                        child: Text(
                          _heartEmojis[i],
                          style: TextStyle(fontSize: 12.0 + (i % 2) * 3),
                        ),
                      ),
                    ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Transform.translate(
                      offset: Offset(0, dy),
                      child: Transform.rotate(
                        angle: rot,
                        child: Transform.scale(
                          scale: scale,
                          child: Opacity(
                            opacity: opacity,
                            child: Text(
                              widget.emoji,
                              style: const TextStyle(fontSize: 38),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (widget.mood == _PetMood.sleepy)
                  Positioned(
                    right: -2,
                    top: 6 - 10 * t,
                    child: Opacity(
                      opacity: (1 - t).clamp(0.0, 1.0),
                      child: const Text('💤', style: TextStyle(fontSize: 14)),
                    ),
                  ),
                if (widget.mood == _PetMood.thinking)
                  Positioned(
                    right: -4,
                    top: -2 + 2 * wave,
                    child: const Text('💭', style: TextStyle(fontSize: 15)),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Faint flowers / sparkles / butterflies drifting up behind the chat.
class _FloatingDecor extends StatefulWidget {
  const _FloatingDecor();

  @override
  State<_FloatingDecor> createState() => _FloatingDecorState();
}

class _FloatingDecorState extends State<_FloatingDecor>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 24),
  )..repeat();

  // [emoji, x fraction, phase, font size]
  static const List<List<Object>> _items = [
    ['🌸', 0.08, 0.00, 16.0],
    ['✨', 0.28, 0.35, 13.0],
    ['💜', 0.50, 0.70, 14.0],
    ['🌷', 0.72, 0.20, 15.0],
    ['⭐', 0.90, 0.55, 12.0],
    ['🦋', 0.18, 0.85, 15.0],
    ['🐾', 0.62, 0.45, 13.0],
  ];

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        return AnimatedBuilder(
          animation: _c,
          builder: (context, _) {
            return Stack(
              children: [
                for (final it in _items)
                  Builder(
                    builder: (context) {
                      final p = (_c.value + (it[2] as double)) % 1.0;
                      final x =
                          box.maxWidth * (it[1] as double) +
                          14 * math.sin(p * 4 * math.pi);
                      final y = box.maxHeight * (1 - p);
                      return Positioned(
                        left: x,
                        top: y,
                        child: Opacity(
                          opacity: 0.22 * math.sin(p * math.pi),
                          child: Text(
                            it[0] as String,
                            style: TextStyle(fontSize: it[3] as double),
                          ),
                        ),
                      );
                    },
                  ),
              ],
            );
          },
        );
      },
    );
  }
}
