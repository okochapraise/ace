import 'package:ace/screens/studyplan_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/mood_provider.dart';


class MoodScreen extends ConsumerStatefulWidget {
  final String studyText;

  const MoodScreen({
    super.key,
    required this.studyText,
  });

  @override
  ConsumerState<MoodScreen> createState() => _MoodScreenState();
}

class _MoodScreenState extends ConsumerState<MoodScreen> {
  String? selectedMood;

  final moods = [
    "happy",
    "tired",
    "stressed",
    "neutral",
  ];

  Future<void> openSpotify(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception("Could not open Spotify");
    }
  }

  @override
  Widget build(BuildContext context) {
    final recommendationAsync = selectedMood == null
        ? null
        : ref.watch(moodProvider(selectedMood!));

    return Scaffold(
      appBar: AppBar(
        title: const Text("How are you feeling?"),
        backgroundColor: Colors.red,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            /// MOOD SELECTION (VERTICAL)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: moods.map((mood) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ChoiceChip(
                    label: Text(
                      mood.toUpperCase(),
                      style: const TextStyle(fontSize: 16),
                    ),
                    selected: selectedMood == mood,
                    selectedColor: Colors.red.shade200,
                    onSelected: (_) {
                      setState(() {
                        selectedMood = mood;
                      });
                    },
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 25),

            /// RECOMMENDATION RESULT
            if (recommendationAsync != null)
              Expanded(
                child: recommendationAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text("Error: $e")),
                  data: (rec) => SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// ACTIVITY CARD
                        Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Recommended Activity",
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 10),
                                Text(rec.activity),
                                const SizedBox(height: 20),
                                Text(
                                  "Reason",
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 10),
                                Text(rec.reason),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        /// ENCOURAGEMENT CARD
                        Card(
                          color: Colors.orange.shade50,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                const Icon(Icons.auto_awesome,
                                    color: Colors.orange),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    rec.encouragement,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        /// MUSIC LABEL
                        Text(
                          rec.music.query,
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontStyle: FontStyle.italic,
                          ),
                        ),

                        const SizedBox(height: 10),

                        /// SPOTIFY BUTTON
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () =>
                                openSpotify(rec.music.spotifyUrl),
                            icon: const Icon(Icons.headphones),
                            label: const Text("Open in Spotify"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1DB954),
                              foregroundColor: Colors.white,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 3,
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),

                        /// CONTINUE BUTTON
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(50),
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                 builder: (_) => StudyPlannerScreen(
  studyText: widget.studyText,
  mood: selectedMood!,
),
                                ),
                              );
                            },
                            child: const Text("Continue to Study Plan"),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}