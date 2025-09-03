import 'package:ace/screens/upload_notes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; 

void main() {
  runApp(
    const ProviderScope( 
      child: AIStudyCompanionApp(),
    ),
  );
}

class AIStudyCompanionApp extends StatelessWidget {
  const AIStudyCompanionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ACE',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const UploadNotesScreen(),
    );
  }
}
