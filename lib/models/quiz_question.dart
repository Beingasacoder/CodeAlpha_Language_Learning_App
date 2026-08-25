/// A multiple-choice quiz question generated from a category's lesson items.
class QuizQuestion {
  final String id;
  final String prompt; // e.g. "What does 'Hola' mean?"
  final List<String> options;
  final int correctOptionIndex;

  const QuizQuestion({
    required this.id,
    required this.prompt,
    required this.options,
    required this.correctOptionIndex,
  });
}
