import 'package:flutter/material.dart';
import '../services/flashcard_service.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  final FlashcardService _service = FlashcardService();
  List sessions = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  void load() async {
  try {
    final data = await _service.getStats();

    setState(() {
      sessions = data;
    });

  } catch (e) {
    print("Stats error: $e");
  }
}

 @override
Widget build(BuildContext context) {
  if (sessions.isEmpty) {
    return const Scaffold(
      body: Center(child: Text("No sessions yet")),
    );
  }

  double avgAccuracy = sessions
          .map((s) => s['accuracy'] as num)
          .reduce((a, b) => a + b) /
      sessions.length;

  return Scaffold(
    appBar: AppBar(title: const Text("Your Performance")),
    body: Column(
      children: [
        const SizedBox(height: 20),

        Text(
          "Average Accuracy: ${avgAccuracy.toStringAsFixed(1)}%",
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        const Divider(),

        Expanded(
          child: ListView.builder(
            itemCount: sessions.length,
            itemBuilder: (context, index) {
              final s = sessions[index];
              return ListTile(
                title: Text("Accuracy: ${s['accuracy']}%"),
                subtitle: Text(
                  "Correct: ${s['correct_answers']} | Wrong: ${s['wrong_answers']}",
                ),
              );
            },
          ),
        ),
      ],
    ),
  );
}
}