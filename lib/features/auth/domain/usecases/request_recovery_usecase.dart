import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/auth_repository.dart';

class RequestRecoveryUseCase implements UseCase<String, RequestRecoveryParams> {
  final AuthRepository repository;

  RequestRecoveryUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(RequestRecoveryParams params) {
    return repository.requestPasswordReset(params.cedula);
  }
}

class RequestRecoveryParams extends Equatable {
  final String cedula;

  const RequestRecoveryParams({required this.cedula});

  @override
  List<Object?> get props => [cedula];
}
