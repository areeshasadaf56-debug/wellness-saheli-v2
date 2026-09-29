import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/cycle_provider.dart';
import '../theme/app_theme.dart';
import 'cycle_data_screen.dart';
import 'about_screen.dart';
import 'terms_screen.dart';
import 'data_privacy_screen.dart';
import 'sign_in_screen.dart';
import 'health_diary_screen.dart'; // ← NEW IMPORT

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _userName = 'Your Name';

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    final savedName = prefs.getString('userName');
    if (savedName != null && savedName.isNotEmpty && mounted) {
      setState(() => _userName = savedName);
    }
  }

  Future<void> _saveUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', name);
  }

  @override
  Widget build(BuildContext context) {
    final cycle = context.watch<CycleProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Settings', style: AppTextStyles.serif(size: 22)),
              const SizedBox(height: 20),
              _profileCard(),

              const SizedBox(height: 20),
              _sectionHeading('HEALTH'),
              const SizedBox(height: 10),
              _settingsRow(context, '📖', 'My Health Diary', 'View', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HealthDiaryScreen(),
                  ),
                );
              }),

              const SizedBox(height: 20),
              _sectionHeading('CYCLE SETTINGS'),
              const SizedBox(height: 10),
              _settingsRow(context, '🩸', 'Cycle Data', 'Edit', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CycleDataScreen(),
                  ),
                );
              }),
              _reminderToggleRow(context, cycle),
              _settingsRow(context, '📊', 'Data & Privacy', 'Manage', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DataPrivacyScreen(),
                  ),
                );
              }),

              const SizedBox(height: 20),
              _sectionHeading('ABOUT'),
              const SizedBox(height: 10),
              _settingsRow(context, 'ℹ️', 'About Wellness Saheli', '', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AboutScreen()),
                );
              }),
              _settingsRow(context, '📋', 'Terms & Privacy', '', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TermsScreen()),
                );
              }),
              _settingsRow(
                context,
                '⭐',
                'Rate the App',
                '',
                () => _showRateDialog(context),
              ),

              const SizedBox(height: 20),
              _logoutButton(context),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
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

  Widget _profileCard() {
    return GestureDetector(
      onTap: () => _showEditNameDialog(context),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: AppColors.cardBorder,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_outline,
                color: AppColors.textSecondary,
                size: 28,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _userName,
                    style: AppTextStyles.sans(
                      size: 15,
                      weight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Edit Profile',
                    style: AppTextStyles.sans(
                      size: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _showEditNameDialog(BuildContext context) {
    final controller = TextEditingController(
      text: _userName == 'Your Name' ? '' : _userName,
    );
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          'Edit Name',
          style: AppTextStyles.sans(size: 16, weight: FontWeight.w600),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: AppTextStyles.sans(size: 14),
          cursorColor: AppColors.primary,
          decoration: InputDecoration(
            hintText: 'Enter your name',
            hintStyle: AppTextStyles.sans(
              size: 14,
              color: AppColors.textSecondary,
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.cardBorder),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.primary),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final newName = controller.text.trim();
              final finalName = newName.isEmpty ? 'Your Name' : newName;
              setState(() => _userName = finalName);
              _saveUserName(finalName);
              Navigator.pop(dialogContext);
            },
            child: Text(
              'Save',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _settingsRow(
    BuildContext context,
    String emoji,
    String title,
    String value,
    VoidCallback? onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.sans(size: 14, weight: FontWeight.w600),
              ),
            ),
            if (value.isNotEmpty) ...[
              Text(
                value,
                style: AppTextStyles.sans(
                  size: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 6),
            ],
            const Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _reminderToggleRow(BuildContext context, CycleProvider cycle) {
    // NOTE: if this switch still doesn't visually turn on after tapping,
    // the bug is inside cycle_provider.dart — either `remindersEnabled`
    // isn't being updated, or `toggleReminders()` isn't calling
    // notifyListeners(). This widget itself reads/writes correctly.
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          const Text('🔔', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Reminders',
              style: AppTextStyles.sans(size: 14, weight: FontWeight.w600),
            ),
          ),
          Switch(
            value: cycle.remindersEnabled,
            activeThumbColor: AppColors.primary,
            onChanged: (val) {
              context.read<CycleProvider>().toggleReminders(val);
            },
          ),
        ],
      ),
    );
  }

  Widget _logoutButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (dialogContext) => AlertDialog(
            backgroundColor: AppColors.surface,
            title: Text(
              'Log Out',
              style: AppTextStyles.sans(size: 16, weight: FontWeight.w600),
            ),
            content: Text(
              'Are you sure you want to log out?',
              style: AppTextStyles.sans(
                size: 13,
                color: AppColors.textSecondary,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  // Close the confirmation dialog first, then navigate to
                  // Sign In and clear the entire navigation stack behind
                  // it, so the back button can't return into the app.
                  Navigator.pop(dialogContext);
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SignInScreen(),
                    ),
                    (route) => false,
                  );
                },
                child: Text(
                  'Log Out',
                  style: TextStyle(color: const Color(0xFFE57373)),
                ),
              ),
            ],
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFEBEE),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(
          'Log Out',
          style: AppTextStyles.sans(
            size: 14,
            weight: FontWeight.w600,
            color: const Color(0xFFE57373),
          ),
        ),
      ),
    );
  }

  void _showRateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          'Rate the App',
          style: AppTextStyles.sans(size: 16, weight: FontWeight.w600),
        ),
        content: Text(
          'Thanks for using Wellness Saheli! App store rating will be available once the app is published.',
          style: AppTextStyles.sans(size: 13, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
