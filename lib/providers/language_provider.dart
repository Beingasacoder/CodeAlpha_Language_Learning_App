import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/sample_data.dart';
import '../models/language.dart';
import '../models/category.dart';
import '../models/lesson_item.dart';
import '../models/quiz_question.dart';

class LanguageProvider extends ChangeNotifier {
  static const _prefsKeySelectedLanguage = 'selected_language_code';

  AppLanguage? _selectedLanguage;
  AppLanguage? get selectedLanguage => _selectedLanguage;

  List<AppLanguage> get availableLanguages => SampleData.languages;

  LanguageProvider() {
    _loadSelectedLanguage();
  }

  Future<void> _loadSelectedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_prefsKeySelectedLanguage);
    if (code != null) {
      _selectedLanguage = SampleData.languages.firstWhere(
        (l) => l.code == code,
        orElse: () => SampleData.languages.first,
      );
      notifyListeners();
    }
  }

  Future<void> selectLanguage(AppLanguage language) async {
    _selectedLanguage = language;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKeySelectedLanguage, language.code);
  }

  List<LearningCategory> get categories {
    if (_selectedLanguage == null) return [];
    return SampleData.categoriesFor(_selectedLanguage!.code);
  }

  List<LessonItem> itemsForCategory(String categoryId) {
    if (_selectedLanguage == null) return [];
    return SampleData.itemsFor(_selectedLanguage!.code, categoryId);
  }

  List<LessonItem> get allItems {
    if (_selectedLanguage == null) return [];
    return SampleData.allItemsFor(_selectedLanguage!.code);
  }

  /// Builds a simple multiple-choice quiz from the items in [categoryId].
  /// Each question asks for the translation of a term, with 3 distractors
  /// drawn from other items in the same language.
  List<QuizQuestion> buildQuiz(String categoryId, {int questionCount = 5}) {
    final items = itemsForCategory(categoryId);
    if (items.isEmpty) return [];

    final allTranslations = allItems.map((i) => i.translation).toSet().toList();
    final rand = Random();
    final shuffledItems = List<LessonItem>.from(items)..shuffle(rand);
    final selected = shuffledItems.take(questionCount).toList();

    return selected.map((item) {
      final distractors = allTranslations
          .where((t) => t != item.translation)
          .toList()
        ..shuffle(rand);
      final options = <String>[item.translation, ...distractors.take(3)];
      options.shuffle(rand);
      final correctIndex = options.indexOf(item.translation);

      return QuizQuestion(
        id: item.id,
        prompt: "What does '${item.term}' mean?",
        options: options,
        correctOptionIndex: correctIndex,
      );
    }).toList();
  }
}
