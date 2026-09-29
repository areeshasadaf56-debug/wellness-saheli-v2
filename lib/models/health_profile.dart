/// MODULE: models/health_profile.dart
/// ROLE: The single source of truth for everything the app knows about a
/// user over time -- their "health diary". Every tab (PCOS, Protection,
/// Diary, and the AI check-in chat) reads from and writes to this same
/// model, so the AI agent can reference past answers instead of
/// re-asking, and so a PCOS result, a contraception choice, or an
/// eligibility check made today is still visible next month.
///
/// This is intentionally a loose, nested JSON-friendly structure (not a
/// rigid SQL schema) because the fields here will keep growing as you add
/// features -- adding a new field just means adding it to the map, no
/// migration needed on the backend (see health_profile_api.py).
///
/// NOTE: This file defines the app's `PrivacySettings` class (below),
/// used throughout the app (fields: aiCanAccessDiary, aiMemoryEnabled).
/// (An earlier, unused duplicate class of the same name that lived in
/// models/privacy_settings.dart has been removed — this is the only
/// PrivacySettings class in the codebase now.)
///
/// USED BY: services/health_profile_service.dart (all reads/writes go
/// through here), screens/pcos_screen.dart, screens/protection_screen.dart,
/// screens/health_diary_screen.dart, screens/ai_checkin_screen.dart,
/// widgets/wellness_check_in_dialog.dart, widgets/diary_entry_dialog.dart.
library;

class HealthProfile {
  final String userId;

  final Demographics demographics;
  final Lifestyle lifestyle;
  final ReproductiveHistory reproductiveHistory;
  final List<PcosCheckResult> pcosHistory;
  final List<EligibilityCheckResult> eligibilityHistory;
  final MentalHealthFlags mentalHealth;
  final List<ConversationEntry> conversationLog;

  /// User-controlled toggles for what the AI check-in is allowed to use
  /// -- e.g. whether it remembers past chat turns, and whether it can
  /// read recent free-text diary entries as context. Read/written from
  /// data_privacy_screen.dart.
  final PrivacySettings privacySettings;

  /// Free-text personal journal entries (separate from the
  /// auto-generated Health Diary timeline in health_diary_screen.dart,
  /// which is built from PCOS/Protection/Cycle/AI history instead of
  /// entries the user writes themselves).
  final List<DiaryEntry> diaryEntries;

  final DateTime lastUpdated;

  const HealthProfile({
    required this.userId,
    required this.demographics,
    required this.lifestyle,
    required this.reproductiveHistory,
    required this.pcosHistory,
    required this.eligibilityHistory,
    required this.mentalHealth,
    required this.conversationLog,
    required this.privacySettings,
    required this.diaryEntries,
    required this.lastUpdated,
  });

  /// A blank profile for a brand-new user (first app launch).
  factory HealthProfile.empty(String userId) {
    return HealthProfile(
      userId: userId,
      demographics: const Demographics(),
      lifestyle: const Lifestyle(),
      reproductiveHistory: const ReproductiveHistory(),
      pcosHistory: const [],
      eligibilityHistory: const [],
      mentalHealth: const MentalHealthFlags(),
      conversationLog: const [],
      privacySettings: const PrivacySettings(),
      diaryEntries: const [],
      lastUpdated: DateTime.now(),
    );
  }

