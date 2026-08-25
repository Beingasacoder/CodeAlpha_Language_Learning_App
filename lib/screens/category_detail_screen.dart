import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/category.dart';
import '../providers/language_provider.dart';
import '../providers/progress_provider.dart';
import '../utils/app_theme.dart';
import 'flashcard_screen.dart';
import 'quiz_screen.dart';

class CategoryDetailScreen extends StatelessWidget {
  final LearningCategory category;

  const CategoryDetailScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
    final progressProvider = context.watch<ProgressProvider>();
    final items = languageProvider.itemsForCategory(category.id);
    final learned = progressProvider.learnedCountIn(items.map((i) => i.id));

    return Scaffold(
      appBar: AppBar(title: Text(category.title)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.style_rounded),
                    label: const Text('Flashcards'),
                    onPressed: items.isEmpty
                        ? null
                        : () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    FlashcardScreen(category: category, items: items),
                              ),
                            ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.quiz_rounded),
                    label: const Text('Take Quiz'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      side: const BorderSide(color: AppTheme.primary),
                      foregroundColor: AppTheme.primary,
                    ),
                    onPressed: items.length < 2
                        ? null
                        : () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => QuizScreen(category: category),
                              ),
                            ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('$learned / ${items.length} learned',
                    style: const TextStyle(color: AppTheme.textSecondary)),
                if (progressProvider.scoreForCategory(category.id) != null)
                  Text(
                    'Best quiz score: ${progressProvider.scoreForCategory(category.id)}',
                    style: const TextStyle(color: AppTheme.textSecondary),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = items[index];
                final isLearned = progressProvider.isLearned(item.id);
                return Card(
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    title: Text(item.term,
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Text('${item.translation}  •  /${item.pronunciation}/'),
                    trailing: Icon(
                      isLearned ? Icons.check_circle_rounded : Icons.circle_outlined,
                      color: isLearned ? AppTheme.secondary : AppTheme.textSecondary,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
