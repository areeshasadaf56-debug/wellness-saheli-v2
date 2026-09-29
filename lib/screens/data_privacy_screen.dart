import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/health_profile.dart';
import '../services/health_profile_service.dart';

class DataPrivacyScreen extends StatefulWidget {
  const DataPrivacyScreen({super.key});

  @override
  State<DataPrivacyScreen> createState() => _DataPrivacyScreenState();
}

class _DataPrivacyScreenState extends State<DataPrivacyScreen> {
  final HealthProfileService _service = HealthProfileService();
  HealthProfile? _profile;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final profile = await _service.loadProfile();
    if (!mounted) return;
    setState(() {
      _profile = profile;
      _loading = false;
    });
  }

  Future<void> _setAiCanAccessDiary(bool value) async {
    final updated = await _service.updateProfile(
      (p) => p.copyWith(
        privacySettings: p.privacySettings.copyWith(aiCanAccessDiary: value),
      ),
    );
    if (!mounted) return;
    setState(() => _profile = updated);
  }

  Future<void> _setAiMemoryEnabled(bool value) async {
    final updated = await _service.updateProfile(
      (p) => p.copyWith(
        privacySettings: p.privacySettings.copyWith(aiMemoryEnabled: value),
      ),
    );
    if (!mounted) return;
    setState(() => _profile = updated);
  }

  Future<void> _confirmAndClearAiMemory() async {
    final confirmed = await _showConfirmDialog(
      title: 'Clear AI conversation memory?',
      body:
          'This deletes every past check-in conversation Saheli AI has '
          'recorded. It does not affect your diary entries, PCOS checks, '
          'or contraception history. This can\'t be undone.',
      confirmLabel: 'Clear memory',
    );
    if (confirmed != true) return;

    final updated = await _service.updateProfile(
      (p) => p.copyWith(conversationLog: const []),
    );
    if (!mounted) return;
    setState(() => _profile = updated);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('AI conversation memory cleared')),
    );
  }

  Future<void> _confirmAndDeleteDiaryEntries() async {
    final confirmed = await _showConfirmDialog(
      title: 'Delete all diary entries?',
      body:
          'This permanently deletes everything you\'ve written in your '
          'diary. It does not affect your cycle logs, PCOS checks, or AI '
          'conversation history. This can\'t be undone.',
      confirmLabel: 'Delete entries',
    );
    if (confirmed != true) return;

    final updated = await _service.updateProfile(
      (p) => p.copyWith(diaryEntries: const []),
    );
    if (!mounted) return;
    setState(() => _profile = updated);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('All diary entries deleted')));
  }

  Future<bool?> _showConfirmDialog({
    required String title,
    required String body,
    required String confirmLabel,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          title,
          style: AppTextStyles.sans(size: 16, weight: FontWeight.w600),
        ),
        content: Text(
          body,
          style: AppTextStyles.sans(
            size: 13,
            color: AppColors.textSecondary,
          ).copyWith(height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(
              confirmLabel,
              style: const TextStyle(
                color: Color(0xFFE57373),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
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
              _backHeader(context, 'Data & Privacy'),
              const SizedBox(height: 20),
              if (!_loading) ...[
                _aiPrivacySection(),
                const SizedBox(height: 24),
              ],
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.ovulationTeal.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.ovulationTeal.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Text('🔒', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Your period, symptom, and mood logs live only on this device. A couple of optional health tools in the app do send the specific values you enter to our server — see below for exactly what and when.',
                        style: AppTextStyles.sans(
                          size: 12,
                          color: AppColors.textPrimary,
                        ).copyWith(height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _section(
                'What We Store',
                'Period start and end dates, cycle length settings, symptoms you log, moods you log, and reminder preferences. All of this is saved locally in the app\'s own storage on your phone — the same way notes or offline apps keep data on your device.',
              ),
              _section(
                'What Is Sent to Our Server',
                'Two tools in this app — the PCOS screening check and the contraceptive eligibility checker — need a server to calculate your result. When you use them, only the specific values you enter on that screen (like the health details you type into the PCOS form, or the conditions you select in My Plan) are sent for that one calculation. We don\'t attach your name, cycle history, or any other data to these requests, and results aren\'t stored on the server afterward.',
              ),
              _section(
                'Account & Login',
                'Creating an account lets you use the app and keeps your name in sync across screens. Your login details are currently stored on your device only, not on a server.',
              ),
              _section(
                'What We Don\'t Do',
                'We don\'t run analytics that identify you personally, and we don\'t sell or share your health data with advertisers.',
              ),
              _section(
                'Why We Ask for This Data',
                'Cycle dates, symptoms, and mood logs are used only to power the predictions and insights inside the app — like your current cycle day, upcoming period estimate, and fertility window. None of it leaves your device to do this.',
              ),
              _section(
                'Your Control',
                'You can edit or delete your cycle data at any time from Settings → Cycle Data. Uninstalling the app removes all locally stored data along with it, since nothing is backed up to an external server by default.',
              ),
              _section(
                'If You Share Your Device',
                'Because data is stored locally, anyone with access to your unlocked phone could open the app and see your logs. If that\'s a concern, consider using your phone\'s built-in app lock or biometric lock features for extra privacy.',
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

  // ---------------- AI & Diary privacy controls ----------------

  Widget _aiPrivacySection() {
    final settings = _profile!.privacySettings;
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
            'AI & Diary Privacy',
            style: AppTextStyles.sans(size: 14, weight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            'Control what Saheli AI is allowed to remember and read about you.',
            style: AppTextStyles.sans(
              size: 12,
              color: AppColors.textSecondary,
            ).copyWith(height: 1.4),
          ),
          const SizedBox(height: 16),
          _privacyToggleRow(
            emoji: '📖',
            title: 'AI can read my diary',
            subtitle:
                'When on, Saheli AI may reference your diary entries during '
                'check-ins to give more relevant guidance. Off by default.',
            value: settings.aiCanAccessDiary,
            onChanged: _setAiCanAccessDiary,
          ),
          const SizedBox(height: 12),
          _privacyToggleRow(
            emoji: '🧠',
            title: 'AI remembers past conversations',
            subtitle:
                'When off, every check-in starts fresh with no memory of '
                'earlier conversations.',
            value: settings.aiMemoryEnabled,
            onChanged: _setAiMemoryEnabled,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _confirmAndClearAiMemory,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: BorderSide(color: AppColors.cardBorder),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Clear AI memory',
                    style: AppTextStyles.sans(
                      size: 12,
                      weight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: _confirmAndDeleteDiaryEntries,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFE57373),
                    side: const BorderSide(color: Color(0xFFE57373)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Delete diary entries',
                    style: AppTextStyles.sans(
                      size: 12,
                      weight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _privacyToggleRow({
    required String emoji,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.sans(size: 13, weight: FontWeight.w600),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: AppTextStyles.sans(
                  size: 11,
                  color: AppColors.textSecondary,
                ).copyWith(height: 1.4),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Switch(
          value: value,
          activeThumbColor: AppColors.primary,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _section(String heading, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            heading,
            style: AppTextStyles.sans(
              size: 14,
              weight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: AppTextStyles.sans(
              size: 13,
              color: AppColors.textSecondary,
            ).copyWith(height: 1.6),
          ),
        ],
      ),
    );
  }
}
