import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PcosLine {
  final String? boldLead;
  final String text;
  final String? number;

  const PcosLine({this.boldLead, required this.text, this.number});
}

class PcosTag {
  final String label;
  final Color color;
  const PcosTag(this.label, this.color);
}

class PcosCard extends StatefulWidget {
  final String emoji;
  final Color badgeColor;
  final String title;
  final String subtitle;
  final List<PcosLine> lines;
  final List<PcosTag>? tags;
  final bool initiallyExpanded;

  const PcosCard({
    super.key,
    required this.emoji,
    required this.badgeColor,
    required this.title,
    required this.subtitle,
    required this.lines,
    this.tags,
    this.initiallyExpanded = false,
  });

  @override
  State<PcosCard> createState() => _PcosCardState();
}

class _PcosCardState extends State<PcosCard> {
  late bool _expanded = widget.initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: widget.badgeColor.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(widget.emoji,
                          style: const TextStyle(fontSize: 18)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.title,
                            style: AppTextStyles.sans(
                                size: 14, weight: FontWeight.w600)),
                        const SizedBox(height: 2),
                        Text(widget.subtitle,
                            style: AppTextStyles.sans(
                                size: 11, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(Icons.keyboard_arrow_down,
                        size: 20, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity, height: 0),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final line in widget.lines) _buildLine(line),
                  if (widget.tags != null && widget.tags!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.tags!.map((t) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: t.color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: t.color.withValues(alpha: 0.4)),
                          ),
                          child: Text(t.label,
                              style: AppTextStyles.sans(
                                  size: 10,
                                  weight: FontWeight.w600,
                                  color: t.color)),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }

  Widget _buildLine(PcosLine line) {
    final baseStyle = AppTextStyles.sans(
      size: 12,
      color: AppColors.textSecondary,
    ).copyWith(height: 1.5);
    final boldStyle = baseStyle.copyWith(
      color: AppColors.textPrimary,
      fontWeight: FontWeight.w600,
    );

    final spans = <TextSpan>[];
    if (line.number != null) {
      spans.add(TextSpan(text: '${line.number}. ', style: boldStyle));
    }
    if (line.boldLead != null) {
      spans.add(TextSpan(text: line.boldLead, style: boldStyle));
      spans.add(TextSpan(
        text: line.number != null ? ' — ${line.text}' : ': ${line.text}',
        style: baseStyle,
      ));
    } else {
      spans.add(TextSpan(text: line.text, style: baseStyle));
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: RichText(text: TextSpan(children: spans)),
    );
  }
}