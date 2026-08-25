/// Represents a language the user can learn.
class AppLanguage {
  final String code; // e.g. 'es', 'fr', 'ur'
  final String name; // e.g. 'Spanish'
  final String flagEmoji;

  const AppLanguage({
    required this.code,
    required this.name,
    required this.flagEmoji,
  });
}
