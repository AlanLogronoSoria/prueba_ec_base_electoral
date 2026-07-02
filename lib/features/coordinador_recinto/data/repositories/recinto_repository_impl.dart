import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../../../features/veedor/domain/entities/acta.dart';
import '../../../../features/veedor/domain/entities/organizacion_politica.dart';
import '../../domain/entities/mesa.dart';
import '../../domain/repositories/recinto_repository.dart';
import '../datasources/recinto_remote_datasource.dart';

class RecintoRepositoryImpl implements RecintoRepository {
  final RecintoRemoteDatasource remoteDatasource;

  RecintoRepositoryImpl(this.remoteDatasource);

  @override
  Future<Either<Failure, List<Mesa>>> getMesas(String recintoId) async {
    try {
      final mesas = await remoteDatasource.getMesas(recintoId);
      return Right(mesas);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, String>> createVeedor(
    String cedula,
    String nombres,
    String apellidos,
    String telefono,
    String correo,
    String creadoPor,
    String? mesaId,
  ) async {
    try {
      final veedorId = await remoteDatasource.createVeedor(
        cedula,
        nombres,
        apellidos,
        telefono,
        correo,
        creadoPor,
        mesaId,
      );
      return Right(veedorId);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Null>> asignarVeedor(
    String mesaId,
    String veedorCedula,
  ) async {
    try {
      await remoteDatasource.asignarVeedor(mesaId, veedorCedula);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<OrganizacionPolitica>>>
      getOrganizaciones() async {
    try {
      final organizaciones =
          await remoteDatasource.getOrganizaciones();
      return Right(organizaciones);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Acta>> getActaPorMesa(String mesaId) async {
    try {
      final acta = await remoteDatasource.getActaPorMesa(mesaId);
      return Right(acta);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Null>> corregirActa(
    String actaId,
    int totalSufragantes,
    int votosNulos,
    int votosBlancos,
    Map<String, int> votosPorOrganizacion,
    String modificadoPor,
  ) async {
    try {
      await remoteDatasource.corregirActa(
        actaId,
        totalSufragantes,
        votosNulos,
        votosBlancos,
        votosPorOrganizacion,
        modificadoPor,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, String>> subirFotoActa(
      String filePath, String actaId) async {
    try {
      final fotoUrl =
          await remoteDatasource.subirFotoActa(filePath, actaId);
      return Right(fotoUrl);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Map<String, int>>> getAvance(
      String recintoId) async {
    try {
      final avance = await remoteDatasource.getAvance(recintoId);
      return Right(avance);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
