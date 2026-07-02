import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:bloc/bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../../../core/sync/sync_service.dart';
import '../../../../sync_worker.dart';
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
        } catch (e) {
          debugPrint('[SYNC] Error leyendo cambio de conectividad: $e');
          add(ConnectivityChanged(isConnected: false));
        }
      });

      add(ConnectivityChanged(isConnected: connected));
    } catch (e) {
      debugPrint('[SYNC] Error verificando conectividad inicial: $e');
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
      triggerOneTimeSync();
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
      emit(SyncCompletado(sincronizados: 0, conflictos: conflictos, errores: 0));
      return;
    }

    final result = await SyncService.sincronizarPendientes(
      local: localDatasource,
      remote: remoteDatasource,
      onProgress: (t, p) => emit(SyncInProgress(total: t, procesados: p)),
    );

    emit(SyncCompletado(
      sincronizados: result.sincronizados,
      conflictos: result.conflictos,
      errores: result.errores,
    ));

    final pendientesFinal = await localDatasource.contarPendientes();
    final conflictosFinal = await localDatasource.contarConflictos();
    if (pendientesFinal == 0 && conflictosFinal == 0) {
      final conectado = await connectivity.checkConnectivity();
      emit(SyncIdle(
        isConnected: conectado.contains(ConnectivityResult.none),
        pendientesCount: 0,
        conflictosCount: 0,
      ));
    } else if (result.errores > 0) {
      emit(SyncPartialError(
        pendientes: pendientesFinal,
        conflictos: conflictosFinal,
        errores: result.errores,
        motivo: '${result.errores} actas no pudieron sincronizarse. '
            'Verifica tu conexión e intenta de nuevo.',
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
        } catch (e) {
          debugPrint('[SYNC] Error eliminando acta remota ${pendiente.actaId}: $e');
        }
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
