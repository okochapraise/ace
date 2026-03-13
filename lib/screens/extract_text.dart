import 'package:flutter/material.dart';
import '../services/tts_service.dart';
import 'summarizer_screen.dart';

class ExtractedTextScreen extends StatefulWidget {
  final String text;
  const ExtractedTextScreen({super.key, required this.text});

  @override
  State<ExtractedTextScreen> createState() => _ExtractedTextScreenState();
}

class _ExtractedTextScreenState extends State<ExtractedTextScreen> {
  final TtsService _tts = TtsService();
  bool isSpeaking = false;

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Extracted Text"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// 📄 EXTRACTED TEXT
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  widget.text,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),

            const SizedBox(height: 16),

            /// 🔊 TTS CONTROLS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: Icon(isSpeaking ? Icons.volume_up : Icons.volume_up),
                  label: const Text("Read Aloud"),
                  onPressed: widget.text.trim().isEmpty
                      ? null
                      : () async {
                          setState(() => isSpeaking = true);
                          await _tts.speak(widget.text);
                          setState(() => isSpeaking = false);
                        },
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.stop),
                  label: const Text("Stop"),
                  onPressed: () async {
                    setState(() => isSpeaking = false);
                    await _tts.stop();
                  },
                ),
              ],
            ),

            const SizedBox(height: 16),

            /// ➡️ GO TO SUMMARIZER
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: widget.text.trim().isEmpty
                  ? null
                  : () {
                      _tts.stop(); // stop reading before navigating
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SummarizerScreen(
                            extractedText: widget.text,
                          ),
                        ),
                      );
                    },
              child: const Text("Summarize Text"),
            ),
          ],
        ),
      ),
    );
  }
}
