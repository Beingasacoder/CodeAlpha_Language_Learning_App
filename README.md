# Language Learning App

A Flutter app for learning vocabulary, phrases, and grammar in a
selected language, with flashcards, quizzes, and locally-persisted
progress tracking.

## Features

- **Language selection** — Spanish, French, or Urdu seeded out of the box
  (see `lib/data/sample_data.dart` to add more or replace with your own
  content/backend).
- **Categories** — Basic Vocabulary, Food & Dining, Travel Phrases, Grammar
  Basics per language.
- **Flashcards** — flip cards showing term → translation, pronunciation
  guide, and an example sentence. Marking a card "Got it!" persists it as
  learned.
- **Quizzes** — auto-generated multiple-choice practice tests per category,
  with a results screen and best-score tracking.
- **Progress screen** — overall and per-category completion, plus best quiz
  scores.
- **Local persistence** — `shared_preferences` stores the selected
  language, learned flashcard IDs, and quiz scores across app restarts. No
  backend required.

## Architecture (MVVM)

```
lib/
  models/       # Plain data classes: AppLanguage, LearningCategory, LessonItem, QuizQuestion
  data/         # SampleData — seeded content (swap for an API/Firebase source later)
  providers/    # ViewModels: LanguageProvider, ProgressProvider (ChangeNotifier)
  screens/      # Views: one file per screen
  widgets/      # Reusable view components: FlashcardWidget, CategoryCard
  utils/        # AppTheme
```

- **Models** are pure data, no logic.
- **Providers** are the ViewModel layer — they own state, talk to
  `shared_preferences`, and expose data/actions to screens via
  `ChangeNotifier` + `provider`.
- **Screens/widgets** are the View layer — they only read from providers
  via `context.watch`/`context.read` and never touch storage directly.

## Adding Firebase later

Progress tracking is written entirely inside `ProgressProvider` and
`LanguageProvider`. To move from local-only to Firebase sync, swap the
`shared_preferences` calls in those two files for Firestore reads/writes
— no screen code needs to change, since screens only depend on the
provider API surface.

## Getting started

```bash
flutter pub get
flutter run
```

Requires Flutter 3.x (Dart 3+). Tested against Material 3.
