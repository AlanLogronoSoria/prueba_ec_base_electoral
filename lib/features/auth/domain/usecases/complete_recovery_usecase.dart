import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/auth_repository.dart';

class CompleteRecoveryUseCase implements UseCase<Null, CompleteRecoveryParams> {
  final AuthRepository repository;

  CompleteRecoveryUseCase(this.repository);

  @override
  Future<Either<Failure, Null>> call(CompleteRecoveryParams params) {
    return repository.completePasswordReset(
      params.userId,
      params.secret,
      params.newPassword,
    );
  }
}

class CompleteRecoveryParams extends Equatable {
  final String userId;
  final String secret;
  final String newPassword;

  const CompleteRecoveryParams({
    required this.userId,
    required this.secret,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [userId, secret, newPassword];
}
