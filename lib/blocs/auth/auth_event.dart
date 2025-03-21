import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:playce/models/user_model.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckStatusEvent extends AuthEvent {
  const AuthCheckStatusEvent();
}

class AuthSignInEvent extends AuthEvent {
  final String email;
  final String password;

  const AuthSignInEvent({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}

class AuthSignUpEvent extends AuthEvent {
  final String email;
  final String password;

  const AuthSignUpEvent({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}

class AuthCreateProfileEvent extends AuthEvent {
  final String username;
  final String fullName;
  final String bio;
  final bool isParent;
  final File? profileImage;

  const AuthCreateProfileEvent({
    required this.username,
    required this.fullName,
    required this.bio,
    required this.isParent,
    this.profileImage,
  });

  @override
  List<Object?> get props => [username, fullName, bio, isParent, profileImage];
}

class AuthUpdateProfileEvent extends AuthEvent {
  final UserModel user;

  const AuthUpdateProfileEvent({
    required this.user,
  });

  @override
  List<Object> get props => [user];
}

class AuthSignOutEvent extends AuthEvent {
  const AuthSignOutEvent();
} 