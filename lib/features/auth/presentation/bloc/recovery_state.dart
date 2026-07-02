import 'package:equatable/equatable.dart';

sealed class RecoveryState extends Equatable {
  const RecoveryState();

  @override
  List<Object?> get props => [];
}

class RecoveryInitial extends RecoveryState {
  const RecoveryInitial();
}

class RecoveryLoading extends RecoveryState {
  const RecoveryLoading();
}

class RecoveryEmailSent extends RecoveryState {
  final String email;

  const RecoveryEmailSent({required this.email});

  @override
  List<Object?> get props => [email];
}

class RecoveryPasswordReset extends RecoveryState {
  const RecoveryPasswordReset();
}

class RecoveryError extends RecoveryState {
  final String message;

  const RecoveryError({required this.message});

  @override
  List<Object?> get props => [message];
}
