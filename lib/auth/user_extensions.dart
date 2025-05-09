// lib/features/auth/domain/extensions/user_extensions.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';

@immutable
class UserData {
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoURL;

  const UserData({
    required this.uid,
    this.email,
    this.displayName,
    this.photoURL,
  });

  // Add toJson method
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
    };
  }

  // Add fromJson factory
  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      uid: json['uid'] as String,
      email: json['email'] as String?,
      displayName: json['displayName'] as String?,
      photoURL: json['photoURL'] as String?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserData &&
        other.uid == uid &&
        other.email == email &&
        other.displayName == displayName &&
        other.photoURL == photoURL;
  }

  @override
  int get hashCode {
    return uid.hashCode ^
        email.hashCode ^
        displayName.hashCode ^
        photoURL.hashCode;
  }
}

extension UserSerialization on User {
  UserData toUserData() {
    return UserData(
      uid: uid,
      email: email,
      displayName: displayName,
      photoURL: photoURL,
    );
  }
}
