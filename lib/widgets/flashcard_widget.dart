import 'package:flutter/material.dart';
import '../models/lesson_item.dart';
import '../utils/app_theme.dart';

/// A tappable flashcard that flips between the term (front) and its
/// translation/pronunciation/example (back).
class FlashcardWidget extends StatefulWidget {
  final LessonItem item;
  final bool isLearned;

  const FlashcardWidget({
    super.key,
    required this.item,
    required this.isLearned,
  });

  @override
  State<FlashcardWidget> createState() => _FlashcardWidgetState();
}

class _FlashcardWidgetState extends State<FlashcardWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 350),
  );
  bool _showFront = true;

  @override
  void didUpdateWidget(covariant FlashcardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.id != widget.item.id) {
      _showFront = true;
      _controller.value = 0;
    }
  }

  void _flip() {
    if (_showFront) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    setState(() => _showFront = !_showFront);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    return GestureDetector(
      onTap: _flip,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final angle = _controller.value * 3.14159;
          final isBack = angle > 3.14159 / 2;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle),
            child: isBack
                ? Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(3.14159),
                    child: _buildBack(item),
                  )
                : _buildFront(item),
          );
        },
      ),
    );
  }

  Widget _buildCardShell({required Widget child}) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 260),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildFront(LessonItem item) {
    return _buildCardShell(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (widget.isLearned)
            const Align(
              alignment: Alignment.topRight,
              child: Icon(Icons.check_circle_rounded, color: AppTheme.secondary),
            ),
          const Spacer(),
          Text(
            item.term,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '/${item.pronunciation}/',
            style: const TextStyle(
              fontSize: 15,
              fontStyle: FontStyle.italic,
              color: AppTheme.textSecondary,
            ),
          ),
          const Spacer(),
          const Text(
            'Tap to flip',
            style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildBack(LessonItem item) {
    return _buildCardShell(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('TRANSLATION',
              style: TextStyle(fontSize: 11, color: AppTheme.textSecondary, letterSpacing: 1)),
          const SizedBox(height: 4),
          Text(
            item.translation,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 20),
          const Text('EXAMPLE',
              style: TextStyle(fontSize: 11, color: AppTheme.textSecondary, letterSpacing: 1)),
          const SizedBox(height: 4),
          Text(item.exampleSentence,
              style: const TextStyle(fontSize: 15, color: AppTheme.textPrimary)),
          const SizedBox(height: 2),
          Text(item.exampleTranslation,
              style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
        ],
      ),
    );
  }
}
