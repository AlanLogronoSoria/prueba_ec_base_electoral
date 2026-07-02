import 'package:equatable/equatable.dart';

sealed class SyncEvent extends Equatable {
  const SyncEvent();

  @override
  List<Object?> get props => [];
}

class StartSync extends SyncEvent {
  const StartSync();
}

class ConnectivityChanged extends SyncEvent {
  final bool isConnected;

  const ConnectivityChanged({required this.isConnected});

  @override
  List<Object?> get props => [isConnected];
}

class SyncNext extends SyncEvent {
  const SyncNext();
}

class ResolverConflicto extends SyncEvent {
  final String localId;
  final bool descartarLocal;

  const ResolverConflicto({
    required this.localId,
    required this.descartarLocal,
  });

  @override
  List<Object?> get props => [localId, descartarLocal];
}
