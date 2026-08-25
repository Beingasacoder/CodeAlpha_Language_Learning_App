import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/category.dart';
import '../models/quiz_question.dart';
import '../providers/language_provider.dart';
import '../providers/progress_provider.dart';
import '../utils/app_theme.dart';

class QuizScreen extends StatefulWidget {
  final LearningCategory category;

  const QuizScreen({super.key, required this.category});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late final List<QuizQuestion> _questions;
  int _questionIndex = 0;
  int? _selectedOption;
  int _correctCount = 0;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _questions = context.read<LanguageProvider>().buildQuiz(widget.category.id);
  }

  QuizQuestion get _current => _questions[_questionIndex];

  void _selectOption(int optionIndex) {
    if (_selectedOption != null) return; // lock after first answer
    setState(() {
      _selectedOption = optionIndex;
      if (optionIndex == _current.correctOptionIndex) {
        _correctCount++;
      }
    });
  }

  void _nextQuestion() {
    if (_questionIndex < _questions.length - 1) {
      setState(() {
        _questionIndex++;
        _selectedOption = null;
      });
    } else {
      context
          .read<ProgressProvider>()
          .recordQuizScore(widget.category.id, _correctCount, _questions.length);
      setState(() => _finished = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('${widget.category.title} Quiz')),
        body: const Center(child: Text('Not enough items to build a quiz yet.')),
      );
    }

    if (_finished) {
      return _ResultsView(
        correct: _correctCount,
        total: _questions.length,
        onRetry: () {
          setState(() {
            _questionIndex = 0;
            _selectedOption = null;
            _correctCount = 0;
            _finished = false;
            _questions.shuffle();
          });
        },
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('${widget.category.title} Quiz')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Question ${_questionIndex + 1} of ${_questions.length}',
                style: const TextStyle(color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: (_questionIndex + 1) / _questions.length,
                  minHeight: 6,
                  backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
                  valueColor: const AlwaysStoppedAnimation(AppTheme.primary),
                ),
              ),
              const SizedBox(height: 28),
              Text(
                _current.prompt,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView.separated(
                  itemCount: _current.options.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) => _OptionTile(
                    text: _current.options[i],
                    state: _selectedOption == null
                        ? _OptionState.neutral
                        : i == _current.correctOptionIndex
                            ? _OptionState.correct
                            : i == _selectedOption
                                ? _OptionState.incorrect
                                : _OptionState.disabled,
                    onTap: () => _selectOption(i),
                  ),
                ),
              ),
              if (_selectedOption != null)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _nextQuestion,
                    child: Text(_questionIndex < _questions.length - 1
                        ? 'Next Question'
                        : 'See Results'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _OptionState { neutral, correct, incorrect, disabled }

class _OptionTile extends StatelessWidget {
  final String text;
  final _OptionState state;
  final VoidCallback onTap;

  const _OptionTile({required this.text, required this.state, required this.onTap});

  @override
  Widget build(BuildContext context) {
    Color borderColor;
    Color bgColor;
    Widget? trailing;

    switch (state) {
      case _OptionState.neutral:
        borderColor = Colors.grey.shade300;
        bgColor = Colors.white;
        trailing = null;
        break;
      case _OptionState.correct:
        borderColor = AppTheme.secondary;
        bgColor = AppTheme.secondary.withValues(alpha: 0.08);
        trailing = const Icon(Icons.check_circle_rounded, color: AppTheme.secondary);
        break;
      case _OptionState.incorrect:
        borderColor = Colors.redAccent;
        bgColor = Colors.redAccent.withValues(alpha: 0.08);
        trailing = const Icon(Icons.cancel_rounded, color: Colors.redAccent);
        break;
      case _OptionState.disabled:
        borderColor = Colors.grey.shade200;
        bgColor = Colors.white;
        trailing = null;
        break;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: borderColor, width: 1.5),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(text, style: const TextStyle(fontSize: 16)),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }
}

class _ResultsView extends StatelessWidget {
  final int correct;
  final int total;
  final VoidCallback onRetry;

  const _ResultsView({required this.correct, required this.total, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final percent = total == 0 ? 0 : ((correct / total) * 100).round();
    final passed = percent >= 70;

    return Scaffold(
      appBar: AppBar(title: const Text('Quiz Results')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                passed ? Icons.emoji_events_rounded : Icons.refresh_rounded,
                size: 72,
                color: passed ? const Color(0xFFF08C00) : AppTheme.primary,
              ),
              const SizedBox(height: 20),
              Text(
                '$percent%',
                style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                'You got $correct out of $total correct',
                style: const TextStyle(fontSize: 16, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onRetry,
                  child: const Text('Try Again'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text('Back to Category'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
