import 'package:equatable/equatable.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class LoginRequested extends AuthEvent {
  final String cedula;
  final String email;
  final String password;
  final String? selectedRole;

  const LoginRequested({
    required this.cedula,
    required this.email,
    required this.password,
    this.selectedRole,
  });

  @override
  List<Object?> get props => [cedula, email, password, selectedRole];
}

class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

class ChangePasswordRequested extends AuthEvent {
  final String currentPassword;
  final String newPassword;

  const ChangePasswordRequested({
    required this.currentPassword,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [currentPassword, newPassword];
}

class RecoverPasswordRequested extends AuthEvent {
  final String email;

  const RecoverPasswordRequested({required this.email});

  @override
  List<Object?> get props => [email];
}

class CheckAuthStatus extends AuthEvent {
  const CheckAuthStatus();
}

class ResetAuthState extends AuthEvent {
  const ResetAuthState();
}
