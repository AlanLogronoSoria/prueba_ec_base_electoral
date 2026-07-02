import 'package:flutter/foundation.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/text_sanitizer.dart';
import '../repositories/provincial_repository.dart';

class CreateCoordinadorRecintoUseCase
    implements UseCase<Null, CreateCoordinadorRecintoParams> {
  final ProvincialRepository repository;

  CreateCoordinadorRecintoUseCase(this.repository);

  @override
  Future<Either<Failure, Null>> call(CreateCoordinadorRecintoParams params) {
    debugPrint('[UC:coord] cedula=${params.cedula} recintoId=${params.recintoId}');
    return repository.createCoordinadorRecinto(
      params.recintoId,
      params.cedula,
      TextSanitizer.sanitize(params.nombres),
      TextSanitizer.sanitize(params.apellidos),
      TextSanitizer.sanitize(params.telefono),
      TextSanitizer.sanitize(params.correo),
      params.creadoPor,
    );
  }
}

class CreateCoordinadorRecintoParams extends Equatable {
  final String recintoId;
  final String cedula;
  final String nombres;
  final String apellidos;
  final String telefono;
  final String correo;
  final String creadoPor;

  const CreateCoordinadorRecintoParams({
    required this.recintoId,
    required this.cedula,
    required this.nombres,
    required this.apellidos,
    required this.telefono,
    required this.correo,
    required this.creadoPor,
  });

  @override
  List<Object?> get props => [
        recintoId,
        cedula,
        nombres,
        apellidos,
        telefono,
        correo,
        creadoPor,
      ];
}
