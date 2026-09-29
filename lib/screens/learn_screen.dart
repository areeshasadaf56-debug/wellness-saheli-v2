import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class QAItem {
  final String question;
  final String answer;
  const QAItem(this.question, this.answer);
}

class TopicItem {
  final String emoji;
  final String title;
  final String subtitle;
  final Color color;
  final List<QAItem> qa;

  const TopicItem({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.qa,
  });
}

class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});

  static final List<TopicItem> _topics = [
    TopicItem(
      emoji: '⚕️',
      title: 'Anatomy',
      subtitle: 'Reproductive system basics',
      color: AppColors.accent,
      qa: const [
        QAItem(
          'What are the main internal reproductive organs?',
          'The ovaries produce eggs and hormones. The fallopian tubes carry eggs from the ovaries to the uterus. The uterus is where a fetus develops. The cervix connects the uterus to the vagina.',
        ),
        QAItem(
          'What does the vagina actually do?',
          'The vagina is the muscular canal connecting the cervix to the outside of the body. It serves as the birth canal, the pathway for menstrual blood, and the entry point for sexual intercourse. It is self-cleaning and produces natural discharge.',
        ),
        QAItem(
          'What is the hymen?',
          'The hymen is a thin membrane that partially covers the vaginal opening. It varies widely in shape and size. It does not indicate virginity and may stretch or tear through exercise, tampon use, or sexual activity.',
        ),
      ],
    ),
    TopicItem(
      emoji: '🧬',
      title: 'Hormones',
      subtitle: 'How they affect your cycle',
      color: AppColors.primary,
      qa: const [
        QAItem(
          'What hormones control my cycle?',
          'Estrogen and progesterone rise and fall through the month, while FSH and LH from the pituitary gland trigger egg development and ovulation. Together they drive every phase of the cycle.',
        ),
        QAItem(
          'Why do I feel different in each phase?',
          'Estrogen tends to lift energy and mood in the first half of the cycle, while progesterone in the second half can cause fatigue, bloating, and mood changes as it eventually drops before your period.',
        ),
        QAItem(
          'Can hormone levels be tested?',
          'Yes. Blood tests can measure estrogen, progesterone, LH, FSH, and thyroid hormones, which are often checked together when investigating irregular cycles.',
        ),
      ],
    ),
    TopicItem(
      emoji: '🛡️',
      title: 'STIs',
      subtitle: 'Common infections & prevention',
      color: AppColors.textPrimary,
      qa: const [
        QAItem(
          'How are STIs usually transmitted?',
          'Most STIs spread through vaginal, anal, or oral sex, and some, like herpes and HPV, can spread through skin-to-skin contact even without penetration.',
        ),
        QAItem(
          'Can you have an STI with no symptoms?',
          'Yes. Many STIs, including chlamydia and gonorrhea, often cause no symptoms at all, which is why regular screening matters even if you feel fine.',
        ),
        QAItem(
          'How can risk be reduced?',
          'Condoms significantly lower the risk of most STIs, and regular testing with new or multiple partners helps catch infections early, when they are easiest to treat.',
        ),
      ],
    ),
    TopicItem(
      emoji: '🩸',
      title: 'Menstruation',
      subtitle: "What's normal, what's not",
      color: AppColors.periodRed,
      qa: const [
        QAItem(
          'What counts as a "normal" cycle?',
          "A typical cycle ranges from 21 to 35 days, with bleeding lasting 2 to 7 days. Some variation month to month is normal and doesn't necessarily indicate a problem.",
        ),
        QAItem(
          'When is bleeding considered too heavy?',
          'Soaking through a pad or tampon every hour for several hours, passing large clots, or bleeding for more than 7 days can indicate heavy menstrual bleeding worth discussing with a doctor.',
        ),
        QAItem(
          'Is period pain always normal?',
          "Mild cramping is common, but pain that stops you from daily activities, doesn't respond to over-the-counter painkillers, or worsens over time can be a sign of an underlying condition like endometriosis.",
        ),
      ],
    ),
    TopicItem(
      emoji: '❌',
      title: 'Myths',
      subtitle: 'Debunking common myths',
      color: AppColors.primary,
      qa: const [
        QAItem(
          "Myth: You can't get pregnant during your period.",
          'False. Sperm can survive up to 5 days, so if you ovulate early or have a short cycle, sex during your period can still lead to pregnancy.',
        ),
        QAItem(
          'Myth: Irregular periods always mean something is wrong.',
          "Not necessarily. Cycles can vary due to stress, travel, or weight changes. Consistently irregular cycles over several months are what's worth checking with a doctor.",
        ),
        QAItem(
          'Myth: You lose a lot of blood during your period.',
          'Most people lose only 2 to 3 tablespoons of blood across an entire period, even though it can feel like more.',
        ),
      ],
    ),
  ];

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
            _sectionHeading('TOPICS'),
            const SizedBox(height: 12),
            _buildTopicGrid(context),
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

  Widget _buildTopicGrid(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _topics.map((topic) {
        return SizedBox(
          width: (MediaQuery.of(context).size.width - 20 * 2 - 12) / 2,
          child: _topicCard(context, topic),
        );
      }).toList(),
    );
  }

  Widget _topicCard(BuildContext context, TopicItem topic) {
    return GestureDetector(
      onTap: () => _showTopicSheet(context, topic),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          children: [
            Text(topic.emoji, style: const TextStyle(fontSize: 26)),
            const SizedBox(height: 10),
            Text(
              topic.title,
              style: AppTextStyles.sans(
                size: 13,
                weight: FontWeight.w700,
                color: topic.color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              topic.subtitle,
              textAlign: TextAlign.center,
              style: AppTextStyles.sans(
                size: 10,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTopicSheet(BuildContext context, TopicItem topic) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(sheetContext).size.height * 0.85,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        topic.title == 'Anatomy'
                            ? 'Reproductive Anatomy'
                            : topic.title,
                        style: AppTextStyles.serif(size: 18),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(sheetContext),
                        child: Icon(
                          Icons.close,
                          size: 20,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  for (int i = 0; i < topic.qa.length; i++) ...[
                    _qaBlock(topic.qa[i], topic.color),
                    if (i != topic.qa.length - 1)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Divider(height: 1, color: AppColors.cardBorder),
                      ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _qaBlock(QAItem qa, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          qa.question,
          style: AppTextStyles.sans(
            size: 13,
            weight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          qa.answer,
          style: AppTextStyles.sans(
            size: 12,
            color: AppColors.textSecondary,
          ).copyWith(height: 1.5),
        ),
      ],
    );
  }
}
