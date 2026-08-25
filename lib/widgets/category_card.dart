import 'package:flutter/material.dart';
import '../models/category.dart';
import '../utils/app_theme.dart';

class CategoryCard extends StatelessWidget {
  final LearningCategory category;
  final int learnedCount;
  final int totalCount;
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    required this.category,
    required this.learnedCount,
    required this.totalCount,
    required this.onTap,
  });

  IconData get _icon {
    switch (category.iconName) {
      case 'book':
        return Icons.menu_book_rounded;
      case 'restaurant':
        return Icons.restaurant_rounded;
      case 'flight':
        return Icons.flight_takeoff_rounded;
      case 'rule':
        return Icons.rule_rounded;
      default:
        return Icons.school_rounded;
    }
  }

  Color get _accentColor {
    switch (category.type) {
      case CategoryType.vocabulary:
        return AppTheme.primary;
      case CategoryType.grammar:
        return const Color(0xFFF08C00);
      case CategoryType.phrases:
        return AppTheme.secondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = totalCount == 0 ? 0.0 : learnedCount / totalCount;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: _accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(_icon, color: _accentColor, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(category.title,
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(
                      category.description,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 6,
                        backgroundColor: _accentColor.withValues(alpha: 0.12),
                        valueColor: AlwaysStoppedAnimation(_accentColor),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$learnedCount / $totalCount learned',
                      style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppTheme.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
