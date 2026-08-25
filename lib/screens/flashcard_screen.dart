import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/category.dart';
import '../models/lesson_item.dart';
import '../providers/progress_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/flashcard_widget.dart';

class FlashcardScreen extends StatefulWidget {
  final LearningCategory category;
  final List<LessonItem> items;

  const FlashcardScreen({super.key, required this.category, required this.items});

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  int _index = 0;

  LessonItem get _current => widget.items[_index];

  void _next() {
    if (_index < widget.items.length - 1) {
      setState(() => _index++);
    }
  }

  void _previous() {
    if (_index > 0) {
      setState(() => _index--);
    }
  }

  @override
  Widget build(BuildContext context) {
    final progressProvider = context.watch<ProgressProvider>();
    final isLearned = progressProvider.isLearned(_current.id);

    return Scaffold(
      appBar: AppBar(title: Text('${widget.category.title} Flashcards')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Text(
                'Card ${_index + 1} of ${widget.items.length}',
                style: const TextStyle(color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: (_index + 1) / widget.items.length,
                  minHeight: 6,
                  backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
                  valueColor: const AlwaysStoppedAnimation(AppTheme.primary),
                ),
              ),
              const SizedBox(height: 28),
              FlashcardWidget(
                key: ValueKey(_current.id),
                item: _current,
                isLearned: isLearned,
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _index == 0 ? null : _previous,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text('Previous'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<ProgressProvider>().markLearned(_current.id);
                        if (_index < widget.items.length - 1) {
                          _next();
                        } else {
                          Navigator.of(context).pop();
                        }
                      },
                      child: Text(isLearned
                          ? (_index < widget.items.length - 1 ? 'Next' : 'Done')
                          : 'Got it!'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
