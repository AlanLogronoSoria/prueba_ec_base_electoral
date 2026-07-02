import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/usuario.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase implements UseCase<Usuario, LoginParams> {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  @override
  Future<Either<Failure, Usuario>> call(LoginParams params) {
    return repository.login(params);
  }
}

class LoginParams extends Equatable {
  final String cedula;
  final String email;
  final String password;

  const LoginParams({
    required this.cedula,
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [cedula, email, password];
}
