import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/health_profile.dart';
import '../services/health_profile_service.dart';

const List<String> _moodOptions = [
  '😊 Happy',
  '😐 Neutral',
  '😢 Sad',
  '😠 Irritable',
  '😴 Tired',
  '😰 Anxious',
];

const List<String> _symptomOptions = [
  'Cramps',
  'Headache',
  'Bloating',
  'Fatigue',
  'Nausea',
  'Back Pain',
];

/// A free-text journal entry dialog (section 13 of the product brief).
/// Distinct from the wellness check-in dialog: this is an open-ended
/// note the person writes herself, not a structured 1-5 stress log.
/// Saved as a DiaryEntry via HealthProfileService, same pattern used
/// everywhere else in the app.
Future<void> showDiaryEntryDialog(
  BuildContext context, {
  required VoidCallback onSaved,
}) async {
  final textController = TextEditingController();
  String? selectedMood;
  final Set<String> selectedSymptoms = {};

  final saved = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          return AlertDialog(
            backgroundColor: AppColors.surface,
            title: Text(
              'Write in your diary',
              style: AppTextStyles.sans(size: 16, weight: FontWeight.w600),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Write freely -- this is just for you.',
                    style: AppTextStyles.sans(
                      size: 12,
                      color: AppColors.textSecondary,
                    ).copyWith(height: 1.4),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: textController,
                    maxLines: 5,
                    style: AppTextStyles.sans(size: 13),
                    decoration: InputDecoration(
                      hintText: "What's on your mind today?",
                      hintStyle: AppTextStyles.sans(
                        size: 12,
                        color: AppColors.textSecondary,
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: AppColors.cardBorder),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: AppColors.primary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'MOOD (OPTIONAL)',
                    style: AppTextStyles.sans(
                      size: 10,
                      weight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _moodOptions.map((m) {
                      final isSelected = selectedMood == m;
                      return GestureDetector(
                        onTap: () => setDialogState(
                          () => selectedMood = isSelected ? null : m,
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary.withValues(alpha: 0.15)
                                : AppColors.background,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.cardBorder,
                            ),
                          ),
                          child: Text(m, style: AppTextStyles.sans(size: 12)),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'SYMPTOMS (OPTIONAL)',
                    style: AppTextStyles.sans(
                      size: 10,
                      weight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _symptomOptions.map((s) {
                      final isSelected = selectedSymptoms.contains(s);
                      return GestureDetector(
                        onTap: () => setDialogState(() {
                          if (isSelected) {
                            selectedSymptoms.remove(s);
                          } else {
                            selectedSymptoms.add(s);
                          }
                        }),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.symptomOrange.withValues(
                                    alpha: 0.15,
                                  )
                                : AppColors.background,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.symptomOrange
                                  : AppColors.cardBorder,
                            ),
                          ),
                          child: Text(s, style: AppTextStyles.sans(size: 12)),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: textController.text.trim().isEmpty
                    ? null
                    : () => Navigator.pop(dialogContext, true),
                child: Text(
                  'Save',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          );
        },
      );
    },
  );

  final text = textController.text.trim();
  if (saved != true || text.isEmpty) return;

  final entry = DiaryEntry(
    date: DateTime.now(),
    text: text,
    mood: selectedMood,
    symptomTags: selectedSymptoms.toList(),
  );

  await HealthProfileService().updateProfile((p) {
    final updated = List<DiaryEntry>.from(p.diaryEntries)..add(entry);
    return p.copyWith(diaryEntries: updated);
  });

  onSaved();

  if (context.mounted) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Saved to your diary')));
  }
}
