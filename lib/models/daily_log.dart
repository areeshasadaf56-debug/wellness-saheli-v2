class DailyLog {
  bool isPeriodDay;
  String? mood;
  List<String> symptoms;
  String? flowIntensity;

  DailyLog({
    this.isPeriodDay = false,
    this.mood,
    this.symptoms = const [],
    this.flowIntensity,
  });

  Map<String, dynamic> toJson() => {
    'isPeriodDay': isPeriodDay,
    'mood': mood,
    'symptoms': symptoms,
    'flowIntensity': flowIntensity,
  };

  factory DailyLog.fromJson(Map<String, dynamic> json) {
    return DailyLog(
      isPeriodDay: json['isPeriodDay'] ?? false,
      mood: json['mood'],
      symptoms: List<String>.from(json['symptoms'] ?? []),
      flowIntensity: json['flowIntensity'],
    );
  }
}
