import 'package:flutter/material.dart';
import 'package:mygainz/widgets/input_field.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _handleLogin() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    print('Email: $email');
    print('Password: $password');

    // TODO: Replace with actual login logic
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Image.asset(
                'assets/logo.png', // Replace with your asset path
                height: 180,
              ),
              const SizedBox(height: 16),
              const Text(
                "Your Workouts, Your Way.",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'LeagueSpartan',
                ),
              ),
              CustomInputField(
                icon: Icons.email,
                hintText: "Email",
                controller: _emailController,
              ),
              const SizedBox(height: 16),
              CustomInputField(
                icon: Icons.lock,
                hintText: "Password",
                controller: _passwordController,
                obscure: true,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  _handleLogin();
                },
                child: const Text(
                  'Login',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'LeagueSpartan',
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/register');
                },
                child: const Text(
                  "Not a member? Register",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'LeagueSpartan',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
