import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/auth_repository.dart';

class RecoverPasswordUseCase
    implements UseCase<Null, RecoverPasswordParams> {
  final AuthRepository repository;

  RecoverPasswordUseCase(this.repository);

  @override
  Future<Either<Failure, Null>> call(RecoverPasswordParams params) {
    return repository.recoverPassword(params.email);
  }
}

class RecoverPasswordParams extends Equatable {
  final String email;

  const RecoverPasswordParams({required this.email});

  @override
  List<Object?> get props => [email];
}
