import 'package:ace/screens/ocr_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'services/auth_service.dart';
import 'screens/login_screen.dart';

class AuthGate extends ConsumerStatefulWidget {
  const AuthGate({super.key});

  @override
  ConsumerState<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends ConsumerState<AuthGate> {
  final AuthService _authService = AuthService();
  bool? isLoggedIn;

  @override
  void initState() {
    super.initState();
    checkLogin();
  }

  void checkLogin() async {
    final token = await _authService.getToken();
    setState(() {
      isLoggedIn = token != null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoggedIn == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return isLoggedIn!
        ? const UploadNotesScreen()
        : LoginScreen();
  }
}