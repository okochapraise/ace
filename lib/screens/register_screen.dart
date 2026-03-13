import 'package:ace/auth_gate.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthService _authService = AuthService();
  final _email = TextEditingController();
  final _password = TextEditingController();

  void _register() async {
  final success = await _authService.register(
    _email.text,
    _password.text,
  );

  if (success && context.mounted) {
  await _authService.login(_email.text, _password.text);

  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (_) => const AuthGate()),
  );
}
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: _email, decoration: const InputDecoration(labelText: "Email")),
            TextField(controller: _password, decoration: const InputDecoration(labelText: "Password"), obscureText: true),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _register, child: const Text("Create Account")),
          ],
        ),
      ),
    );
  }
}