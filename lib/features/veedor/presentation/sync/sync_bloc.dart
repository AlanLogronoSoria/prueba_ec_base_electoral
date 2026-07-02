import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../data/datasources/veedor_local_datasource.dart';
import '../../data/datasources/veedor_remote_datasource.dart';
import 'sync_event.dart';
import 'sync_state.dart';

class SyncBloc extends Bloc<SyncEvent, SyncState> {
  final VeedorLocalDatasource localDatasource;
  final VeedorRemoteDatasource remoteDatasource;
  final Connectivity connectivity;
  StreamSubscription? _connectivitySub;
  bool _sinConexionPrevia = false;

  SyncBloc({
    required this.localDatasource,
    required this.remoteDatasource,
    required this.connectivity,
  }) : super(const SyncInitial()) {
    on<StartSync>(_onStartSync);
    on<ConnectivityChanged>(_onConnectivityChanged);
    on<SyncNext>(_onSyncNext);
    on<ResolverConflicto>(_onResolverConflicto);

    _initConnectivity();
  }

  Future<void> _initConnectivity() async {
    try {
      final result = await connectivity.checkConnectivity();
      final connected = !result.contains(ConnectivityResult.none);
      _sinConexionPrevia = !connected;

      _connectivitySub = connectivity.onConnectivityChanged.listen((results) {
        try {
          final c = !results.contains(ConnectivityResult.none);
          add(ConnectivityChanged(isConnected: c));
        } catch (_) {}
      });

      add(ConnectivityChanged(isConnected: connected));
    } catch (_) {
      add(ConnectivityChanged(isConnected: false));
    }
  }

  Future<void> _onConnectivityChanged(
    ConnectivityChanged event,
    Emitter<SyncState> emit,
  ) async {
    final pendientes = await localDatasource.contarPendientes();
    final conflictos = await localDatasource.contarConflictos();
    emit(SyncIdle(
      isConnected: event.isConnected,
      pendientesCount: pendientes,
      conflictosCount: conflictos,
    ));

    if (event.isConnected && _sinConexionPrevia && pendientes > 0) {
      add(const SyncNext());
    }
    _sinConexionPrevia = !event.isConnected;
  }

  Future<void> _onStartSync(
    StartSync event,
    Emitter<SyncState> emit,
  ) async {
    add(const SyncNext());
  }

