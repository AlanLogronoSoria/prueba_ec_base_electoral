import 'package:equatable/equatable.dart';

sealed class RecoveryEvent extends Equatable {
  const RecoveryEvent();

  @override
  List<Object?> get props => [];
}

class RequestPasswordReset extends RecoveryEvent {
  final String cedula;

  const RequestPasswordReset({required this.cedula});

  @override
  List<Object?> get props => [cedula];
}

class CompletePasswordReset extends RecoveryEvent {
  final String userId;
  final String secret;
  final String newPassword;

  const CompletePasswordReset({
    required this.userId,
    required this.secret,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [userId, secret, newPassword];
}

class ResetRecoveryState extends RecoveryEvent {
  const ResetRecoveryState();
}
