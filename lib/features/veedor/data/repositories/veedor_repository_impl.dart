import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/acta.dart';
import '../../domain/repositories/veedor_repository.dart';
import '../datasources/veedor_local_datasource.dart';
import '../datasources/veedor_remote_datasource.dart';
import '../models/acta_pendiente_model.dart';

class VeedorRepositoryImpl implements VeedorRepository {
  final VeedorRemoteDatasource remoteDatasource;
  final VeedorLocalDatasource localDatasource;

  VeedorRepositoryImpl(this.remoteDatasource, this.localDatasource);

  String _generateLocalId() =>
      'local_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(99999)}';

  bool _isLocalId(String id) => id.startsWith('local_');

  bool _isNetworkError(ServerException e) {
    final msg = e.message.toLowerCase();
    return msg.contains('socket') ||
        msg.contains('connection refused') ||
        msg.contains('connection timed out') ||
        msg.contains('network') ||
        msg.contains('host') ||
        msg.contains('dns') ||
        msg.contains('timeout') ||
        e.code == null ||
        e.code == 0;
  }

  bool _isPermissionError(ServerException e) {
    return e.code == 401 || e.code == 403;
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getMesasVeedor(
    String veedorId,
  ) async {
    try {
      final mesas = await remoteDatasource.getMesasVeedor(veedorId);
      return Right(mesas);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Acta>> registrarActa(
    String mesaId,
    String dignidad,
    int totalSufragantes,
    int votosNulos,
    int votosBlancos,
    double gpsLatitud,
    double gpsLongitud,
    String registradoPor,
    Map<String, int> votosPorOrganizacion,
  ) async {
    try {
      final acta = await remoteDatasource.registrarActa(
        mesaId,
        dignidad,
        totalSufragantes,
        votosNulos,
        votosBlancos,
        gpsLatitud,
        gpsLongitud,
        registradoPor,
        votosPorOrganizacion,
      );
      return Right(acta);
    } on ServerException catch (e) {
      if (_isPermissionError(e)) {
        debugPrint('[REPO:veedor] PERMISSION DENIED — code=${e.code} type=${e.type} msg=${e.message}');
        return Left(PermissionFailure(e.message));
      }
      if (!_isNetworkError(e)) {
        debugPrint('[REPO:veedor] SERVER ERROR — code=${e.code} type=${e.type} msg=${e.message}');
        return Left(ServerFailure(e.message));
      }

      debugPrint('[REPO:veedor] OFFLINE FALLBACK — motivo: ${e.message}');
      try {
        final localId = _generateLocalId();
        final pendiente = ActaPendienteModel(
          localId: localId,
          mesaId: mesaId,
          dignidad: dignidad,
          totalSufragantes: totalSufragantes,
          votosNulos: votosNulos,
          votosBlancos: votosBlancos,
          gpsLatitud: gpsLatitud,
          gpsLongitud: gpsLongitud,
          registradoPor: registradoPor,
          votosPorOrganizacion: Map.from(votosPorOrganizacion),
          syncStatus: 'pendiente',
        );
        await localDatasource.guardarPendiente(pendiente);
        return Right(Acta(
          id: localId,
          mesaId: mesaId,
          dignidad: dignidad,
          totalSufragantes: totalSufragantes,
          votosNulos: votosNulos,
          votosBlancos: votosBlancos,
          gpsLatitud: gpsLatitud,
          gpsLongitud: gpsLongitud,
          registradoPor: registradoPor,
          estado: 'pendiente_sync',
        ));
      } catch (localError) {
        return Left(const ServerFailure('Error sin conexión. No se pudo guardar localmente.'));
      }
    }
  }

  @override
  Future<Either<Failure, String>> subirFotoActa(
    String filePath,
    String actaId,
  ) async {
    if (_isLocalId(actaId)) {
      try {
        await localDatasource.actualizarEstado(
          actaId,
          fotoLocalPath: filePath,
        );
        return Right('local:$actaId');
      } catch (e) {
        return Left(const ServerFailure('Error al guardar foto localmente'));
      }
    }

    try {
      final url = await remoteDatasource.subirFotoActa(filePath, actaId);
      return Right(url);
    } on ServerException catch (e) {
      if (_isPermissionError(e)) {
        debugPrint('[REPO:veedor] subirFoto PERMISSION DENIED — code=${e.code} type=${e.type} msg=${e.message}');
        return Left(PermissionFailure(e.message));
      }
      if (!_isNetworkError(e)) {
        debugPrint('[REPO:veedor] subirFoto SERVER ERROR — code=${e.code} type=${e.type} msg=${e.message}');
        return Left(ServerFailure(e.message));
      }

      debugPrint('[REPO:veedor] subirFoto OFFLINE FALLBACK — motivo: ${e.message}');
      try {
        await localDatasource.actualizarEstado(
          actaId,
          fotoLocalPath: filePath,
        );
        return Right('local:$actaId');
      } catch (localError) {
        return Left(const ServerFailure('Error al guardar foto localmente'));
      }
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getOrganizaciones() async {
    try {
      final orgs = await remoteDatasource.getOrganizaciones();
      return Right(orgs);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Null>> corregirActaVeedor(
    String actaId,
    int totalSufragantes,
    int votosNulos,
    int votosBlancos,
    Map<String, int> votosPorOrganizacion,
    String modificadoPor,
  ) async {
    try {
      await remoteDatasource.corregirActaVeedor(
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
}
