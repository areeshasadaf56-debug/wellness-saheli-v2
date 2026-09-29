class AiResponse {
  final String reply;
  final Map<String, dynamic>? profileUpdates;
  final String? suggestedTab;
  final String? suggestedTabReason;
  final bool crisisConcern;
  final bool medicalEmergencyConcern;

  AiResponse({
    required this.reply,
    this.profileUpdates,
    this.suggestedTab,
    this.suggestedTabReason,
    this.crisisConcern = false,
    this.medicalEmergencyConcern = false,
  });

  factory AiResponse.fromJson(Map<String, dynamic> json) {
    return AiResponse(
      reply: json['reply'] as String? ?? '',
      profileUpdates: json['profile_updates'] as Map<String, dynamic>?,
      suggestedTab: json['suggested_tab'] as String?,
      suggestedTabReason: json['suggested_tab_reason'] as String?,
      crisisConcern: json['crisis_concern'] as bool? ?? false,
      medicalEmergencyConcern:
          json['medical_emergency_concern'] as bool? ?? false,
    );
  }
}
