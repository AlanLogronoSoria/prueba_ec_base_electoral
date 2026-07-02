import 'package:hive/hive.dart';
import '../models/acta_pendiente_model.dart';

abstract class VeedorLocalDatasource {
  Future<void> guardarPendiente(ActaPendienteModel acta);
  Future<List<ActaPendienteModel>> getPendientes();
  Future<List<ActaPendienteModel>> getPendientesSync();
  Future<ActaPendienteModel?> getPorLocalId(String localId);
  Future<void> actualizarEstado(
    String localId, {
    String? actaId,
    String? fotoUrl,
    String? fotoLocalPath,
    String? syncStatus,
    DateTime? lastSyncedAt,
    String? conflictoDetalle,
  });
  Future<void> eliminar(String localId);
  Future<int> contarPendientes();
  Future<int> contarConflictos();
}

class VeedorLocalDatasourceImpl implements VeedorLocalDatasource {
  static const String _boxName = 'actas_pendientes';

  Future<Box<Map>> get _box async => await Hive.openBox<Map>(_boxName);

  @override
  Future<void> guardarPendiente(ActaPendienteModel acta) async {
    final b = await _box;
    await b.put(acta.localId, acta.toMap());
  }

  @override
  Future<List<ActaPendienteModel>> getPendientes() async {
    final b = await _box;
    return b.values
        .map((m) => ActaPendienteModel.fromMap(Map<String, dynamic>.from(m)))
        .toList();
  }

  @override
  Future<List<ActaPendienteModel>> getPendientesSync() async {
    final b = await _box;
    return b.values
        .where((m) =>
            (m['syncStatus'] as String? ?? 'pendiente') != 'sincronizado')
        .map((m) => ActaPendienteModel.fromMap(Map<String, dynamic>.from(m)))
        .toList();
  }

  @override
  Future<ActaPendienteModel?> getPorLocalId(String localId) async {
    final b = await _box;
    final data = b.get(localId);
    if (data == null) return null;
    return ActaPendienteModel.fromMap(Map<String, dynamic>.from(data));
  }

  @override
  Future<void> actualizarEstado(
    String localId, {
    String? actaId,
    String? fotoUrl,
    String? fotoLocalPath,
    String? syncStatus,
    DateTime? lastSyncedAt,
    String? conflictoDetalle,
  }) async {
    final b = await _box;
    final existing = b.get(localId);
    if (existing == null) return;
    final data = Map<String, dynamic>.from(existing);
    if (actaId != null) data['actaId'] = actaId;
    if (fotoUrl != null) data['fotoUrl'] = fotoUrl;
    if (fotoLocalPath != null) data['fotoLocalPath'] = fotoLocalPath;
    if (syncStatus != null) data['syncStatus'] = syncStatus;
    if (lastSyncedAt != null) data['lastSyncedAt'] = lastSyncedAt.toIso8601String();
    if (conflictoDetalle != null) data['conflictoDetalle'] = conflictoDetalle;
    await b.put(localId, data);
  }

  @override
  Future<void> eliminar(String localId) async {
    final b = await _box;
    await b.delete(localId);
  }

  @override
  Future<int> contarPendientes() async {
    final b = await _box;
    return b.values
        .where((m) =>
            (m['syncStatus'] as String? ?? 'pendiente') != 'sincronizado')
        .length;
  }

  @override
  Future<int> contarConflictos() async {
    final b = await _box;
    return b.values
        .where((m) => (m['syncStatus'] as String?) == 'conflicto')
        .length;
  }
}