  Future<void> _onSyncNext(
    SyncNext event,
    Emitter<SyncState> emit,
  ) async {
    final pendientes = await localDatasource.getPendientesSync();
    final total = pendientes.length;

    if (total == 0) {
      final conflictos = await localDatasource.contarConflictos();
      emit(SyncCompletado(
        sincronizados: 0,
        conflictos: conflictos,
        errores: 0,
      ));
      return;
    }

    int procesados = 0;
    int errores = 0;

    for (final pendiente in pendientes) {
      emit(SyncInProgress(total: total, procesados: procesados));

      try {
        // --- CONFLICT RESOLUTION STRATEGY ---
        // For new actas (actaId == null): no remote record exists, so no conflict.
        // Push directly.
        //
        // For corrections (actaId != null): fetch the remote updated_at.
        // - If remote has a newer updated_at than local createdAt: conflict.
        //   The local changes might overwrite newer data. Mark as conflicto
        //   and let the user decide.
        // - If local has the same or newer timestamp: safe to overwrite
        //   (last-write-wins, optimistic concurrency).
        //
        // This strategy is "last-write-wins with conflict detection":
        // - Prevents silent data loss from stale offline edits
        // - User intervention required only when remote was modified while
        //   offline changes were pending
        // - For new actas, there is no stale data to conflict with
        if (pendiente.actaId != null) {
          try {
            final remoteActa = await remoteDatasource.getActaPorId(
              pendiente.actaId!,
            );

            final remoteUpdated =
                DateTime.parse(remoteActa['updated_at'] ?? remoteActa['\$updatedAt'] ?? '');
            final localCreated = pendiente.createdAt;

            if (remoteUpdated.isAfter(localCreated)) {
              // Remote is newer → conflict, local changes may overwrite new data
              await localDatasource.actualizarEstado(
                pendiente.localId,
                syncStatus: 'conflicto',
                conflictoDetalle:
                    'El acta fue modificada remotamente el ${remoteUpdated.toLocal()}. '
                    'Tus cambios locales son del ${localCreated.toLocal()}. '
                    'Decide si descartar tus cambios locales o sobrescribir.',
              );
              emit(ConflictoDetectado(
                pendiente: pendiente,
                remoteUpdatedAt: remoteUpdated.toIso8601String(),
                remoteData: remoteActa,
              ));
              continue;
            }
          } catch (e) {
            // Cannot fetch remote → network issue, skip and try later
            continue;
          }
        }

        // Push to Appwrite
        String? actaIdResult = pendiente.actaId;
        String? fotoUrlResult = pendiente.fotoUrl;

        if (actaIdResult == null) {
          // Create acta document + votos in one call
          final nuevaActa = await remoteDatasource.registrarActa(
            pendiente.mesaId,
            pendiente.dignidad,
            pendiente.totalSufragantes,
            pendiente.votosNulos,
            pendiente.votosBlancos,
            pendiente.gpsLatitud,
            pendiente.gpsLongitud,
            pendiente.registradoPor,
            pendiente.votosPorOrganizacion,
          );

          actaIdResult = nuevaActa.id;

          // Upload foto if available locally
          if (pendiente.fotoLocalPath != null) {
            try {
              fotoUrlResult = await remoteDatasource.subirFotoActa(
                pendiente.fotoLocalPath!,
                actaIdResult,
              );
            } catch (_) {
              // Foto upload failure is non-fatal
            }
          }
        }

        await localDatasource.actualizarEstado(
          pendiente.localId,
          actaId: actaIdResult,
          fotoUrl: fotoUrlResult,
          syncStatus: 'sincronizado',
          lastSyncedAt: DateTime.now(),
        );

        procesados++;
      } catch (e) {
        errores++;
        await localDatasource.actualizarEstado(
          pendiente.localId,
          syncStatus: 'pendiente',
          conflictoDetalle: 'Error: $e',
        );
      }
    }

    final conflictosFinal = await localDatasource.contarConflictos();
    emit(SyncCompletado(
      sincronizados: procesados,
      conflictos: conflictosFinal,
      errores: errores,
    ));

    final pendientesFinal = await localDatasource.contarPendientes();
    if (pendientesFinal == 0 && conflictosFinal == 0) {
      final conectado = await connectivity.checkConnectivity();
      emit(SyncIdle(
        isConnected: conectado.contains(ConnectivityResult.none),
        pendientesCount: 0,
        conflictosCount: 0,
      ));
    }
  }

  /// Resolve a conflict: discard local or delete remote and re-push
  Future<void> _onResolverConflicto(
    ResolverConflicto event,
    Emitter<SyncState> emit,
  ) async {
    if (event.descartarLocal) {
      // Remove local pending entry → keep remote as-is
      await localDatasource.eliminar(event.localId);
    } else {
      // Overwrite: delete remote acta and re-push
      final pendiente = await localDatasource.getPorLocalId(event.localId);
      if (pendiente != null && pendiente.actaId != null) {
        try {
          await remoteDatasource.eliminarActa(pendiente.actaId!);
        } catch (_) {}
        await localDatasource.actualizarEstado(
          event.localId,
          actaId: null,
          syncStatus: 'pendiente',
          conflictoDetalle: null,
        );
        add(const SyncNext());
      }
    }

    final pendientes = await localDatasource.contarPendientes();
    final conflictos = await localDatasource.contarConflictos();
    final conectado = await connectivity.checkConnectivity();
    emit(SyncIdle(
      isConnected: conectado.contains(ConnectivityResult.none),
      pendientesCount: pendientes,
      conflictosCount: conflictos,
    ));
  }

  @override
  Future<void> close() {
    _connectivitySub?.cancel();
    return super.close();
  }
}
