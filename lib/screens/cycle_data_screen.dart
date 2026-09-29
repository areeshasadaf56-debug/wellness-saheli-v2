import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cycle_provider.dart';
import '../theme/app_theme.dart';

class CycleDataScreen extends StatefulWidget {
  const CycleDataScreen({super.key});

  @override
  State<CycleDataScreen> createState() => _CycleDataScreenState();
}

class _CycleDataScreenState extends State<CycleDataScreen> {
  late int _cycleLength;
  late int _periodDuration;
  late DateTime _lastPeriodStart;

  @override
  void initState() {
    super.initState();
    final cycle = context.read<CycleProvider>();
    _cycleLength = cycle.cycleLength;
    _periodDuration = cycle.periodDuration;
    _lastPeriodStart = cycle.cycleData.lastPeriodStart;
  }

  String _formatDate(DateTime date) {
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
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Future<void> _pickLastPeriodStart() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _lastPeriodStart,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.primary,
              surface: AppColors.surface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && mounted) {
      setState(() => _lastPeriodStart = picked);
      context.read<CycleProvider>().updateLastPeriodStart(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _backHeader(context, 'Cycle Data'),
              const SizedBox(height: 20),
              _sectionHeading('LAST PERIOD'),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: _pickLastPeriodStart,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Row(
                    children: [
                      const Text('🩸', style: TextStyle(fontSize: 18)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Start date',
                          style: AppTextStyles.sans(
                            size: 14,
                            weight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        _formatDate(_lastPeriodStart),
                        style: AppTextStyles.sans(
                          size: 13,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.chevron_right,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _sectionHeading('CYCLE LENGTH'),
              const SizedBox(height: 10),
              _stepperCard(
                label: 'Average cycle length',
                value: _cycleLength,
                unit: 'days',
                min: 21,
                max: 45,
                onChanged: (val) {
                  setState(() => _cycleLength = val);
                  context.read<CycleProvider>().updateCycleLength(val);
                },
              ),
              const SizedBox(height: 20),
              _sectionHeading('PERIOD DURATION'),
              const SizedBox(height: 10),
              _stepperCard(
                label: 'Average period length',
                value: _periodDuration,
                unit: 'days',
                min: 2,
                max: 10,
                onChanged: (val) {
                  setState(() => _periodDuration = val);
                  context.read<CycleProvider>().updatePeriodDuration(val);
                },
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.ovulationTeal.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.ovulationTeal.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Text('💡', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Changes here update your predictions immediately across the app.',
                        style: AppTextStyles.sans(
                          size: 11,
                          color: AppColors.textSecondary,
                        ).copyWith(height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _backHeader(BuildContext context, String title) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: const Icon(
              Icons.arrow_back,
              size: 18,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(title, style: AppTextStyles.serif(size: 20)),
      ],
    );
  }

  Widget _sectionHeading(String text) {
    return Text(
      text,
      style: AppTextStyles.sans(
        size: 11,
        weight: FontWeight.w600,
        color: AppColors.textSecondary,
      ),
    );
  }

  Widget _stepperCard({
    required String label,
    required int value,
    required String unit,
    required int min,
    required int max,
    required ValueChanged<int> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.sans(size: 14, weight: FontWeight.w600),
            ),
          ),
          _stepperButton(
            icon: Icons.remove,
            onTap: value > min ? () => onChanged(value - 1) : null,
          ),
          SizedBox(
            width: 56,
            child: Text(
              '$value $unit',
              textAlign: TextAlign.center,
              style: AppTextStyles.sans(
                size: 13,
                color: AppColors.primary,
                weight: FontWeight.w600,
              ),
            ),
          ),
          _stepperButton(
            icon: Icons.add,
            onTap: value < max ? () => onChanged(value + 1) : null,
          ),
        ],
      ),
    );
  }

  Widget _stepperButton({
    required IconData icon,
    required VoidCallback? onTap,
  }) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: enabled
              ? AppColors.primary.withValues(alpha: 0.15)
              : AppColors.cardBorder.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 16,
          color: enabled ? AppColors.primary : AppColors.textSecondary,
        ),
      ),
    );
  }
}
