import 'package:equatable/equatable.dart';
import '../../domain/entities/usuario.dart';

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

class AuthAuthenticated extends AuthState {
  final Usuario usuario;

  const AuthAuthenticated({required this.usuario});

  @override
  List<Object?> get props => [usuario];
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object?> get props => [message];
}

class AuthRequiresPasswordChange extends AuthState {
  final Usuario usuario;

  const AuthRequiresPasswordChange({required this.usuario});

  @override
  List<Object?> get props => [usuario];
}
