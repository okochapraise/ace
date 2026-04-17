import 'package:ace/auth_gate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';



Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  
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
      title: 'AI Study Companion',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
  scaffoldBackgroundColor: Colors.white,

  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.red,
    primary: Colors.red,
  ),

  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    foregroundColor: Colors.black,
    elevation: 0,
    centerTitle: true,
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.red,
      foregroundColor: Colors.white,
      elevation: 2,
      padding: const EdgeInsets.symmetric(vertical: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    ),
  ),

  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
    ),
  ),

  cardTheme: const CardThemeData(
  elevation: 3,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(16)),
  ),
),
),
      home: const AuthGate(),
    );
  }
}
