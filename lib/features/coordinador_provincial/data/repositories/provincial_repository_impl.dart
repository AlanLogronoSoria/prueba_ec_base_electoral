import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../../../features/veedor/domain/entities/acta.dart';
import '../../domain/entities/detalle_acta_completo.dart';
import '../../domain/entities/recinto.dart';
import '../../domain/entities/votos_consolidados.dart';
import '../../domain/repositories/provincial_repository.dart';
import '../datasources/provincial_remote_datasource.dart';

class ProvincialRepositoryImpl implements ProvincialRepository {
  final ProvincialRemoteDatasource remoteDatasource;

  ProvincialRepositoryImpl(this.remoteDatasource);

  @override
  Future<Either<Failure, List<Recinto>>> getRecintos() async {
    try {
      final recintos = await remoteDatasource.getRecintos();
      return Right(recintos);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<Recinto>>> getRecintosSinCoordinador() async {
    try {
      final recintos = await remoteDatasource.getRecintosSinCoordinador();
      return Right(recintos);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Recinto>> createRecinto(
    String canton,
    String parroquia,
    String nombre,
    String? numeroJrv,
  ) async {
    try {
      final recinto = await remoteDatasource.createRecinto(
        canton,
        parroquia,
        nombre,
        numeroJrv,
      );
      return Right(recinto);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Null>> createCoordinadorRecinto(
    String recintoId,
    String cedula,
    String nombres,
    String apellidos,
    String telefono,
    String correo,
    String creadoPor,
  ) async {
    try {
      await remoteDatasource.createCoordinadorRecinto(
        recintoId,
        cedula,
        nombres,
        apellidos,
        telefono,
        correo,
        creadoPor,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Map<String, int>>> getAvanceRecinto(
    String recintoId,
  ) async {
    try {
      final avance = await remoteDatasource.getAvanceRecinto(recintoId);
      return Right(avance);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<Acta>>> getActasPorRecinto(
    String recintoId,
  ) async {
    try {
      final actas = await remoteDatasource.getActasPorRecinto(recintoId);
      return Right(actas);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<VotosConsolidados>>> getVotosConsolidados(
    String? recintoId,
  ) async {
    try {
      final votos = await remoteDatasource.getVotosConsolidados(recintoId);
      return Right(votos);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, DetalleActaCompleto>> getDetalleActa(
    String actaId,
    String mesaId,
  ) async {
    try {
      final detalle = await remoteDatasource.getDetalleActa(actaId, mesaId);
      return Right(detalle);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
