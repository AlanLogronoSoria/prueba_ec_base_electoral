import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/recinto_repository.dart';

class AsignarVeedorUseCase implements UseCase<Null, AsignarVeedorParams> {
  final RecintoRepository repository;

  AsignarVeedorUseCase(this.repository);

  @override
  Future<Either<Failure, Null>> call(AsignarVeedorParams params) {
    return repository.asignarVeedor(params.mesaId, params.veedorCedula);
  }
}

class AsignarVeedorParams extends Equatable {
  final String mesaId;
  final String veedorCedula;

  const AsignarVeedorParams({
    required this.mesaId,
    required this.veedorCedula,
  });

  @override
  List<Object?> get props => [mesaId, veedorCedula];
}
