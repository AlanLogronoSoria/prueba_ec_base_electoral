import 'dart:io';
import 'package:flutter/foundation.dart';
import '../utils/retry_helper.dart';
import '../../features/veedor/data/datasources/veedor_local_datasource.dart';
import '../../features/veedor/data/datasources/veedor_remote_datasource.dart';

class SyncResult {
  final int sincronizados;
  final int conflictos;
  final int errores;

  const SyncResult({
    required this.sincronizados,
    required this.conflictos,
    required this.errores,
  });
}

class SyncService {
  static Future<SyncResult> sincronizarPendientes({
    required VeedorLocalDatasource local,
    required VeedorRemoteDatasource remote,
    void Function(int total, int procesados)? onProgress,
  }) async {
    final pendientes = await local.getPendientesSync();
    final total = pendientes.length;

    if (total == 0) {
      final conflictos = await local.contarConflictos();
      return SyncResult(sincronizados: 0, conflictos: conflictos, errores: 0);
    }

    int procesados = 0;
    int errores = 0;

    for (final pendiente in pendientes) {
      onProgress?.call(total, procesados);

      try {
        if (pendiente.actaId != null) {
          try {
            final remoteActa = await remote.getActaPorId(pendiente.actaId!);
            final remoteUpdated = DateTime.tryParse(
              remoteActa['updated_at']?.toString() ??
                  remoteActa['\$updatedAt']?.toString() ??
                  '',
            );
            if (remoteUpdated != null && remoteUpdated.isAfter(pendiente.createdAt)) {
              await local.actualizarEstado(
                pendiente.localId,
                syncStatus: 'conflicto',
                conflictoDetalle:
                    'El acta fue modificada remotamente el ${remoteUpdated.toLocal()}. '
                    'Tus cambios locales son del ${pendiente.createdAt.toLocal()}.',
              );
              continue;
            }
          } catch (e) {
            debugPrint('[SYNC] No se pudo verificar acta remota ${pendiente.actaId}: $e');
            continue;
          }
        }

        String? actaIdResult = pendiente.actaId;
        String? fotoUrlResult = pendiente.fotoUrl;

        if (actaIdResult == null) {
          final nuevaActa = await retryWithBackoff(
            () => remote.registrarActa(
              pendiente.mesaId,
              pendiente.dignidad,
              pendiente.totalSufragantes,
              pendiente.votosNulos,
              pendiente.votosBlancos,
              pendiente.gpsLatitud,
              pendiente.gpsLongitud,
              pendiente.registradoPor,
              pendiente.votosPorOrganizacion,
            ),
          );

          actaIdResult = nuevaActa.id;

          if (pendiente.fotoLocalPath != null) {
            try {
              fotoUrlResult = await retryWithBackoff(
                () => remote.subirFotoActa(
                  pendiente.fotoLocalPath!,
                  actaIdResult!,
                ),
                maxAttempts: 2,
              );
            } catch (e) {
              debugPrint('[SYNC] Error subiendo foto para acta $actaIdResult: $e');
            }
          }
        }

        await local.actualizarEstado(
          pendiente.localId,
          actaId: actaIdResult,
          fotoUrl: fotoUrlResult,
          syncStatus: 'sincronizado',
          lastSyncedAt: DateTime.now(),
        );

        procesados++;
      } catch (e) {
        errores++;
        try {
          await local.actualizarEstado(
            pendiente.localId,
            syncStatus: 'pendiente',
            conflictoDetalle: 'Error: $e',
          );
        } catch (localError) {
          debugPrint('[SYNC] Error critico al actualizar estado local: $localError');
        }
      }
    }

    final conflictos = await local.contarConflictos();
    return SyncResult(
      sincronizados: procesados,
      conflictos: conflictos,
      errores: errores,
    );
  }
}
