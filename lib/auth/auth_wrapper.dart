// lib/features/auth/presentation/widgets/auth_wrapper.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:searchgpt/database/db/db.dart';
import 'auth_bloc.dart';
import 'auth_state.dart';

class AuthWrapper extends StatelessWidget {
  final AppDatabase db;
  final Widget authenticated;
  final Widget unauthenticated;

  const AuthWrapper({
    super.key,
    required this.db,
    required this.authenticated,
    required this.unauthenticated,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return switch (state) {
          AuthInitial() => const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
          AuthLoading() => const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
          Authenticated() => authenticated,
          Unauthenticated() => unauthenticated,
          AuthError() => Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${state.message}'),
                  const SizedBox(height: 16),
                  // ElevatedButton(
                  //   onPressed: () {
                  //     context.read<AuthBloc>().add(const AuthStatusChecked());
                  //   },
                  //   child: const Text('Retry'),
                  // ),
                ],
              ),
            ),
          ),
        };
      },
    );
  }
}
