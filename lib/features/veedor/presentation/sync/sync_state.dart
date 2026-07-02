import 'package:equatable/equatable.dart';
import '../../data/models/acta_pendiente_model.dart';

sealed class SyncState extends Equatable {
  const SyncState();

  @override
  List<Object?> get props => [];
}

class SyncInitial extends SyncState {
  const SyncInitial();
}

class SyncIdle extends SyncState {
  final bool isConnected;
  final int pendientesCount;
  final int conflictosCount;

  const SyncIdle({
    required this.isConnected,
    required this.pendientesCount,
    required this.conflictosCount,
  });

  @override
  List<Object?> get props => [isConnected, pendientesCount, conflictosCount];
}

class SyncInProgress extends SyncState {
  final int total;
  final int procesados;

  const SyncInProgress({
    required this.total,
    required this.procesados,
  });

  @override
  List<Object?> get props => [total, procesados];
}

class SyncCompletado extends SyncState {
  final int sincronizados;
  final int conflictos;
  final int errores;

  const SyncCompletado({
    required this.sincronizados,
    required this.conflictos,
    required this.errores,
  });

  @override
  List<Object?> get props => [sincronizados, conflictos, errores];
}

class ConflictoDetectado extends SyncState {
  final ActaPendienteModel pendiente;
  final String remoteUpdatedAt;
  final Map<String, dynamic>? remoteData;

  const ConflictoDetectado({
    required this.pendiente,
    required this.remoteUpdatedAt,
    this.remoteData,
  });

  @override
  List<Object?> get props => [pendiente.localId, remoteUpdatedAt];
}

class SyncError extends SyncState {
  final String message;

  const SyncError({required this.message});

  @override
  List<Object?> get props => [message];
}

class SyncPartialError extends SyncState {
  final int pendientes;
  final int conflictos;
  final int errores;
  final String motivo;

  const SyncPartialError({
    required this.pendientes,
    required this.conflictos,
    required this.errores,
    required this.motivo,
  });

  @override
  List<Object?> get props => [pendientes, conflictos, errores, motivo];
}
