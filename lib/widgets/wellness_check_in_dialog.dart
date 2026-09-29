import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/health_profile.dart';
import '../services/health_profile_service.dart';

/// A short, self-report-only check-in. This never labels or diagnoses —
/// it just stores what the person says about themselves, on a 1-5 scale
/// they choose, plus an optional free-text note. Nothing here is
/// inferred or asserted by the app.
///
/// Shared across screens (Diary, PCOS results, etc.) so there's one
/// dialog implementation and one save path.
Future<void> showWellnessCheckInDialog(
  BuildContext context, {
  required HealthProfile current,
  required VoidCallback onSaved,
}) async {
  final service = HealthProfileService();
  double stress = (current.mentalHealth.selfReportedStressLevel ?? 3)
      .toDouble()
      .clamp(1, 5);
  final notesController = TextEditingController(
    text: current.mentalHealth.notes ?? '',
  );

  final saved = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          return AlertDialog(
            backgroundColor: AppColors.surface,
            title: Text(
              'How are you feeling?',
              style: AppTextStyles.sans(size: 16, weight: FontWeight.w600),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'This is just for you — a quick, private note to yourself. Nothing here is a diagnosis.',
                  style: AppTextStyles.sans(
                    size: 12,
                    color: AppColors.textSecondary,
                  ).copyWith(height: 1.4),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Stress level',
                      style: AppTextStyles.sans(
                        size: 13,
                        weight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${stress.round()} / 5',
                      style: AppTextStyles.sans(
                        size: 13,
                        weight: FontWeight.w700,
                        color: AppColors.moodYellow,
                      ),
                    ),
                  ],
                ),
                SliderTheme(
                  data: SliderTheme.of(dialogContext).copyWith(
                    activeTrackColor: AppColors.moodYellow,
                    inactiveTrackColor: AppColors.cardBorder,
                    thumbColor: AppColors.moodYellow,
                    overlayColor: AppColors.moodYellow.withValues(alpha: 0.15),
                    trackHeight: 4,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 10,
                    ),
                  ),
                  child: Slider(
                    value: stress,
                    min: 1,
                    max: 5,
                    divisions: 4,
                    onChanged: (v) => setDialogState(() => stress = v),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: notesController,
                  maxLines: 3,
                  style: AppTextStyles.sans(size: 13),
                  decoration: InputDecoration(
                    hintText: 'Anything on your mind? (optional)',
                    hintStyle: AppTextStyles.sans(
                      size: 12,
                      color: AppColors.textSecondary,
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.cardBorder),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.moodYellow),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: Text(
                  'Save',
                  style: TextStyle(
                    color: AppColors.moodYellow,
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

  if (saved != true) return;

  final notes = notesController.text.trim();
  await service.updateProfile((p) {
    return p.copyWith(
      mentalHealth: p.mentalHealth.copyWith(
        selfReportedStressLevel: stress.round(),
        notes: notes.isEmpty ? p.mentalHealth.notes : notes,
        lastCheckIn: DateTime.now(),
      ),
    );
  });

  if (context.mounted) {
    onSaved();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Check-in saved to your diary')),
    );
  }
}
