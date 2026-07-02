import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/text_sanitizer.dart';
import '../entities/usuario.dart';
import '../repositories/auth_repository.dart';

class CreateUserUseCase implements UseCase<Usuario, CreateUserParams> {
  final AuthRepository repository;

  CreateUserUseCase(this.repository);

  @override
  Future<Either<Failure, Usuario>> call(CreateUserParams params) {
    return repository.createUser(CreateUserParams(
      cedula: params.cedula,
      nombres: TextSanitizer.sanitize(params.nombres),
      apellidos: TextSanitizer.sanitize(params.apellidos),
      telefono: TextSanitizer.sanitize(params.telefono),
      correo: TextSanitizer.sanitize(params.correo),
      rol: params.rol,
      creadoPor: params.creadoPor,
      recintoId: params.recintoId,
    ));
  }
}

class CreateUserParams extends Equatable {
  final String cedula;
  final String nombres;
  final String apellidos;
  final String telefono;
  final String correo;
  final String rol;
  final String creadoPor;
  final String? recintoId;

  const CreateUserParams({
    required this.cedula,
    required this.nombres,
    required this.apellidos,
    required this.telefono,
    required this.correo,
    required this.rol,
    required this.creadoPor,
    this.recintoId,
  });

  @override
  List<Object?> get props => [
        cedula,
        nombres,
        apellidos,
        telefono,
        correo,
        rol,
        creadoPor,
        recintoId,
      ];
}
