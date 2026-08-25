import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/language_provider.dart';
import 'providers/progress_provider.dart';
import 'screens/home_screen.dart';
import 'screens/language_select_screen.dart';
import 'utils/app_theme.dart';

void main() {
  runApp(const LanguageLearningApp());
}

class LanguageLearningApp extends StatelessWidget {
  const LanguageLearningApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => ProgressProvider()),
      ],
      child: MaterialApp(
        title: 'Language Learning App',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        home: const _StartupRouter(),
      ),
    );
  }
}


class _StartupRouter extends StatelessWidget {
  const _StartupRouter();

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
    if (languageProvider.selectedLanguage == null) {
      return const LanguageSelectScreen();
    }
    return const HomeScreen();
  }
}
