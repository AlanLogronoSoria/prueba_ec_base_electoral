import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/veedor_repository.dart';

class SubirFotoActaUseCase
    implements UseCase<String, SubirFotoActaParams> {
  final VeedorRepository repository;

  SubirFotoActaUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(SubirFotoActaParams params) {
    return repository.subirFotoActa(params.filePath, params.actaId);
  }
}

class SubirFotoActaParams extends Equatable {
  final String filePath;
  final String actaId;

  const SubirFotoActaParams({
    required this.filePath,
    required this.actaId,
  });

  @override
  List<Object?> get props => [filePath, actaId];
}
