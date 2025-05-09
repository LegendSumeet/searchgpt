// lib/features/auth/domain/auth_state.dart
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:searchgpt/auth/user_extensions.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class Authenticated extends AuthState {
  final UserData userData;

  const Authenticated(this.userData);

  // Helper constructor from Firebase User
  factory Authenticated.fromUser(User user) {
    return Authenticated(
      UserData(
        uid: user.uid,
        email: user.email,
        displayName: user.displayName,
        photoURL: user.photoURL,
      ),
    );
  }

  @override
  List<Object?> get props => [userData];
}

class Unauthenticated extends AuthState {
  const Unauthenticated();
}

class AuthError extends AuthState {
  final String message;
  final StackTrace? stackTrace;

  const AuthError(this.message, [this.stackTrace]);

  @override
  List<Object?> get props => [message, stackTrace];
}
