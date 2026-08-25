/// A single flashcard / lesson item: a word or phrase with its
/// translation and a simple pronunciation guide.
class LessonItem {
  final String id;
  final String categoryId;
  final String term; // word/phrase in the target language
  final String translation; // meaning in the user's base language
  final String pronunciation; // phonetic guide, e.g. "OH-lah"
  final String exampleSentence;
  final String exampleTranslation;

  const LessonItem({
    required this.id,
    required this.categoryId,
    required this.term,
    required this.translation,
    required this.pronunciation,
    required this.exampleSentence,
    required this.exampleTranslation,
  });
}
