import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/usuario.dart';
import '../usecases/create_user_usecase.dart';
import '../usecases/login_usecase.dart';

abstract class AuthRepository {
  Future<Either<Failure, Usuario>> login(LoginParams params);
  Future<Either<Failure, Null>> logout();
  Future<Either<Failure, Usuario>> getCurrentUser();
  Future<Either<Failure, Usuario>> createUser(CreateUserParams params);
  Future<Either<Failure, Null>> changePassword(
      String currentPassword, String newPassword);
  Future<Either<Failure, Null>> recoverPassword(String email);
  Future<Either<Failure, String>> requestPasswordReset(String cedula);
  Future<Either<Failure, Null>> completePasswordReset(
      String userId, String secret, String newPassword);
}
