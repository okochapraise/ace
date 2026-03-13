import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/flashcard.dart';
import '../services/flashcard_service.dart';

/// Service provider
final flashcardServiceProvider = Provider<FlashcardService>((ref) {
  return FlashcardService();
});

/// Flashcards generator
final flashcardsProvider = FutureProvider.family<
    List<Flashcard>,
    ({
      String text,
      int minutes,
      String difficulty,
    })>((ref, params) async {

  final service = ref.read(flashcardServiceProvider);

  return service.generateFlashcards(
    text: params.text,
    availableMinutes: params.minutes,
    difficulty: params.difficulty,
  );
});