// lib/features/auth/presentation/bloc/auth_bloc.dart
import 'dart:async';

import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:equatable/equatable.dart';
import 'package:dartz/dartz.dart';
import 'package:searchgpt/auth/user_extensions.dart';
import 'auth_repository.dart';
import 'auth_state.dart';
import 'auth_event.dart';

class AuthBloc extends HydratedBloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  StreamSubscription<User?>? _authSubscription;

  AuthBloc({required AuthRepository authRepository})
    : _authRepository = authRepository,
      super(const AuthInitial()) {
    on<GoogleSignInRequested>(_onGoogleSignInRequested);
    on<SignOutRequested>(_onSignOutRequested);
    on<AuthStatusChecked>(_onAuthStatusChecked);

    // Listen to authentication state changes
    _authSubscription = _authRepository.authStateChanges.listen((user) {
      if (user != null) {
        add(const AuthStatusChecked());
      } else {
        add(const AuthStatusChecked());
      }
    });
  }

  Future<void> _onGoogleSignInRequested(
    GoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _authRepository.signInWithGoogle();
    result.fold(
      (error) => emit(AuthError(error.toString())),
      (user) => emit(Authenticated(user.toUserData())),
    );
  }

  Future<void> _onAuthStatusChecked(
    AuthStatusChecked event,
    Emitter<AuthState> emit,
  ) async {
    final user = _authRepository.auth.currentUser;
    emit(
      user != null ? Authenticated(user.toUserData()) : const Unauthenticated(),
    );
  }

  Future<void> _onSignOutRequested(
    SignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    await _authRepository.signOut();
    emit(const Unauthenticated());
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }

  @override
  AuthState? fromJson(Map<String, dynamic> json) {
    try {
      final userJson = json['user'];
      if (userJson != null) {
        return Authenticated(UserData.fromJson(userJson));
      }
      return const Unauthenticated();
    } catch (e, stackTrace) {
      // Add proper error logging here in production
      return AuthError('Failed to restore auth state', stackTrace);
    }
  }

  @override
  Map<String, dynamic>? toJson(AuthState state) {
    if (state is Authenticated) {
      return {'user': state.userData.toJson()};
    }
    return {'user': null};
  }
}