  HealthProfile copyWith({
    Demographics? demographics,
    Lifestyle? lifestyle,
    ReproductiveHistory? reproductiveHistory,
    List<PcosCheckResult>? pcosHistory,
    List<EligibilityCheckResult>? eligibilityHistory,
    MentalHealthFlags? mentalHealth,
    List<ConversationEntry>? conversationLog,
    PrivacySettings? privacySettings,
    List<DiaryEntry>? diaryEntries,
  }) {
    return HealthProfile(
      userId: userId,
      demographics: demographics ?? this.demographics,
      lifestyle: lifestyle ?? this.lifestyle,
      reproductiveHistory: reproductiveHistory ?? this.reproductiveHistory,
      pcosHistory: pcosHistory ?? this.pcosHistory,
      eligibilityHistory: eligibilityHistory ?? this.eligibilityHistory,
      mentalHealth: mentalHealth ?? this.mentalHealth,
      conversationLog: conversationLog ?? this.conversationLog,
      privacySettings: privacySettings ?? this.privacySettings,
      diaryEntries: diaryEntries ?? this.diaryEntries,
      lastUpdated: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'demographics': demographics.toJson(),
    'lifestyle': lifestyle.toJson(),
    'reproductive_history': reproductiveHistory.toJson(),
    'pcos_history': pcosHistory.map((e) => e.toJson()).toList(),
    'eligibility_history': eligibilityHistory.map((e) => e.toJson()).toList(),
    'mental_health': mentalHealth.toJson(),
    'conversation_log': conversationLog.map((e) => e.toJson()).toList(),
    'privacy_settings': privacySettings.toJson(),
    'diary_entries': diaryEntries.map((e) => e.toJson()).toList(),
    'last_updated': lastUpdated.toIso8601String(),
  };

  factory HealthProfile.fromJson(Map<String, dynamic> json) {
    return HealthProfile(
      userId: json['user_id'] as String,
      demographics: Demographics.fromJson(
        json['demographics'] as Map<String, dynamic>? ?? {},
      ),
      lifestyle: Lifestyle.fromJson(
        json['lifestyle'] as Map<String, dynamic>? ?? {},
      ),
      reproductiveHistory: ReproductiveHistory.fromJson(
        json['reproductive_history'] as Map<String, dynamic>? ?? {},
      ),
      pcosHistory: (json['pcos_history'] as List<dynamic>? ?? [])
          .map((e) => PcosCheckResult.fromJson(e as Map<String, dynamic>))
          .toList(),
      eligibilityHistory: (json['eligibility_history'] as List<dynamic>? ?? [])
          .map(
            (e) => EligibilityCheckResult.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
      mentalHealth: MentalHealthFlags.fromJson(
        json['mental_health'] as Map<String, dynamic>? ?? {},
      ),
      conversationLog: (json['conversation_log'] as List<dynamic>? ?? [])
          .map((e) => ConversationEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      privacySettings: PrivacySettings.fromJson(
        json['privacy_settings'] as Map<String, dynamic>? ?? {},
      ),
      diaryEntries: (json['diary_entries'] as List<dynamic>? ?? [])
          .map((e) => DiaryEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      lastUpdated: json['last_updated'] != null
          ? DateTime.parse(json['last_updated'] as String)
          : DateTime.now(),
    );
  }
}

/// ---------------------------------------------------------------
/// Privacy settings -- user-controlled toggles for what the AI
/// check-in is allowed to use. Both default to true so existing AI
/// features keep working exactly as before for anyone who never
/// visits Settings > Data & Privacy to change them; the toggles exist
/// so users CAN opt out, not so the app starts locked down.
/// ---------------------------------------------------------------
class PrivacySettings {
  /// Whether the AI check-in sends past turns of the current chat
  /// session as context on each new message (i.e. "remembers" the
  /// conversation so far). When false, each message is sent with no
  /// history, so the AI has no memory even within one session.
  final bool aiMemoryEnabled;

  /// Whether the AI check-in may read recent free-text diaryEntries as
  /// additional context (mood, symptom tags, journal text) when
  /// building its replies.
  final bool aiCanAccessDiary;

  const PrivacySettings({
    this.aiMemoryEnabled = true,
    this.aiCanAccessDiary = true,
  });

  PrivacySettings copyWith({bool? aiMemoryEnabled, bool? aiCanAccessDiary}) {
    return PrivacySettings(
      aiMemoryEnabled: aiMemoryEnabled ?? this.aiMemoryEnabled,
      aiCanAccessDiary: aiCanAccessDiary ?? this.aiCanAccessDiary,
    );
  }

  Map<String, dynamic> toJson() => {
    'ai_memory_enabled': aiMemoryEnabled,
    'ai_can_access_diary': aiCanAccessDiary,
  };

  factory PrivacySettings.fromJson(Map<String, dynamic> json) {
    return PrivacySettings(
      aiMemoryEnabled: json['ai_memory_enabled'] as bool? ?? true,
      aiCanAccessDiary: json['ai_can_access_diary'] as bool? ?? true,
    );
  }
}

/// ---------------------------------------------------------------
/// A free-text personal journal entry -- distinct from the
/// auto-generated Health Diary timeline (health_diary_screen.dart),
/// which is built purely from PCOS/Protection/Cycle/AI history rather
/// than something the user writes themselves.
/// ---------------------------------------------------------------
class DiaryEntry {
  final DateTime date;
  final String? mood;
  final List<String> symptomTags;
  final String text;

  const DiaryEntry({
    required this.date,
    this.mood,
    this.symptomTags = const [],
    required this.text,
  });

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'mood': mood,
    'symptom_tags': symptomTags,
    'text': text,
  };

  factory DiaryEntry.fromJson(Map<String, dynamic> json) {
    return DiaryEntry(
      date: DateTime.parse(json['date'] as String),
      mood: json['mood'] as String?,
      symptomTags: List<String>.from(json['symptom_tags'] ?? []),
      text: json['text'] as String? ?? '',
    );
  }
}

/// ---------------------------------------------------------------
/// Demographics -- who the user is. Kept separate from lifestyle so
/// the PCOS/Protection forms can pull just this section without
/// pulling everything else.
/// ---------------------------------------------------------------
class Demographics {
  final int? ageYrs;
  final double? weightKg;
  final double? heightCm;

  /// 'Single', 'Married', 'Divorced', 'Widowed', or null if not provided.
  /// Relevant because some contraception/PCOS guidance differs by this
  /// (e.g. fertility planning conversations, some WHO MEC categories).
  final String? maritalStatus;

  const Demographics({
    this.ageYrs,
    this.weightKg,
    this.heightCm,
    this.maritalStatus,
  });

  Demographics copyWith({
    int? ageYrs,
    double? weightKg,
    double? heightCm,
    String? maritalStatus,
  }) {
    return Demographics(
      ageYrs: ageYrs ?? this.ageYrs,
      weightKg: weightKg ?? this.weightKg,
      heightCm: heightCm ?? this.heightCm,
      maritalStatus: maritalStatus ?? this.maritalStatus,
    );
  }

  Map<String, dynamic> toJson() => {
    'age_yrs': ageYrs,
    'weight_kg': weightKg,
    'height_cm': heightCm,
    'marital_status': maritalStatus,
  };

  factory Demographics.fromJson(Map<String, dynamic> json) {
    return Demographics(
      ageYrs: json['age_yrs'] as int?,
      weightKg: (json['weight_kg'] as num?)?.toDouble(),
      heightCm: (json['height_cm'] as num?)?.toDouble(),
      maritalStatus: json['marital_status'] as String?,
    );
  }
}

/// ---------------------------------------------------------------
/// Lifestyle -- the day-to-day habits the AI check-in asks about
/// (exercise, diet, fast food, sleep) and uses to drive
/// recommendations.
/// ---------------------------------------------------------------
class Lifestyle {
  final bool? regularExercise;
  final String? exerciseFrequency; // e.g. 'Never', '1-2x/week', '3+/week'
  final String? dietQuality; // e.g. 'Poor', 'Average', 'Good'
  final bool? fastFoodFrequent;
  final double? averageSleepHours;

  /// Free-text notes captured verbatim from the AI chat, in case the
  /// structured fields above don't capture everything the user said.
  final String? notes;

  const Lifestyle({
    this.regularExercise,
    this.exerciseFrequency,
    this.dietQuality,
    this.fastFoodFrequent,
    this.averageSleepHours,
    this.notes,
  });

  Lifestyle copyWith({
    bool? regularExercise,
    String? exerciseFrequency,
    String? dietQuality,
    bool? fastFoodFrequent,
    double? averageSleepHours,
    String? notes,
  }) {
    return Lifestyle(
      regularExercise: regularExercise ?? this.regularExercise,
      exerciseFrequency: exerciseFrequency ?? this.exerciseFrequency,
      dietQuality: dietQuality ?? this.dietQuality,
      fastFoodFrequent: fastFoodFrequent ?? this.fastFoodFrequent,
      averageSleepHours: averageSleepHours ?? this.averageSleepHours,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() => {
    'regular_exercise': regularExercise,
    'exercise_frequency': exerciseFrequency,
    'diet_quality': dietQuality,
    'fast_food_frequent': fastFoodFrequent,
    'average_sleep_hours': averageSleepHours,
    'notes': notes,
  };

  factory Lifestyle.fromJson(Map<String, dynamic> json) {
    return Lifestyle(
      regularExercise: json['regular_exercise'] as bool?,
      exerciseFrequency: json['exercise_frequency'] as String?,
      dietQuality: json['diet_quality'] as String?,
      fastFoodFrequent: json['fast_food_frequent'] as bool?,
      averageSleepHours: (json['average_sleep_hours'] as num?)?.toDouble(),
      notes: json['notes'] as String?,
    );
  }
}

/// ---------------------------------------------------------------
/// Reproductive history -- cycle info and contraception choices over
/// time, feeding both the Protection tab and future PCOS pre-fill.
/// ---------------------------------------------------------------
class ReproductiveHistory {
  final String? cycleRegularity; // 'Regular' or 'Irregular'
  final int? cycleLengthDays;

  /// The contraception method currently in use, if any (matches the
  /// method names used in protection_screen.dart's _methods list).
  final String? currentContraceptionMethod;

  /// Every eligibility check or method chosen over time, most recent
  /// last -- lets "My Plan" show a real history instead of only the
  /// latest result.
  final List<ContraceptionLogEntry> contraceptionHistory;

  const ReproductiveHistory({
    this.cycleRegularity,
    this.cycleLengthDays,
    this.currentContraceptionMethod,
    this.contraceptionHistory = const [],
  });

  ReproductiveHistory copyWith({
    String? cycleRegularity,
    int? cycleLengthDays,
    String? currentContraceptionMethod,
    List<ContraceptionLogEntry>? contraceptionHistory,
  }) {
    return ReproductiveHistory(
      cycleRegularity: cycleRegularity ?? this.cycleRegularity,
      cycleLengthDays: cycleLengthDays ?? this.cycleLengthDays,
      currentContraceptionMethod:
          currentContraceptionMethod ?? this.currentContraceptionMethod,
      contraceptionHistory: contraceptionHistory ?? this.contraceptionHistory,
    );
  }

  Map<String, dynamic> toJson() => {
    'cycle_regularity': cycleRegularity,
    'cycle_length_days': cycleLengthDays,
    'current_contraception_method': currentContraceptionMethod,
    'contraception_history': contraceptionHistory
        .map((e) => e.toJson())
        .toList(),
  };

  factory ReproductiveHistory.fromJson(Map<String, dynamic> json) {
    return ReproductiveHistory(
      cycleRegularity: json['cycle_regularity'] as String?,
      cycleLengthDays: json['cycle_length_days'] as int?,
      currentContraceptionMethod:
          json['current_contraception_method'] as String?,
      contraceptionHistory:
          (json['contraception_history'] as List<dynamic>? ?? [])
              .map(
                (e) =>
                    ContraceptionLogEntry.fromJson(e as Map<String, dynamic>),
              )
              .toList(),
    );
  }
}

class ContraceptionLogEntry {
  final DateTime date;
  final String method;
  final String? note;

  const ContraceptionLogEntry({
    required this.date,
    required this.method,
    this.note,
  });

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'method': method,
    'note': note,
  };

  factory ContraceptionLogEntry.fromJson(Map<String, dynamic> json) {
    return ContraceptionLogEntry(
      date: DateTime.parse(json['date'] as String),
      method: json['method'] as String,
      note: json['note'] as String?,
    );
  }
}

/// ---------------------------------------------------------------
/// PCOS check history -- every result the user has ever gotten from
/// the Detection tab, so trends over time are possible later (e.g.
/// "your estimated likelihood has gone from 40% to 65% over 3
/// months" -- a much more useful signal than a single snapshot).
/// ---------------------------------------------------------------
class PcosCheckResult {
  final DateTime date;
  final String prediction; // 'PCOS Detected' / 'No PCOS Detected'
  final double pcosProbability;
  final String modelUsed;

  const PcosCheckResult({
    required this.date,
    required this.prediction,
    required this.pcosProbability,
    required this.modelUsed,
  });

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'prediction': prediction,
    'pcos_probability': pcosProbability,
    'model_used': modelUsed,
  };

  factory PcosCheckResult.fromJson(Map<String, dynamic> json) {
    return PcosCheckResult(
      date: DateTime.parse(json['date'] as String),
      prediction: json['prediction'] as String,
      pcosProbability: (json['pcos_probability'] as num).toDouble(),
      modelUsed: json['model_used'] as String,
    );
  }
}

/// ---------------------------------------------------------------
/// Eligibility check history -- every time the user runs the
/// Protection > My Plan > Eligibility tool, the conditions they
/// selected and the per-method category results are saved here, so
/// past checks are visible in the Health Diary instead of vanishing
/// the moment the user leaves that screen.
/// ---------------------------------------------------------------
class EligibilityResultEntry {
  final String methodLabel;
  final int category;

  const EligibilityResultEntry({
    required this.methodLabel,
    required this.category,
  });

  Map<String, dynamic> toJson() => {
    'method_label': methodLabel,
    'category': category,
  };

  factory EligibilityResultEntry.fromJson(Map<String, dynamic> json) {
    return EligibilityResultEntry(
      methodLabel: json['method_label'] as String,
      category: json['category'] as int,
    );
  }
}

class EligibilityCheckResult {
  final DateTime date;

  /// Human-readable labels of the conditions the user selected (not raw
  /// backend IDs), so the Diary can display something meaningful without
  /// needing to re-fetch the condition list.
  final List<String> conditions;
  final List<EligibilityResultEntry> results;

  const EligibilityCheckResult({
    required this.date,
    required this.conditions,
    required this.results,
  });

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'conditions': conditions,
    'results': results.map((e) => e.toJson()).toList(),
  };

  factory EligibilityCheckResult.fromJson(Map<String, dynamic> json) {
    return EligibilityCheckResult(
      date: DateTime.parse(json['date'] as String),
      conditions: List<String>.from(json['conditions'] ?? []),
      results: (json['results'] as List<dynamic>? ?? [])
          .map(
            (e) => EligibilityResultEntry.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    );
  }
}

/// ---------------------------------------------------------------
/// Mental health flags -- deliberately lightweight and NON-diagnostic.
/// This app must never claim to diagnose anxiety, depression, or any
/// mental health condition. These fields exist only to let the AI
/// check-in be gentler/more relevant on a return visit (e.g. "last
/// time you mentioned feeling stressed about work -- how's that
/// going?") and to decide when to show a "please consider talking to
/// someone" prompt with real crisis resources, never a label.
/// ---------------------------------------------------------------
class MentalHealthFlags {
  /// Self-reported 1-5 scale, set by the user/AI chat, never inferred
  /// or asserted by the app on its own.
  final int? selfReportedStressLevel;
  final String? notes;
  final DateTime? lastCheckIn;

  const MentalHealthFlags({
    this.selfReportedStressLevel,
    this.notes,
    this.lastCheckIn,
  });

  MentalHealthFlags copyWith({
    int? selfReportedStressLevel,
    String? notes,
    DateTime? lastCheckIn,
  }) {
    return MentalHealthFlags(
      selfReportedStressLevel:
          selfReportedStressLevel ?? this.selfReportedStressLevel,
      notes: notes ?? this.notes,
      lastCheckIn: lastCheckIn ?? this.lastCheckIn,
    );
  }

  Map<String, dynamic> toJson() => {
    'self_reported_stress_level': selfReportedStressLevel,
    'notes': notes,
    'last_check_in': lastCheckIn?.toIso8601String(),
  };

  factory MentalHealthFlags.fromJson(Map<String, dynamic> json) {
    return MentalHealthFlags(
      selfReportedStressLevel: json['self_reported_stress_level'] as int?,
      notes: json['notes'] as String?,
      lastCheckIn: json['last_check_in'] != null
          ? DateTime.parse(json['last_check_in'] as String)
          : null,
    );
  }
}

/// ---------------------------------------------------------------
/// Conversation log -- the raw AI check-in chat history, so the AI
/// agent has memory of past conversations instead of starting fresh
/// every time.
/// ---------------------------------------------------------------
class ConversationEntry {
  final DateTime timestamp;
  final String role; // 'user' or 'assistant'
  final String message;

  /// Groups turns into distinct chat sessions (see AiCheckinScreen's
  /// "Chats" history sheet). Entries saved before this field existed
  /// have no sessionId, so the screen treats those as one combined
  /// "legacy" session rather than losing them.
  final String? sessionId;

  const ConversationEntry({
    required this.timestamp,
    required this.role,
    required this.message,
    this.sessionId,
  });

  Map<String, dynamic> toJson() => {
    'timestamp': timestamp.toIso8601String(),
    'role': role,
    'message': message,
    'session_id': sessionId,
  };

  factory ConversationEntry.fromJson(Map<String, dynamic> json) {
    return ConversationEntry(
      timestamp: DateTime.parse(json['timestamp'] as String),
      role: json['role'] as String,
      message: json['message'] as String,
      sessionId: json['session_id'] as String?,
    );
  }
}
