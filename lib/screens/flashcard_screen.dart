import 'package:ace/models/flashcard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/flashcard_provider.dart';

class FlashcardScreen extends ConsumerStatefulWidget {
  final String studyText;
  final int availableMinutes;
  final String difficulty;

  const FlashcardScreen({
    super.key,
    required this.studyText,
    required this.availableMinutes,
    required this.difficulty,
  });

  @override
  ConsumerState<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends ConsumerState<FlashcardScreen> {
  int currentIndex = 0;
  int correctCount = 0;

  // NEW: store answers
  List<bool> userAnswers = [];

  void _answer(bool userSaysCorrect, Flashcard card, int total) {
    final isUserRight = userSaysCorrect == card.isCorrect;

    // store result
    userAnswers.add(isUserRight);

    if (isUserRight) correctCount++;

    if (currentIndex < total - 1) {
      setState(() => currentIndex++);
    } else {
      _finishQuiz(total);
    }
  }

  Future<void> _finishQuiz(int total) async {
    final cardsAsync = ref.read(
      flashcardsProvider(
        (
          text: widget.studyText,
          minutes: widget.availableMinutes,
          difficulty: widget.difficulty,
        ),
      ),
    );

    final cards = cardsAsync.value;

    if (cards == null) {
      _showResult(total, null);
      return;
    }
try {
  final summary = await ref
      .read(flashcardServiceProvider)
      .saveSessionSummary(
        flashcards: cards,
        answers: userAnswers,
      );

  _showResult(total, summary);

} catch (e) {
  print("Failed to save session: $e");
  _showResult(total, null);
}
  }

  void _showResult(int total, Map<String, dynamic>? summary) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("Session Complete"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "You got $correctCount out of $total correct",
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            if (summary != null)
              Text(
                "Accuracy: ${summary["score_percent"]}%",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
          ],
        ),
        actions: [
         TextButton(
  onPressed: () {
    Navigator.of(context).popUntil((route) => route.isFirst);
  },
  child: const Text("OK"),
)
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final asyncCards = ref.watch(
      flashcardsProvider(
        (
          text: widget.studyText,
          minutes: widget.availableMinutes,
          difficulty: widget.difficulty,
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Flashcards"),
        centerTitle: true,
      ),
      body: asyncCards.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) =>
            Center(child: Text("Error: $e", style: const TextStyle(color: Colors.red))),
        data: (cards) {
          final card = cards[currentIndex];

          return Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    card.question,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    card.shownAnswer,
                    style: const TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Difficulty: ${card.difficulty}",
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 30),
                  Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            minimumSize: const Size(0, 50),
                    ),
                    onPressed: () => _answer(false, card, cards.length),
                    child: const Text(
            "Incorrect",
            style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
            
                const SizedBox(width: 16),
            
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            minimumSize: const Size(0, 50),
                    ),
                    onPressed: () => _answer(true, card, cards.length),
                    child: const Text(
            "Correct",
            style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
                  const SizedBox(height: 20),
                  Text(
                    "Card ${currentIndex + 1} of ${cards.length}",
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}