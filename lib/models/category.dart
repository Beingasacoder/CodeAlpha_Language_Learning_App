enum CategoryType { vocabulary, grammar, phrases }

/// A learning category within a language, e.g. "Vocabulary - Food".
class LearningCategory {
  final String id;
  final String title;
  final CategoryType type;
  final String iconName; // maps to an IconData in the UI layer
  final String description;

  const LearningCategory({
    required this.id,
    required this.title,
    required this.type,
    required this.iconName,
    required this.description,
  });
}
