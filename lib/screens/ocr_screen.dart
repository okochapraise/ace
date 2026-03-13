import 'dart:io';
import 'package:ace/providers/ocr_provider.dart';
import 'package:ace/screens/login_screen.dart';
import 'package:ace/screens/stat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'extract_text.dart';
import 'package:ace/providers/auth_provider.dart';

class UploadNotesScreen extends ConsumerWidget {
  const UploadNotesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ocrState = ref.watch(ocrNotifierProvider);
    final ocrNotifier = ref.read(ocrNotifierProvider.notifier);
    final selectedFile = ocrState.selectedFile;

    return Scaffold(
      appBar: AppBar(
  title: const Text("Upload / Scan Notes"),
  centerTitle: true,
  backgroundColor: Colors.red,
  actions: [
     IconButton(
    icon: const Icon(Icons.bar_chart),
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const StatsScreen(),
        ),
      );
    },
  ),
    IconButton(
      icon: const Icon(Icons.logout),
      onPressed: () async {
        await ref.read(authServiceProvider).logout();
        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => LoginScreen()),
          );
        }
      },
    ),
  ],
  
),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              onPressed: () => _showFilePicker(context, ocrNotifier),
              icon: const Icon(Icons.upload_file),
              label: const Text("Select File"),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Selected file preview
            if (selectedFile != null) _FilePreview(file: selectedFile),
            if (selectedFile != null) const SizedBox(height: 20),

            ElevatedButton(
              onPressed: selectedFile == null
                  ? null
                  : () async {
                      final result = await ocrNotifier.extractText();
                      if (context.mounted && result != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ExtractedTextScreen(
                              text: result.text, // ✅ use OcrResult.text
                            ),
                          ),
                        );
                      }
                    },
              child: const Text("Extract Text"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: selectedFile != null
                    ? Colors.red
                    : Colors.grey,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Show OCR progress/errors in UI
            ocrState.extractedResult.when(
              data: (result) => result.text.isNotEmpty
                  ? Text(
                      "✅ Extracted: ${result.text.substring(0, result.text.length > 50 ? 50 : result.text.length)}...",
                      style: const TextStyle(color: Colors.green),
                    )
                  : const SizedBox(),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text(
                "⚠️ Error: $e",
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilePicker(BuildContext context, OcrNotifier notifier) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.image),
            title: const Text("Pick Image"),
            onTap: () async {
              Navigator.pop(context);
              await notifier.pickImage();
            },
          ),
          ListTile(
            leading: const Icon(Icons.picture_as_pdf),
            title: const Text("Pick PDF"),
            onTap: () async {
              Navigator.pop(context);
              await notifier.pickPdf();
            },
          ),
        ],
      ),
    );
  }
}

class _FilePreview extends StatelessWidget {
  final File file;
  const _FilePreview({required this.file});

  @override
  Widget build(BuildContext context) {
    final isPdf = file.path.toLowerCase().endsWith('.pdf');

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Container(
        height: 160,
        padding: const EdgeInsets.all(12),
        child: isPdf
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.picture_as_pdf, size: 50, color: Colors.red),
                  const SizedBox(height: 10),
                  Text(
                    file.path.split('/').last,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(file, fit: BoxFit.cover),
              ),
      ),
    );
  }
}
