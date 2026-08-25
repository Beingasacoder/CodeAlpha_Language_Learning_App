import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../providers/progress_provider.dart';
import '../utils/app_theme.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
    final progressProvider = context.watch<ProgressProvider>();
    final categories = languageProvider.categories;

    final totalItems = languageProvider.allItems.length;
    final totalLearned =
        progressProvider.learnedCountIn(languageProvider.allItems.map((i) => i.id));
    final overallPercent = totalItems == 0 ? 0 : ((totalLearned / totalItems) * 100).round();

    return Scaffold(
      appBar: AppBar(title: const Text('Your Progress')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.cardBackground,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  '$overallPercent%',
                  style: const TextStyle(
                      fontSize: 44, fontWeight: FontWeight.w800, color: AppTheme.primary),
                ),
                const SizedBox(height: 4),
                Text('$totalLearned of $totalItems words learned overall',
                    style: const TextStyle(color: AppTheme.textSecondary)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('By category', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          ...categories.map((category) {
            final items = languageProvider.itemsForCategory(category.id);
            final learned = progressProvider.learnedCountIn(items.map((i) => i.id));
            final score = progressProvider.scoreForCategory(category.id);
            final progress = items.isEmpty ? 0.0 : learned / items.length;

            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(category.title,
                              style: const TextStyle(fontWeight: FontWeight.w700)),
                          Text('$learned/${items.length}',
                              style: const TextStyle(color: AppTheme.textSecondary)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 6,
                          backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
                          valueColor: const AlwaysStoppedAnimation(AppTheme.primary),
                        ),
                      ),
                      if (score != null) ...[
                        const SizedBox(height: 8),
                        Text('Best quiz score: $score',
                            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
