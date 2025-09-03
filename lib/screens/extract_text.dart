import 'package:flutter/material.dart';

class ExtractedTextScreen extends StatelessWidget {
  final String text;
  const ExtractedTextScreen({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Extracted Text")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: text.isEmpty
            ? const Center(child: Text("No text extracted"))
            : SingleChildScrollView(
                child: SelectableText(text), 
              ),
      ),
    );
  }
}
