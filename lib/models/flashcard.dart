class Flashcard {
  final String question;
  final String shownAnswer;
  final bool isCorrect;
  final String difficulty;

  Flashcard({
    required this.question,
    required this.shownAnswer,
    required this.isCorrect,
    required this.difficulty,
  });

  factory Flashcard.fromJson(Map<String, dynamic> json) {
    return Flashcard(
      question: json['question'],
      shownAnswer: json['shown_answer'],
      isCorrect: json['is_correct'],
      difficulty: json['difficulty'],
    );
  }

  Map<String, dynamic> toJson() {
  return {
    "question": question,
    "shown_answer": shownAnswer,
    "is_correct": isCorrect,
    "difficulty": difficulty,
  };
}
}
