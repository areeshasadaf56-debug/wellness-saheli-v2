import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'pcos_screen.dart' show PcosCard, PcosLine, PcosTag;

class EndoScreen extends StatefulWidget {
  const EndoScreen({super.key});

  @override
  State<EndoScreen> createState() => _EndoScreenState();
}

class _EndoScreenState extends State<EndoScreen> {
  int _activeTab = 0;

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
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _buildTabs(),
            const SizedBox(height: 20),
            if (_activeTab == 0)
              ..._buildInformationTab()
            else
              _buildDetectionTab(),
            const SizedBox(height: 16),
          ],
        ),
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

  Widget _buildTabs() {
    return Row(
      children: [
        Expanded(
          child: _tabButton('ℹ️', 'Information', 0, AppColors.ovulationTeal),
        ),
        const SizedBox(width: 10),
        Expanded(child: _tabButton('🩺', 'Detection', 1, AppColors.primary)),
      ],
    );
  }

  Widget _tabButton(String emoji, String label, int index, Color activeColor) {
    final isActive = _activeTab == index;
    return GestureDetector(
      onTap: () => setState(() => _activeTab = index),
      child: Container(
        height: 46,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isActive
              ? activeColor.withValues(alpha: 0.18)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive
                ? activeColor.withValues(alpha: 0.6)
                : AppColors.cardBorder,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.sans(
                size: 13,
                weight: FontWeight.w600,
                color: isActive
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildInformationTab() {
    return [
      _heroCard(),
      const SizedBox(height: 24),
      _sectionLabel('WHAT IS ENDOMETRIOSIS?'),
      const SizedBox(height: 12),
      PcosCard(
        emoji: '💡',
        badgeColor: AppColors.moodYellow,
        title: 'Overview',
        subtitle: '',
        initiallyExpanded: true,
        lines: const [
          PcosLine(
            text:
                'Endometriosis occurs when endometrial-like tissue implants on organs outside the uterus — most commonly the ovaries, fallopian tubes, and pelvic lining. This tissue responds to hormonal changes just like the uterine lining, causing inflammation, scarring, and pain.',
          ),
        ],
      ),
      const SizedBox(height: 20),
      _sectionLabel('SYMPTOMS'),
      const SizedBox(height: 12),
      PcosCard(
        emoji: '🩺',
        badgeColor: AppColors.periodRed,
        title: 'Common Symptoms',
        subtitle: 'How endometriosis presents',
        initiallyExpanded: true,
        lines: const [
          PcosLine(
            boldLead: 'Dysmenorrhoea',
            text:
                'Severely painful periods that worsen over time, often not relieved by standard painkillers.',
          ),
          PcosLine(
            boldLead: 'Dyspareunia',
            text:
                'Pain during or after sexual intercourse, particularly deep penetration.',
          ),
          PcosLine(
            boldLead: 'Chronic pelvic pain',
            text: 'Persistent lower abdominal pain outside of periods.',
          ),
          PcosLine(
            boldLead: 'Bowel & bladder symptoms',
            text:
                'Pain during bowel movements or urination, especially during menstruation.',
          ),
          PcosLine(
            boldLead: 'Infertility',
            text:
                'Present in up to 50% of people with endometriosis, often the first presenting complaint.',
          ),
        ],
        tags: const [
          PcosTag('Severe period pain', AppColors.symptomOrange),
          PcosTag('Painful sex', AppColors.symptomOrange),
          PcosTag('Chronic pelvic pain', AppColors.symptomOrange),
          PcosTag('Infertility', AppColors.periodRed),
        ],
      ),
      const SizedBox(height: 20),
      _sectionLabel('DIAGNOSIS'),
      const SizedBox(height: 12),
      PcosCard(
        emoji: '🔬',
        badgeColor: AppColors.ovulationTeal,
        title: 'Stages & Diagnosis',
        subtitle: 'Classification and how it is confirmed',
        initiallyExpanded: true,
        lines: const [
          PcosLine(
            text:
                'Endometriosis is staged I–IV (minimal to severe) based on the extent and location of lesions. Staging does not always correlate with symptom severity — Stage I can cause intense pain while Stage IV may be asymptomatic.',
          ),
          PcosLine(
            boldLead: 'Definitive diagnosis',
            text:
                'requires laparoscopy (keyhole surgery) with biopsy. Ultrasound and MRI can detect endometriomas (ovarian cysts) and deep infiltrating disease but cannot confirm all forms.',
          ),
        ],
        tags: const [
          PcosTag('Laparoscopy (gold standard)', AppColors.ovulationTeal),
          PcosTag('Ultrasound', AppColors.moodYellow),
          PcosTag('MRI', AppColors.symptomOrange),
        ],
      ),
      const SizedBox(height: 20),
      _sectionLabel('TREATMENT'),
      const SizedBox(height: 12),
      PcosCard(
        emoji: '💊',
        badgeColor: AppColors.periodRed,
        title: 'Medical & Surgical Options',
        subtitle: 'Managing pain and fertility',
        initiallyExpanded: true,
        lines: const [
          PcosLine(
            boldLead: 'Hormonal therapies',
            text:
                'The combined OCP, progestogens, GnRH agonists, and the levonorgestrel IUD all suppress menstruation and reduce lesion activity.',
          ),
          PcosLine(
            boldLead: 'Pain management',
            text:
                'NSAIDs (ibuprofen, naproxen) taken at the start of a period can reduce prostaglandin-driven pain.',
          ),
          PcosLine(
            boldLead: 'Surgery',
            text:
                'Laparoscopic excision removes lesions and adhesions, providing significant pain relief. Recurrence rates vary. Hysterectomy is a last resort and does not guarantee cure if ovaries are retained.',
          ),
        ],
        tags: const [
          PcosTag('OCP / progestogens', AppColors.ovulationTeal),
          PcosTag('Excision surgery', AppColors.primary),
          PcosTag('GnRH agonists', AppColors.symptomOrange),
          PcosTag('NSAIDs', AppColors.periodRed),
        ],
      ),
    ];
  }

  Widget _buildDetectionTab() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withValues(alpha: 0.15),
            ),
            child: const Center(
              child: Text('🩺', style: TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Symptom Checker',
            style: AppTextStyles.sans(size: 14, weight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            'Answer a few quick questions about your pain and cycle to see if it may be worth discussing endometriosis with a doctor.',
            textAlign: TextAlign.center,
            style: AppTextStyles.sans(size: 12, color: AppColors.textSecondary),
          ),
        ],
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

  Widget _heroCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.ovulationTeal.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: const Center(
              child: Text('🔭', style: TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(height: 14),
          Text('Endometriosis Guide', style: AppTextStyles.serif(size: 19)),
          const SizedBox(height: 8),
          Text(
            'A condition where tissue similar to the uterine lining grows outside the uterus, affecting roughly 1 in 10 people with ovaries.',
            textAlign: TextAlign.center,
            style: AppTextStyles.sans(
              size: 12,
              color: AppColors.textSecondary,
            ).copyWith(height: 1.5),
          ),
        ],
      ),
    );
  }
}
