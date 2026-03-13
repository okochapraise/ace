import 'package:ace/screens/ocr_screen.dart';
import 'package:ace/screens/register_screen.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';


class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  void _login() async {
    bool success = await _authService.login(
      _email.text,
      _password.text,
    );

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => UploadNotesScreen()),
      );
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Login failed")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    TextField(
      controller: _email,
      decoration: const InputDecoration(labelText: "Email"),
    ),
    TextField(
      controller: _password,
      decoration: const InputDecoration(labelText: "Password"),
      obscureText: true,
    ),
    const SizedBox(height: 20),

    ElevatedButton(
      onPressed: _login,
      child: const Text("Login"),
    ),

    const SizedBox(height: 16),

    TextButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const RegisterScreen(),
          ),
        );
      },
      child: const Text("Don't have an account? Register"),
    ),
  ],
)
      ),
    );
  }
}