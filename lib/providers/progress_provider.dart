import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Tracks per-language learning progress: which flashcards have been
/// reviewed and the best quiz score achieved per category. Persisted
/// locally via shared_preferences (MVVM: this is the "Model" state
/// exposed to ViewModels/screens through ChangeNotifier).
class ProgressProvider extends ChangeNotifier {
  static const _prefsKeyLearnedItems = 'learned_item_ids';
  static const _prefsKeyQuizScores = 'quiz_scores'; // categoryId -> "correct/total"

  final Set<String> _learnedItemIds = {};
  final Map<String, String> _quizScores = {};

  ProgressProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final learned = prefs.getStringList(_prefsKeyLearnedItems) ?? [];
    _learnedItemIds.addAll(learned);

    final scoresJson = prefs.getString(_prefsKeyQuizScores);
    if (scoresJson != null) {
      final decoded = jsonDecode(scoresJson) as Map<String, dynamic>;
      _quizScores.addAll(decoded.map((k, v) => MapEntry(k, v as String)));
    }
    notifyListeners();
  }

  bool isLearned(String itemId) => _learnedItemIds.contains(itemId);

  Future<void> markLearned(String itemId) async {
    if (_learnedItemIds.add(itemId)) {
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_prefsKeyLearnedItems, _learnedItemIds.toList());
    }
  }

  int learnedCountIn(Iterable<String> itemIds) {
    return itemIds.where(_learnedItemIds.contains).length;
  }

  String? scoreForCategory(String categoryId) => _quizScores[categoryId];

  Future<void> recordQuizScore(String categoryId, int correct, int total) async {
    final existing = _quizScores[categoryId];
    final newBest = '$correct/$total';
    // Only overwrite if this attempt is a better ratio than the stored best.
    if (existing == null || _ratio(newBest) >= _ratio(existing)) {
      _quizScores[categoryId] = newBest;
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKeyQuizScores, jsonEncode(_quizScores));
    }
  }

  double _ratio(String score) {
    final parts = score.split('/');
    final correct = int.tryParse(parts[0]) ?? 0;
    final total = int.tryParse(parts.length > 1 ? parts[1] : '1') ?? 1;
    return total == 0 ? 0 : correct / total;
  }
}
