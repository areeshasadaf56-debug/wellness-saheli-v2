import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// AI Welcome Card
///
/// A beautiful, premium-looking AI companion introduction card that appears
/// at the top of the home dashboard. Designed to make users feel like they
/// have a personal health companion available.
class AiWelcomeCard extends StatelessWidget {
  final String userName;
  final VoidCallback onTap;
  final String? currentPhase;
  final int? currentCycleDay;
  final DateTime? lastCheckIn;
  final int? selfReportedStressLevel;
  final String? latestDiaryMood;

  const AiWelcomeCard({
    super.key,
    required this.userName,
    required this.onTap,
    this.currentPhase,
    this.currentCycleDay,
    this.lastCheckIn,
    this.selfReportedStressLevel,
    this.latestDiaryMood,
  });

  String _getGreetingByTime() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String _getSaheliGreeting() {
    // Personalize using what we actually know about her, most specific
    // signal first -- falls back to a generic time-based line only when
    // there's nothing to go on yet.
    if (selfReportedStressLevel != null && selfReportedStressLevel! >= 4) {
      return 'Things have seemed heavy lately -- want to talk? 💛';
    }

    if (lastCheckIn != null) {
      final daysSince = DateTime.now().difference(lastCheckIn!).inDays;
      if (daysSince >= 7) {
        return 'It\'s been a while -- how have you really been? ✨';
      }
    } else {
      return 'Haven\'t met yet -- I\'d love to get to know you 🌸';
    }

    if (latestDiaryMood != null) {
      final moodWord = latestDiaryMood!
          .split(' ')
          .skip(1)
          .join(' ')
          .toLowerCase();
      if (moodWord == 'sad' ||
          moodWord == 'irritable' ||
          moodWord == 'anxious') {
        return 'Last time you mentioned feeling $moodWord -- how\'s that now?';
      }
    }

    final greeting = _getGreetingByTime();
    final time = greeting.replaceAll('Good ', '').toLowerCase();

    switch (time) {
      case 'morning':
        return 'Starting your day strong? 🌸';
      case 'afternoon':
        return 'How\'s your day been? ✨';
      case 'evening':
        return 'Time to check in? 🌙';
      default:
        return 'How are you feeling today? ✨';
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayName = userName.isNotEmpty ? userName : 'there';
    final greeting = _getGreetingByTime();
    final saheliMsg = _getSaheliGreeting();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary.withValues(alpha: 0.85),
              AppColors.accent.withValues(alpha: 0.7),
            ],
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.2),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Decorative background circles
            Positioned(
              top: -40,
              right: -40,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
            ),
            Positioned(
              bottom: -30,
              left: -30,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.06),
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header: greeting + Saheli info
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$greeting, $displayName 👋',
                              style: AppTextStyles.serif(
                                size: 18,
                                weight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Your personal health companion',
                              style: AppTextStyles.sans(
                                size: 12,
                                weight: FontWeight.w500,
                                color: Colors.white.withValues(alpha: 0.85),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // AI icon/avatar
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.25),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.4),
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.favorite_rounded,
                            size: 28,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Conversation starter
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.chat_bubble_outline_rounded,
                          size: 18,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            saheliMsg,
                            style: AppTextStyles.sans(
                              size: 14,
                              weight: FontWeight.w500,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // CTA Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Talk to Saheli',
                        style: AppTextStyles.sans(
                          size: 14,
                          weight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Cycle phase indicator (if available)
                  if (currentPhase != null && currentCycleDay != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getPhaseIcon(currentPhase!),
                            size: 14,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Day $currentCycleDay • $currentPhase',
                            style: AppTextStyles.sans(
                              size: 11,
                              weight: FontWeight.w500,
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getPhaseIcon(String phase) {
    switch (phase) {
      case 'Menstrual':
        return Icons.water_drop;
      case 'Follicular':
        return Icons.local_florist;
      case 'Ovulation':
        return Icons.wb_sunny;
      case 'Luteal':
        return Icons.nightlight_round;
      default:
        return Icons.info_outline;
    }
  }
}
