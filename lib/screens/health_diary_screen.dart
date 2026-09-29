import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/health_profile.dart';
import '../services/health_profile_service.dart';
import '../providers/cycle_provider.dart';

/// Unified entry type so PCOS results, contraception changes, AI
/// conversation turns, and cycle logs (period flow, mood, symptoms) can
/// all live in one sorted timeline.
enum _EntryKind { pcos, contraception, conversation, cycle, eligibility }

class _TimelineEntry {
  final DateTime date;
  final _EntryKind kind;
  final String title;
  final String subtitle;
  final Color color;
  final String emoji;

  _TimelineEntry({
    required this.date,
    required this.kind,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.emoji,
  });
}

class HealthDiaryScreen extends StatefulWidget {
  const HealthDiaryScreen({super.key});

  @override
  State<HealthDiaryScreen> createState() => _HealthDiaryScreenState();
}

class _HealthDiaryScreenState extends State<HealthDiaryScreen> {
  final _service = HealthProfileService();
  HealthProfile? _profile;
  bool _loading = true;
  int _activeTab = 0; // 0 = Timeline, 1 = Profile Summary

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final profile = await _service.loadProfile();
    if (!mounted) return;
    setState(() {
      _profile = profile;
      _loading = false;
    });
  }

  /// Parses the "yyyy-MM-dd" keys CycleProvider uses for _dailyLogs back
  /// into a DateTime, so cycle log entries can be sorted alongside
  /// PCOS/contraception/conversation entries on the same timeline.
  DateTime? _parseDateKey(String key) {
    final parts = key.split('-');
    if (parts.length != 3) return null;
    final year = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final day = int.tryParse(parts[2]);
    if (year == null || month == null || day == null) return null;
    return DateTime(year, month, day);
  }

  List<_TimelineEntry> _buildTimeline(
    HealthProfile p,
    Map<String, dynamic> dailyLogs,
  ) {
    final entries = <_TimelineEntry>[];

    for (final r in p.pcosHistory) {
      final positive = r.prediction.toLowerCase().contains('detected') &&
          !r.prediction.toLowerCase().contains('no pcos');
      entries.add(_TimelineEntry(
        date: r.date,
        kind: _EntryKind.pcos,
        title: 'PCOS Check — ${r.prediction}',
        subtitle:
            'Likelihood: ${(r.pcosProbability * 100).clamp(0, 100).toStringAsFixed(1)}% · ${r.modelUsed}',
        color: positive ? AppColors.periodRed : AppColors.ovulationTeal,
        emoji: '🧪',
      ));
    }

    for (final c in p.reproductiveHistory.contraceptionHistory) {
      entries.add(_TimelineEntry(
        date: c.date,
        kind: _EntryKind.contraception,
        title: 'Protection Method — ${c.method}',
        subtitle: c.note ?? 'Method logged',
        color: AppColors.primary,
        emoji: '🛡️',
      ));
    }

    for (final ec in p.eligibilityHistory) {
      final safeCount = ec.results.where((r) => r.category == 1).length;
      entries.add(_TimelineEntry(
        date: ec.date,
        kind: _EntryKind.eligibility,
        title: 'Eligibility Check — ${ec.conditions.length} condition(s)',
        subtitle: ec.conditions.isEmpty
            ? '$safeCount of ${ec.results.length} methods rated "safe to use"'
            : '${ec.conditions.join(", ")} · $safeCount of ${ec.results.length} methods rated "safe to use"',
        color: AppColors.moodYellow,
        emoji: '📝',
      ));
    }

    for (final e in p.conversationLog) {
      entries.add(_TimelineEntry(
        date: e.timestamp,
        kind: _EntryKind.conversation,
        title: e.role == 'user' ? 'You said' : 'Saheli AI',
        subtitle: e.message,
        color: AppColors.accent,
        emoji: e.role == 'user' ? '💬' : '🤖',
      ));
    }

    // Cycle logs come from CycleProvider's dailyLogs map, keyed by date
    // string. Each day's log can carry a period flag/intensity, a mood,
    // and/or a list of symptoms -- each present field becomes its own
    // timeline entry so the diary reads naturally (e.g. "Period Flow:
    // Medium" on one line, "Mood: Anxious" on another, same day).
    dailyLogs.forEach((key, log) {
      final date = _parseDateKey(key);
      if (date == null) return;

      final isPeriodDay = log.isPeriodDay == true;
      final flowIntensity = log.flowIntensity as String?;
      final mood = log.mood as String?;
      final symptoms = (log.symptoms as List?)?.cast<String>() ?? const [];

      if (isPeriodDay || (flowIntensity != null && flowIntensity.isNotEmpty)) {
        entries.add(_TimelineEntry(
          date: date,
          kind: _EntryKind.cycle,
          title: 'Period Flow${flowIntensity != null ? ' — $flowIntensity' : ''}',
          subtitle: isPeriodDay ? 'Logged as a period day' : 'Flow logged',
          color: AppColors.periodRed,
          emoji: '🩸',
        ));
      }

      if (mood != null && mood.isNotEmpty) {
        entries.add(_TimelineEntry(
          date: date,
          kind: _EntryKind.cycle,
          title: 'Mood — $mood',
          subtitle: 'Logged from your cycle calendar',
          color: AppColors.moodYellow,
          emoji: '🙂',
        ));
      }

      if (symptoms.isNotEmpty) {
        entries.add(_TimelineEntry(
          date: date,
          kind: _EntryKind.cycle,
          title: 'Symptoms logged',
          subtitle: symptoms.join(', '),
          color: AppColors.symptomOrange,
          emoji: '📋',
        ));
      }
    });

    entries.sort((a, b) => b.date.compareTo(a.date));
    return entries;
  }

  @override
  Widget build(BuildContext context) {
    final cycle = context.watch<CycleProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _load,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(context),
                      const SizedBox(height: 20),
                      _buildStatsGrid(_profile!, cycle),
                      const SizedBox(height: 20),
                      _buildTabs(),
                      const SizedBox(height: 16),
                      if (_activeTab == 0)
                        ..._buildTimelineTab(_profile!, cycle)
                      else
                        ..._buildProfileTab(_profile!),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  // ---------------- Header ----------------

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(
                Icons.arrow_back_ios_new,
                size: 18,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 12),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'My ',
                    style: AppTextStyles.serif(
                      size: 22,
                      weight: FontWeight.w600,
                      color: AppColors.accent,
                    ).copyWith(fontStyle: FontStyle.italic),
                  ),
                  TextSpan(
                    text: 'Diary',
                    style: AppTextStyles.serif(
                      size: 22,
                      weight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: _load,
          child: const Icon(
            Icons.refresh,
            size: 20,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  // ---------------- Stats ----------------

  Widget _buildStatsGrid(HealthProfile p, CycleProvider cycle) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _statCard(
                '${p.pcosHistory.length}',
                'PCOS checks',
                AppColors.ovulationTeal,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _statCard(
                '${p.reproductiveHistory.contraceptionHistory.length}',
                'Methods logged',
                AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _statCard(
                '${cycle.dailyLogs.length}',
                'Cycle entries',
                AppColors.periodRed,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _statCard(
                '${p.eligibilityHistory.length}',
                'Eligibility checks',
                AppColors.moodYellow,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _statCard(
                '${p.conversationLog.length}',
                'AI check-ins',
                AppColors.accent,
              ),
            ),
            const SizedBox(width: 10),
            const Expanded(child: SizedBox()),
          ],
        ),
      ],
    );
  }

  Widget _statCard(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: AppTextStyles.serif(size: 22, color: color),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.sans(
              size: 10,
              weight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- Tabs ----------------

  Widget _buildTabs() {
    return Row(
      children: [
        Expanded(child: _tabButton('🕒', 'Timeline', 0, AppColors.primary)),
        const SizedBox(width: 10),
        Expanded(child: _tabButton('📋', 'Profile', 1, AppColors.accent)),
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
          color: isActive ? activeColor.withOpacity(0.18) : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive
                ? activeColor.withOpacity(0.6)
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

  // ---------------- Timeline tab ----------------

  List<Widget> _buildTimelineTab(HealthProfile p, CycleProvider cycle) {
    final entries = _buildTimeline(p, cycle.dailyLogs);

    if (entries.isEmpty) {
      return [_emptyState()];
    }

    // Group by month for readability.
    final grouped = <String, List<_TimelineEntry>>{};
    for (final e in entries) {
      final key = _monthYearLabel(e.date);
      grouped.putIfAbsent(key, () => []).add(e);
    }

    final widgets = <Widget>[];
    grouped.forEach((month, items) {
      widgets.add(Padding(
        padding: const EdgeInsets.only(bottom: 8, top: 4),
        child: Text(
          month.toUpperCase(),
          style: AppTextStyles.sans(
            size: 11,
            weight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
      ));
      for (final item in items) {
        widgets.add(_timelineTile(item));
      }
      widgets.add(const SizedBox(height: 8));
    });

    return widgets;
  }

  Widget _timelineTile(_TimelineEntry e) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: e.color.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: e.color.withOpacity(0.18),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(e.emoji, style: const TextStyle(fontSize: 16)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  e.title,
                  style: AppTextStyles.sans(size: 13, weight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  e.subtitle,
                  style: AppTextStyles.sans(
                    size: 11,
                    color: AppColors.textSecondary,
                  ).copyWith(height: 1.4),
                ),
                const SizedBox(height: 6),
                Text(
                  _formatDate(e.date),
                  style: AppTextStyles.sans(
                    size: 10,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          const Text('📖', style: TextStyle(fontSize: 36)),
          const SizedBox(height: 12),
          Text(
            'Your diary is empty — for now',
            style: AppTextStyles.sans(size: 14, weight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            'PCOS checks, protection method changes, cycle logs, and AI '
            'check-ins will show up here automatically as you use the app.',
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

  // ---------------- Profile tab ----------------

  List<Widget> _buildProfileTab(HealthProfile p) {
    return [
      _profileSection('Demographics', '👤', AppColors.primary, [
        _kv('Age', p.demographics.ageYrs?.toString()),
        _kv('Weight', p.demographics.weightKg != null
            ? '${p.demographics.weightKg} kg'
            : null),
        _kv('Height', p.demographics.heightCm != null
            ? '${p.demographics.heightCm} cm'
            : null),
        _kv('Marital Status', p.demographics.maritalStatus),
      ]),
      const SizedBox(height: 12),
      _profileSection('Lifestyle', '🌿', AppColors.ovulationTeal, [
        _kv('Regular Exercise', _yesNo(p.lifestyle.regularExercise)),
        _kv('Exercise Frequency', p.lifestyle.exerciseFrequency),
        _kv('Diet Quality', p.lifestyle.dietQuality),
        _kv('Frequent Fast Food', _yesNo(p.lifestyle.fastFoodFrequent)),
        _kv('Avg Sleep', p.lifestyle.averageSleepHours != null
            ? '${p.lifestyle.averageSleepHours} hrs'
            : null),
        _kv('Notes', p.lifestyle.notes),
      ]),
      const SizedBox(height: 12),
      _profileSection('Reproductive Health', '🩷', AppColors.periodRed, [
        _kv('Cycle Regularity', p.reproductiveHistory.cycleRegularity),
        _kv('Cycle Length', p.reproductiveHistory.cycleLengthDays != null
            ? '${p.reproductiveHistory.cycleLengthDays} days'
            : null),
        _kv('Current Method',
            p.reproductiveHistory.currentContraceptionMethod),
      ]),
      const SizedBox(height: 12),
      _profileSection('Wellbeing (self-reported)', '💛', AppColors.moodYellow, [
        _kv('Stress Level (1-5)',
            p.mentalHealth.selfReportedStressLevel?.toString()),
        _kv('Notes', p.mentalHealth.notes),
        _kv(
          'Last Check-in',
          p.mentalHealth.lastCheckIn != null
              ? _formatDate(p.mentalHealth.lastCheckIn!)
              : null,
        ),
      ]),
      const SizedBox(height: 16),
      Center(
        child: Text(
          'Last updated: ${_formatDate(p.lastUpdated)}',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
        ),
      ),
    ];
  }

  Widget _profileSection(
    String title,
    String emoji,
    Color color,
    List<Widget> rows,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppTextStyles.sans(size: 14, weight: FontWeight.w600),
              ),
            ],
          ),
          const Divider(height: 20),
          ...rows,
        ],
      ),
    );
  }

  Widget _kv(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: AppTextStyles.sans(
                size: 12,
                weight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value ?? 'Not set',
              style: AppTextStyles.sans(
                size: 12,
                color: value == null
                    ? AppColors.textSecondary
                    : AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String? _yesNo(bool? v) {
    if (v == null) return null;
    return v ? 'Yes' : 'No';
  }

  String _monthYearLabel(DateTime d) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${months[d.month - 1]} ${d.year}';
  }

  String _formatDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final hour = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final ampm = d.hour >= 12 ? 'PM' : 'AM';
    return '${months[d.month - 1]} ${d.day}, ${d.year} · $hour:${d.minute.toString().padLeft(2, '0')} $ampm';
  }
}