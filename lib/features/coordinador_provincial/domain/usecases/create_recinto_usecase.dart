import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/text_sanitizer.dart';
import '../entities/recinto.dart';
import '../repositories/provincial_repository.dart';

class CreateRecintoUseCase
    implements UseCase<Recinto, CreateRecintoParams> {
  final ProvincialRepository repository;

  CreateRecintoUseCase(this.repository);

  @override
  Future<Either<Failure, Recinto>> call(CreateRecintoParams params) {
    return repository.createRecinto(
      TextSanitizer.sanitize(params.canton),
      TextSanitizer.sanitize(params.parroquia),
      TextSanitizer.sanitize(params.nombre),
      params.numeroJrv,
    );
  }
}

class CreateRecintoParams extends Equatable {
  final String canton;
  final String parroquia;
  final String nombre;
  final String? numeroJrv;

  const CreateRecintoParams({
    required this.canton,
    required this.parroquia,
    required this.nombre,
    this.numeroJrv,
  });

  @override
  List<Object?> get props => [canton, parroquia, nombre, numeroJrv];
}
