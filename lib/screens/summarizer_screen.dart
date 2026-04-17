import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ace/providers/summarizer_provider.dart';
import 'package:ace/services/tts_service.dart';
import 'mood_screen.dart';

class SummarizerScreen extends ConsumerStatefulWidget {
  const SummarizerScreen({super.key, required this.extractedText});
  final String extractedText;

  @override
  ConsumerState<SummarizerScreen> createState() => _SummarizerScreenState();
}

class _SummarizerScreenState extends ConsumerState<SummarizerScreen> {
  final TtsService _tts = TtsService();
  bool isSpeaking = false;

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final summaryAsync = ref.watch(summarizerProvider(widget.extractedText));

    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Summarizer"),
        centerTitle: true,
        backgroundColor: Colors.red,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: summaryAsync.when(
          data: (summarized) {
            final summaryText = summarized.summary;

            return Column(
              children: [
                /// 📄 SUMMARY TEXT
                Expanded(
                  child: SingleChildScrollView(
                    child: Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          summaryText.isNotEmpty
                              ? summaryText
                              : "No summary available.",
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),


             Row(
  children: [
    Expanded(
      child: ElevatedButton.icon(
        icon: const Icon(Icons.volume_up),
        label: const Text(
          "Read Summary",
          overflow: TextOverflow.ellipsis,
        ),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        onPressed: summaryText.trim().isEmpty
            ? null
            : () async {
                setState(() => isSpeaking = true);
                await _tts.speak(summaryText);
                setState(() => isSpeaking = false);
              },
      ),
    ),

    const SizedBox(width: 12),

    Expanded(
      child: ElevatedButton.icon(
        icon: const Icon(Icons.stop),
        label: const Text("Stop"),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        onPressed: () async {
          setState(() => isSpeaking = false);
          await _tts.stop();
        },
      ),
    ),
  ],
),

                const SizedBox(height: 16),

           
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: summaryText.trim().isEmpty
                      ? null
                      : () {
                          _tts.stop(); 
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MoodScreen(
                                studyText: widget.extractedText,
                              ),
                            ),
                          );
                        },
                  child: const Text("Continue"),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Text(
              "⚠️ Failed to summarize:\n$e",
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
