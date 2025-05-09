import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:searchgpt/auth/auth_bloc.dart';
import 'package:searchgpt/auth/auth_event.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome to Search GPT'),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                context.read<AuthBloc>().add(const GoogleSignInRequested());
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.login),
                  SizedBox(width: 8),
                  Text('Sign in with Google'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
