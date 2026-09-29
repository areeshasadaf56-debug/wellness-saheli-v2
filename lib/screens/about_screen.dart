import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _backHeader(context, 'About'),
              const SizedBox(height: 20),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Text('🌸', style: TextStyle(fontSize: 28)),
                ),
              ),
              const SizedBox(height: 14),
              Text('Wellness Saheli', style: AppTextStyles.serif(size: 20)),
              const SizedBox(height: 4),
              Text(
                'Version 1.0.0',
                style: AppTextStyles.sans(
                  size: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              _section(
                'Our Mission',
                'Wellness Saheli is a cycle tracking companion built to help you understand your body, plan ahead, and access clear, reliable health information — all in one private space. We believe understanding your cycle shouldn\'t require a medical degree, and that good health information should be simple, honest, and judgment-free.',
              ),
              _section(
                'What You Can Do',
                'Track your period, symptoms, and mood day to day. See predictions for your next period and fertile window. Learn about your cycle phases, contraception options, and conditions like PCOS and endometriosis in plain language. Everything is designed to be private, simple, and genuinely useful.',
              ),
              _section(
                'Why We Built This',
                'So many people grow up with little to no real education about their own bodies. Wellness Saheli exists to close that gap — combining everyday cycle tracking with clear, medically grounded explanations, so you can make informed decisions about your health with confidence.',
              ),
              _section(
                'A Note on Medical Advice',
                'This app is an educational and tracking tool, not a substitute for professional medical care. Always consult a qualified doctor for diagnosis, treatment, or any health concerns specific to you.',
              ),
              const SizedBox(height: 8),
              Text(
                'Made with care, for anyone who has ever wished their body came with an instruction manual.',
                style: AppTextStyles.sans(
                  size: 12,
                  color: AppColors.textSecondary,
                ).copyWith(fontStyle: FontStyle.italic, height: 1.5),
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
      children: <Widget>[
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
        children: <Widget>[
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
