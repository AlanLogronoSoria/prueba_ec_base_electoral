import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/veedor_repository.dart';

class GetOrganizacionesUseCase
    implements UseCase<List<Map<String, dynamic>>, NoParams> {
  final VeedorRepository repository;

  GetOrganizacionesUseCase(this.repository);

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> call(NoParams params) {
    return repository.getOrganizaciones();
  }
}
