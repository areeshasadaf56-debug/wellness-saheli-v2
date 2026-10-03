import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/cycle_provider.dart';

class MonthCalendar extends StatefulWidget {
  const MonthCalendar({super.key});

  @override
  State<MonthCalendar> createState() => _MonthCalendarState();
}

class _MonthCalendarState extends State<MonthCalendar> {
  final ScrollController _scrollController = ScrollController();
  late DateTime _labelDate;

  // Wide range so the user can freely swipe back/forward through months.
  static const int _daysBefore = 180;
  static const int _daysAfter = 180;
  static const double _cellWidth = 44;
  static const double _cellSpacing = 8;

  static const _monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  @override
  void initState() {
    super.initState();
    _labelDate = DateTime.now();
    _scrollController.addListener(_updateLabel);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        // Land on today, with a couple of days of context to the left
        final offset = (_daysBefore - 2) * (_cellWidth + _cellSpacing);
        _scrollController.jumpTo(offset);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateLabel);
    _scrollController.dispose();
    super.dispose();
  }

  void _updateLabel() {
    if (!_scrollController.hasClients) return;
    final today = DateTime.now();
    final todayNormalized = DateTime(today.year, today.month, today.day);
    final index = (_scrollController.offset / (_cellWidth + _cellSpacing))
        .round();
    final visibleDate = todayNormalized.add(
      Duration(days: index - _daysBefore),
    );

    if (visibleDate.month != _labelDate.month ||
        visibleDate.year != _labelDate.year) {
      setState(() {
        _labelDate = visibleDate;
      });
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _isPredictedPeriodDay(DateTime date, CycleProvider cycle) {
    final start = cycle.cycleData.lastPeriodStart;
    final cycleLength = cycle.cycleLength;
    final periodDuration = cycle.periodDuration;

    final normalizedDate = DateTime(date.year, date.month, date.day);
    final normalizedStart = DateTime(start.year, start.month, start.day);

    int daysSince = normalizedDate.difference(normalizedStart).inDays;
    int cyclePos = daysSince % cycleLength;
    if (cyclePos < 0) cyclePos += cycleLength;

    return cyclePos < periodDuration;
  }

  @override
  Widget build(BuildContext context) {
    final cycle = context.watch<CycleProvider>();
    final today = DateTime.now();
    final todayNormalized = DateTime(today.year, today.month, today.day);
    final weekdayLabels = ['MO', 'TU', 'WE', 'TH', 'FR', 'SA', 'SU'];

    final totalDays = _daysBefore + _daysAfter;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Live month label — updates as you scroll the strip
        Text(
          '${_monthNames[_labelDate.month - 1]} ${_labelDate.year}',
          style: AppTextStyles.sans(
            size: 12,
            weight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 68,
          child: ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: totalDays,
            itemBuilder: (context, index) {
              final date = todayNormalized.add(
                Duration(days: index - _daysBefore),
              );
              final isToday = _isSameDay(date, todayNormalized);
              final isPeriodDay = _isPredictedPeriodDay(date, cycle);

              Color bgColor = AppColors.surface;
              Color borderColor = AppColors.cardBorder;

              if (isPeriodDay) {
                bgColor = AppColors.periodRed.withValues(alpha: 0.18);
                borderColor = AppColors.periodRed.withValues(alpha: 0.4);
              }
              if (isToday) {
                borderColor = AppColors.periodRed;
              }

              return GestureDetector(
                onTap: () {
                  context.read<CycleProvider>().selectPeriodDate(date);
                },
                child: Container(
                  width: _cellWidth,
                  margin: const EdgeInsets.only(right: _cellSpacing),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: borderColor,
                      width: isToday ? 1.5 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        weekdayLabels[date.weekday - 1],
                        style: AppTextStyles.sans(
                          size: 9,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${date.day}',
                        style: AppTextStyles.sans(
                          size: 15,
                          weight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      if (isPeriodDay)
                        Container(
                          width: 5,
                          height: 5,
                          decoration: const BoxDecoration(
                            color: AppColors.periodRed, // solid, fully opaque
                            shape: BoxShape.circle,
                          ),
                        )
                      else
                        const SizedBox(height: 5),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
