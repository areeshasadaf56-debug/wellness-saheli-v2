import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'l10n/language_fab.dart';
import 'l10n/language_provider.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';
import 'providers/cycle_provider.dart';

void main() {
  runApp(const WellnessSaheliApp());
}

class WellnessSaheliApp extends StatelessWidget {
  const WellnessSaheliApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CycleProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
      ],
      child: const _AppRoot(),
    );
  }
}

class _AppRoot extends StatelessWidget {
  const _AppRoot();

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    return MaterialApp(
      title: 'Wellness Saheli',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      // 'ur' makes Flutter lay everything out right-to-left automatically
      // and translates built-in widgets (date pickers, OK/Cancel, etc.).
      locale: lang.locale,
      supportedLocales: const [Locale('en'), Locale('ur')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      builder: (context, child) => Stack(
        fit: StackFit.expand,
        children: [child ?? const SizedBox.shrink(), const LanguageFab()],
      ),
      home: const SplashScreen(),
    );
  }
}
