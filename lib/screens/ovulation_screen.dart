import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/cycle_provider.dart';

class OvulationScreen extends StatelessWidget {
  const OvulationScreen({super.key});

  String _formattedDate() {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
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
    final now = DateTime.now();
    return '${weekdays[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';
  }

  @override
  Widget build(BuildContext context) {
    final cycle = context.watch<CycleProvider>();
    final day = cycle.currentCycleDay;
    final cycleLength = cycle.cycleLength;
    final ovulationDay = (cycleLength / 2).floor();
    final periodDuration = cycle.periodDuration;

    // Fertility level 0.0 - 1.0, peaks around ovulation day
    final distanceFromOvulation = (day - ovulationDay).abs();
    final fertilityLevel = (1 - (distanceFromOvulation / (cycleLength / 2)))
        .clamp(0.0, 1.0);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _sectionLabel('FERTILITY WINDOW'),
            const SizedBox(height: 10),
            _buildFertilityMeter(fertilityLevel),
            const SizedBox(height: 16),
            _buildStatCards(cycle, ovulationDay),
            const SizedBox(height: 24),
            _sectionLabel('CYCLE PHASES'),
            const SizedBox(height: 12),
            _phaseRow(
              title: 'Menstrual',
              days: 'Days 1–$periodDuration',
              description:
                  'The uterine lining, built up over the previous cycle, breaks down and sheds through the vagina as your period. Both estrogen and progesterone are at their lowest point of the entire cycle, which is why fatigue, low mood, and low motivation are common in these first few days. Prostaglandins trigger the uterus to contract, causing cramping that can radiate to the lower back and thighs. Bleeding is typically heaviest on days 1–2 and tapers off after. Fertility is essentially at zero right now since no egg is developing yet. Iron-rich foods, warmth on the abdomen, and gentle movement like walking can ease symptoms.',
              isActive: day <= periodDuration,
              color: AppColors.periodRed,
            ),
            _phaseRow(
              title: 'Follicular',
              days: 'Days 1–$ovulationDay',
              description:
                  'This phase technically overlaps with menstruation but continues after bleeding stops. The pituitary gland releases FSH (follicle-stimulating hormone), prompting a group of follicles in the ovaries to grow, each containing an immature egg. As they develop, estrogen rises steadily, which is what causes energy, mood, and mental clarity to noticeably improve as this phase progresses. The uterine lining begins rebuilding itself in preparation for a possible pregnancy. Toward the end of this phase, one dominant follicle outpaces the rest and prepares to release its egg, and fertility climbs sharply in the final few days leading into ovulation.',
              isActive: day > periodDuration && day <= ovulationDay,
              color: AppColors.symptomOrange,
            ),
            _phaseRow(
              title: 'Ovulation',
              days: 'Day $ovulationDay (avg)',
              description:
                  'A sharp surge in luteinizing hormone (LH), triggered by peak estrogen, causes the dominant follicle to rupture and release its egg into the fallopian tube. The egg itself only survives 12–24 hours, making this technically the single most fertile day of the cycle. However, because sperm can survive in the reproductive tract for 3–5 days, the fertile window effectively spans the 5 days before ovulation through the day itself — about 6 days total. Many people notice physical signs here: clear, stretchy cervical mucus (similar to raw egg white), a slight rise in basal body temperature, mild one-sided pelvic twinges, and a boost in energy, libido, and confidence as estrogen and testosterone both peak.',
              isActive: day == ovulationDay || day == ovulationDay + 1,
              color: AppColors.ovulationTeal,
            ),
            _phaseRow(
              title: 'Luteal',
              days: 'Days ${ovulationDay + 2}–$cycleLength',
              description:
                  'After the egg is released, the ruptured follicle transforms into a temporary structure called the corpus luteum, which produces progesterone to thicken and stabilize the uterine lining in case a fertilized egg implants. If pregnancy doesn\'t occur, the corpus luteum breaks down around 10–14 days later, causing both estrogen and progesterone to fall sharply — this hormonal drop is what triggers PMS symptoms like bloating, breast tenderness, irritability, food cravings, and low mood in the days before your period. Fertility declines steadily through this phase since ovulation has already happened. Once hormone levels bottom out, the uterine lining sheds and the cycle begins again.',
              isActive: day > ovulationDay + 1,
              color: AppColors.primary,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: AppTextStyles.sans(
        size: 11,
        weight: FontWeight.w600,
        color: AppColors.textSecondary,
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Wellness ',
                style: AppTextStyles.serif(
                  size: 22,
                  weight: FontWeight.w600,
                  color: AppColors.accent,
                ).copyWith(fontStyle: FontStyle.italic),
              ),
              TextSpan(
                text: 'Saheli',
                style: AppTextStyles.serif(
                  size: 22,
                  weight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        Text(
          _formattedDate(),
          style: AppTextStyles.sans(size: 11, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildFertilityMeter(double level) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CURRENT FERTILITY LEVEL',
            style: AppTextStyles.sans(
              size: 10,
              weight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: LinearProgressIndicator(
              value: level,
              minHeight: 8,
              backgroundColor: AppColors.cardBorder,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.ovulationTeal,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Low',
                style: AppTextStyles.sans(
                  size: 10,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                'Peak Fertile',
                style: AppTextStyles.sans(
                  size: 10,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCards(CycleProvider cycle, int ovulationDay) {
    final day = cycle.currentCycleDay;
    final daysToOvulation = ovulationDay - day;

    final ovulationDate = DateTime.now().add(Duration(days: daysToOvulation));
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
    final ovulationDateLabel =
        '${months[ovulationDate.month - 1]} ${ovulationDate.day}';

    final fertileWindowDays = daysToOvulation.abs() <= 5
        ? (5 - daysToOvulation.abs() + 1).clamp(1, 6)
        : 6;
    final fertileWindowValue = daysToOvulation.abs() <= 5
        ? 'Active'
        : '$fertileWindowDays';
    final fertileWindowSub = daysToOvulation.abs() <= 5
        ? 'Fertile now'
        : 'days this cycle';

    return Row(
      children: [
        Expanded(
          child: _statCard(
            label: 'OVULATION DAY',
            value: daysToOvulation > 0
                ? 'In ${daysToOvulation}d'
                : (daysToOvulation == 0 ? 'Today' : 'Passed'),
            subLabel: ovulationDateLabel,
            valueColor: AppColors.ovulationTeal,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statCard(
            label: 'FERTILE WINDOW',
            value: fertileWindowValue,
            subLabel: fertileWindowSub,
            valueColor: AppColors.symptomOrange,
          ),
        ),
      ],
    );
  }

  Widget _statCard({
    required String label,
    required String value,
    required String subLabel,
    required Color valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.sans(
              size: 10,
              weight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Text(value, style: AppTextStyles.serif(size: 20, color: valueColor)),
          const SizedBox(height: 2),
          Text(
            subLabel,
            style: AppTextStyles.sans(size: 11, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _phaseRow({
    required String title,
    required String days,
    required String description,
    required bool isActive,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: EdgeInsets.all(
        isActive ? 14 : 0,
      ).copyWith(bottom: isActive ? 14 : 14),
      decoration: BoxDecoration(
        color: isActive ? color.withValues(alpha: 0.08) : null,
        borderRadius: BorderRadius.circular(12),
        border: isActive
            ? Border.all(color: color.withValues(alpha: 0.5), width: 1)
            : const Border(
                bottom: BorderSide(color: AppColors.cardBorder, width: 1),
              ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 5),
            width: 9,
            height: 9,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.6),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.sans(
                        size: 14,
                        weight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                    if (isActive) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'CURRENT PHASE',
                          style: AppTextStyles.sans(
                            size: 8,
                            weight: FontWeight.w700,
                            color: color,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  days,
                  style: AppTextStyles.sans(
                    size: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: AppTextStyles.sans(
                    size: 12,
                    color: isActive
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                  ).copyWith(height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
