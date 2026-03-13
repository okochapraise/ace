import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/studyplan_provider.dart';
import 'flashcard_screen.dart';

class StudyPlannerScreen extends ConsumerStatefulWidget {
  final String studyText;
  final String mood;

  const StudyPlannerScreen({
    super.key,
    required this.studyText,
    required this.mood,
  });

  @override
  ConsumerState<StudyPlannerScreen> createState() =>
      _StudyPlannerScreenState();
}

class _StudyPlannerScreenState
    extends ConsumerState<StudyPlannerScreen> {
  final TextEditingController minutesController =
      TextEditingController(text: "30");

  @override
  Widget build(BuildContext context) {
    final minutes = int.tryParse(minutesController.text);

    final planAsync = minutes == null
        ? null
        : ref.watch(
            studyPlannerProvider(
              (
                textLength: widget.studyText.length,
                minutes: minutes,
                mood: widget.mood,
              ),
            ),
          );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Smart Study Plan"),
        backgroundColor: Colors.red,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            /// INPUT TIME
            TextField(
              controller: minutesController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Available study minutes",
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),

            const SizedBox(height: 20),

            /// PLAN RESULT
            if (planAsync != null)
              Expanded(
                child: planAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) =>
                      Center(child: Text("Error: $e")),
                  data: (plan) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plan.message,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),

                      Expanded(
                        child: ListView.builder(
                          itemCount: plan.sessions.length,
                          itemBuilder: (_, i) {
                            final session = plan.sessions[i];

                            return Card(
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.red,
                                  child: Text(
                                    "${session.duration}m",
                                    style: const TextStyle(
                                        color: Colors.white),
                                  ),
                                ),
                                title: Text(session.activity),
                                subtitle: Text(
                                    "Difficulty: ${session.difficulty}"),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 10),

            /// CONTINUE BUTTON
            /// CONTINUE BUTTON
SizedBox(
  width: double.infinity,
  child: ElevatedButton(
    style: ElevatedButton.styleFrom(
      minimumSize: const Size.fromHeight(50),
      backgroundColor: Colors.red,
      foregroundColor: Colors.white,
    ),
    onPressed: () {
  planAsync?.whenData((plan) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FlashcardScreen(
          studyText: widget.studyText,
          availableMinutes:
              int.parse(minutesController.text),
          difficulty: plan.sessions.first.difficulty,
        ),
      ),
    );
  });
},
    child: const Text("Continue to Flashcards"),
  ),
),
          ],
        ),
      ),
    );
  }
}