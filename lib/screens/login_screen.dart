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
  padding: const EdgeInsets.all(24),
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [

      const Icon(
        Icons.school,
        size: 70,
        color: Colors.red,
      ),

      const SizedBox(height: 16),

      const Text(
        "ACE",
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
      ),

      const SizedBox(height: 40),

      TextField(
        controller: _email,
        decoration: const InputDecoration(
          labelText: "Email",
          prefixIcon: Icon(Icons.email),
        ),
      ),

      const SizedBox(height: 16),

      TextField(
        controller: _password,
        obscureText: true,
        decoration: const InputDecoration(
          labelText: "Password",
          prefixIcon: Icon(Icons.lock),
        ),
      ),

      const SizedBox(height: 24),

      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _login,
          child: const Text("Login"),
        ),
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
        child: const Text("Create an account"),
      ),
    ],
  ),
),
    );
  }
}