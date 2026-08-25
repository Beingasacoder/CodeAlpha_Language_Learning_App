import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../providers/progress_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/category_card.dart';
import 'category_detail_screen.dart';
import 'language_select_screen.dart';
import 'progress_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
    final progressProvider = context.watch<ProgressProvider>();
    final language = languageProvider.selectedLanguage;
    final categories = languageProvider.categories;

    final totalItems = languageProvider.allItems.length;
    final totalLearned =
        progressProvider.learnedCountIn(languageProvider.allItems.map((i) => i.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(language == null
            ? 'Learn'
            : 'Learn ${language.name} ${language.flagEmoji}'),
        actions: [
          IconButton(
            tooltip: 'Change language',
            icon: const Icon(Icons.translate_rounded),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const LanguageSelectScreen()),
              );
            },
          ),
          IconButton(
            tooltip: 'Progress',
            icon: const Icon(Icons.bar_chart_rounded),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ProgressScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {},
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          children: [
            _DailyProgressBanner(totalLearned: totalLearned, totalItems: totalItems),
            const SizedBox(height: 24),
            Text('Categories', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12),
            ...categories.map((category) {
              final items = languageProvider.itemsForCategory(category.id);
              final learned =
                  progressProvider.learnedCountIn(items.map((i) => i.id));
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: CategoryCard(
                  category: category,
                  learnedCount: learned,
                  totalCount: items.length,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => CategoryDetailScreen(category: category),
                      ),
                    );
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _DailyProgressBanner extends StatelessWidget {
  final int totalLearned;
  final int totalItems;

  const _DailyProgressBanner({required this.totalLearned, required this.totalItems});

  @override
  Widget build(BuildContext context) {
    final progress = totalItems == 0 ? 0.0 : totalLearned / totalItems;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primary, Color(0xFF7C5CFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Today's goal",
            style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            '$totalLearned of $totalItems words learned',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation(Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
