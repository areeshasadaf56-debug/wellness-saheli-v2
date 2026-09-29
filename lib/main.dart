import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
    return ChangeNotifierProvider(
      create: (_) => CycleProvider(),
      child: MaterialApp(
        title: 'Wellness Saheli',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        home: const SplashScreen(),
      ),
    );
  }
}
