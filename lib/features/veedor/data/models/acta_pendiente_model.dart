class ActaPendienteModel {
  final String localId;
  String? actaId;
  String? fotoUrl;
  String? fotoLocalPath;
  String mesaId;
  String dignidad;
  int totalSufragantes;
  int votosNulos;
  int votosBlancos;
  double gpsLatitud;
  double gpsLongitud;
  String registradoPor;
  Map<String, int> votosPorOrganizacion;
  String syncStatus;
  DateTime createdAt;
  DateTime? lastSyncedAt;
  String? conflictoDetalle;

  ActaPendienteModel({
    required this.localId,
    this.actaId,
    this.fotoUrl,
    this.fotoLocalPath,
    required this.mesaId,
    required this.dignidad,
    required this.totalSufragantes,
    required this.votosNulos,
    required this.votosBlancos,
    required this.gpsLatitud,
    required this.gpsLongitud,
    required this.registradoPor,
    required this.votosPorOrganizacion,
    this.syncStatus = 'pendiente',
    DateTime? createdAt,
    this.lastSyncedAt,
    this.conflictoDetalle,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'localId': localId,
      'actaId': actaId,
      'fotoUrl': fotoUrl,
      'fotoLocalPath': fotoLocalPath,
      'mesaId': mesaId,
      'dignidad': dignidad,
      'totalSufragantes': totalSufragantes,
      'votosNulos': votosNulos,
      'votosBlancos': votosBlancos,
      'gpsLatitud': gpsLatitud,
      'gpsLongitud': gpsLongitud,
      'registradoPor': registradoPor,
      'votosPorOrganizacion': votosPorOrganizacion,
      'syncStatus': syncStatus,
      'createdAt': createdAt.toIso8601String(),
      'lastSyncedAt': lastSyncedAt?.toIso8601String(),
      'conflictoDetalle': conflictoDetalle,
    };
  }

  factory ActaPendienteModel.fromMap(Map<String, dynamic> map) {
    return ActaPendienteModel(
      localId: map['localId'] as String,
      actaId: map['actaId'] as String?,
      fotoUrl: map['fotoUrl'] as String?,
      fotoLocalPath: map['fotoLocalPath'] as String?,
      mesaId: map['mesaId'] as String,
      dignidad: map['dignidad'] as String,
      totalSufragantes: map['totalSufragantes'] as int,
      votosNulos: map['votosNulos'] as int,
      votosBlancos: map['votosBlancos'] as int,
      gpsLatitud: (map['gpsLatitud'] as num).toDouble(),
      gpsLongitud: (map['gpsLongitud'] as num).toDouble(),
      registradoPor: map['registradoPor'] as String,
      votosPorOrganizacion:
          Map<String, int>.from(map['votosPorOrganizacion'] as Map),
      syncStatus: map['syncStatus'] as String? ?? 'pendiente',
      createdAt: DateTime.parse(map['createdAt'] as String),
      lastSyncedAt: map['lastSyncedAt'] != null
          ? DateTime.tryParse(map['lastSyncedAt'] as String)
          : null,
      conflictoDetalle: map['conflictoDetalle'] as String?,
    );
  }

  ActaPendienteModel copyWith({
    String? actaId,
    String? fotoUrl,
    String? fotoLocalPath,
    String? syncStatus,
    DateTime? lastSyncedAt,
    String? conflictoDetalle,
  }) {
    return ActaPendienteModel(
      localId: localId,
      actaId: actaId ?? this.actaId,
      fotoUrl: fotoUrl ?? this.fotoUrl,
      fotoLocalPath: fotoLocalPath ?? this.fotoLocalPath,
      mesaId: mesaId,
      dignidad: dignidad,
      totalSufragantes: totalSufragantes,
      votosNulos: votosNulos,
      votosBlancos: votosBlancos,
      gpsLatitud: gpsLatitud,
      gpsLongitud: gpsLongitud,
      registradoPor: registradoPor,
      votosPorOrganizacion: Map.from(votosPorOrganizacion),
      syncStatus: syncStatus ?? this.syncStatus,
      createdAt: createdAt,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      conflictoDetalle: conflictoDetalle ?? this.conflictoDetalle,
    );
  }
}
