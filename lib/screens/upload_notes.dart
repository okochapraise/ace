import 'dart:io';
import 'package:ace/providers/upload_notes_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'extract_text.dart';

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
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () async {
                showModalBottomSheet(
                  context: context,
                  builder: (_) => Wrap(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.image),
                        title: const Text("Pick Image"),
                        onTap: () async {
                          Navigator.pop(context);
                          await ocrNotifier.pickImage();
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.picture_as_pdf),
                        title: const Text("Pick PDF"),
                        onTap: () async {
                          Navigator.pop(context);
                          await ocrNotifier.pickPdf();
                        },
                      ),
                    ],
                  ),
                );
              },
              child: const Text("Select File"),
            ),
            const SizedBox(height: 10),

            // Show preview of selected file
            if (selectedFile != null)
              Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: selectedFile.path.toLowerCase().endsWith('.pdf')
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.picture_as_pdf,
                                size: 50, color: Colors.red),
                            Text(
                              selectedFile.path.split('/').last,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      )
                    : Image.file(
                        File(selectedFile.path),
                        fit: BoxFit.cover,
                      ),
              ),
            const SizedBox(height: 10),

            ElevatedButton(
  onPressed: selectedFile == null
      ? null
      : () async {
          final extractedText = await ocrNotifier.extractText();
          if (context.mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ExtractedTextScreen(
                  text: extractedText,
                ),
              ),
            );
          }
        },
  child: const Text("Extract Text"),
)

          ],
        ),
      ),
    );
  }
}
