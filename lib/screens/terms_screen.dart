import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

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
              _backHeader(context, 'Terms & Privacy'),
              const SizedBox(height: 20),
              Text(
                'Last updated: July 2026',
                style: AppTextStyles.sans(
                  size: 11,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              _section(
                '1. Not Medical Advice',
                'Wellness Saheli provides educational information and self-tracking tools only. Nothing in this app constitutes medical advice, diagnosis, or treatment. Predictions about your cycle, fertility, or symptoms are estimates based on the data you enter and general averages — they are not guaranteed to be accurate for your body. Always consult a qualified doctor or healthcare provider for any medical concerns, before making decisions about contraception, fertility, or treatment, and before stopping or starting any medication.',
              ),
              _section(
                '2. Your Data',
                'Cycle, symptom, and mood data you enter is stored locally on your device. The PCOS screening tool and the contraceptive eligibility checker send the values you enter on those screens to our server so it can calculate a result for you — these requests are not linked to your name or stored for later use. We do not sell, rent, or share your data with advertisers or third parties. You can delete your locally stored data at any time from within the app.',
              ),
              _section(
                '3. Acceptable Use',
                'This app is intended for personal, non-commercial use to track your own health information. You agree not to use the app to attempt to harm, reverse-engineer, or disrupt its normal operation, and not to misrepresent information provided by the app as professional medical advice to others.',
              ),
              _section(
                '4. Accuracy & Limitations',
                'Cycle predictions, phase estimates, and fertility windows are approximations based on standard cycle-length averages and the data you provide. Real cycles vary due to stress, illness, travel, medication, and many other factors. This app should not be relied upon as a sole method of contraception or conception planning.',
              ),
              _section(
                '5. Changes to These Terms',
                'These terms may be updated from time to time as the app evolves. Continued use of the app after an update means you accept the revised terms.',
              ),
              _section(
                '6. Contact',
                'If you have questions about these terms or how your data is handled, you can reach out through the app store listing once Wellness Saheli is published.',
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
