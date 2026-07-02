import 'package:flutter/foundation.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/recinto_repository.dart';

class CreateVeedorUseCase implements UseCase<String, CreateVeedorParams> {
  final RecintoRepository repository;

  CreateVeedorUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(CreateVeedorParams params) {
    debugPrint('[UC:veedor] cedula=${params.cedula} mesaId=${params.mesaId}');
    return repository.createVeedor(
      params.cedula,
      params.nombres,
      params.apellidos,
      params.telefono,
      params.correo,
      params.creadoPor,
      params.mesaId,
    );
  }
}

class CreateVeedorParams extends Equatable {
  final String cedula;
  final String nombres;
  final String apellidos;
  final String telefono;
  final String correo;
  final String creadoPor;
  final String? mesaId;

  const CreateVeedorParams({
    required this.cedula,
    required this.nombres,
    required this.apellidos,
    required this.telefono,
    required this.correo,
    required this.creadoPor,
    this.mesaId,
  });

  @override
  List<Object?> get props => [
        cedula,
        nombres,
        apellidos,
        telefono,
        correo,
        creadoPor,
        mesaId,
      ];
}
