import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/veedor_repository.dart';

class GetMesasVeedorUseCase
    implements UseCase<List<Map<String, dynamic>>, GetMesasVeedorParams> {
  final VeedorRepository repository;

  GetMesasVeedorUseCase(this.repository);

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> call(
      GetMesasVeedorParams params) {
    return repository.getMesasVeedor(params.veedorId);
  }
}

class GetMesasVeedorParams extends Equatable {
  final String veedorId;

  const GetMesasVeedorParams({required this.veedorId});

  @override
  List<Object?> get props => [veedorId];
}
