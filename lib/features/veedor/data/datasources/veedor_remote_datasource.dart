import 'package:flutter/foundation.dart';
import 'package:appwrite/appwrite.dart';
import '../../../../core/constants/appwrite_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/acta_model.dart';

abstract class VeedorRemoteDatasource {
  Future<List<Map<String, dynamic>>> getMesasVeedor(String veedorId);
  Future<ActaModel> registrarActa(
    String mesaId,
    String dignidad,
    int totalSufragantes,
    int votosNulos,
    int votosBlancos,
    double gpsLatitud,
    double gpsLongitud,
    String registradoPor,
    Map<String, int> votosPorOrganizacion,
  );
  Future<String> subirFotoActa(String filePath, String actaId);
  Future<List<Map<String, dynamic>>> getOrganizaciones();
  Future<void> corregirActaVeedor(
    String actaId,
    int totalSufragantes,
    int votosNulos,
    int votosBlancos,
    Map<String, int> votosPorOrganizacion,
    String modificadoPor,
  );
  Future<Map<String, dynamic>> getActaPorId(String actaId);
  Future<void> eliminarActa(String actaId);
}

class VeedorRemoteDatasourceImpl implements VeedorRemoteDatasource {
  final Databases databases;
  final Storage storage;

  VeedorRemoteDatasourceImpl({
    required this.databases,
    required this.storage,
  });

  @override
  Future<List<Map<String, dynamic>>> getMesasVeedor(String veedorId) async {
    try {
      final mesasDocs = await databases.listDocuments(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.mesasCollectionId,
        queries: [Query.equal('veedor_id', veedorId)],
      );

      final result = <Map<String, dynamic>>[];
      for (final mesa in mesasDocs.documents) {
        final recintoDocs = await databases.getDocument(
          databaseId: AppwriteConstants.databaseId,
          collectionId: AppwriteConstants.recintosCollectionId,
          documentId: mesa.data['recinto_id'] as String,
        );

        final actasDocs = await databases.listDocuments(
          databaseId: AppwriteConstants.databaseId,
          collectionId: AppwriteConstants.actasCollectionId,
          queries: [Query.equal('mesa_id', mesa.$id)],
        );

        result.add({
          'mesa': mesa.data,
          'mesa_id': mesa.$id,
          'recinto': recintoDocs.data,
          'actas':
              actasDocs.documents.map((d) => {'id': d.$id, ...d.data}).toList(),
        });
      }
      return result;
    } on AppwriteException catch (e) {
      throw ServerException(e.message ?? 'Error al obtener mesas del veedor');
    }
  }

  @override
  Future<ActaModel> registrarActa(
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
      debugPrint('[DS:veedor] registrarActa START — mesa=$mesaId dignidad=$dignidad creadoPor=$registradoPor');
      final existingActas = await databases.listDocuments(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.actasCollectionId,
        queries: [Query.equal('mesa_id', mesaId)],
      );

      final dignidadesExistentes = <String>{};
      for (final doc in existingActas.documents) {
        final d = doc.data['dignidad'] as String?;
        if (d != null) dignidadesExistentes.add(d);
      }

      if (dignidadesExistentes.contains(dignidad)) {
        throw ServerException(
          'Ya existe un acta para la dignidad "$dignidad" en esta mesa. '
          'Usa la opción "Corregir" para modificarla.',
        );
      }

      if (dignidadesExistentes.length >= 2) {
        throw ServerException(
          'Esta mesa ya tiene sus 2 actas registradas (alcalde y prefecto). '
          'Usa la opción "Corregir" para modificar cualquiera de ellas.',
        );
      }

      final doc = await databases.createDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.actasCollectionId,
        documentId: ID.unique(),
        data: {
          'mesa_id': mesaId,
          'dignidad': dignidad,
          'total_sufragantes': totalSufragantes,
          'votos_nulos': votosNulos,
          'votos_blancos': votosBlancos,
          'gps_lat': gpsLatitud,
          'gps_lng': gpsLongitud,
          'created_by': registradoPor,
          'estado': 'pendiente',
        },
        permissions: [
          Permission.read(Role.user(registradoPor)),
          Permission.update(Role.user(registradoPor)),
        ],
      );

      final actaId = doc.$id;

      for (final entry in votosPorOrganizacion.entries) {
        await databases.createDocument(
          databaseId: AppwriteConstants.databaseId,
          collectionId: AppwriteConstants.votosCollectionId,
          documentId: ID.unique(),
          data: {
            'acta_id': actaId,
            'organizacion_id': entry.key,
            'cantidad_votos': entry.value,
          },
          permissions: [
            Permission.read(Role.user(registradoPor)),
            Permission.update(Role.user(registradoPor)),
          ],
        );
      }

      return ActaModel.fromMap(doc.data, doc.$id);
    } on AppwriteException catch (e) {
      debugPrint('[DS:veedor] APPWRITE ERROR: code=${e.code} message=${e.message}');
      throw ServerException(e.message ?? 'Error al registrar acta');
    }
  }

  @override
  Future<String> subirFotoActa(String filePath, String actaId) async {
    try {
      final file = await storage.createFile(
        bucketId: AppwriteConstants.bucketId,
        fileId: ID.unique(),
        file: InputFile.fromPath(
          path: filePath,
          filename: 'acta_$actaId.jpg',
        ),
      );

      final fotoUrl = storage.getFileView(
        bucketId: AppwriteConstants.bucketId,
        fileId: file.$id,
      );

      await databases.updateDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.actasCollectionId,
        documentId: actaId,
        data: {'foto_url': fotoUrl.toString()},
      );

      return fotoUrl.toString();
    } on AppwriteException catch (e) {
      throw ServerException(e.message ?? 'Error al subir foto');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getOrganizaciones() async {
    try {
      final documents = await databases.listDocuments(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.organizacionesCollectionId,
      );
      return documents.documents
          .map((doc) => {'id': doc.$id, ...doc.data})
          .toList();
    } on AppwriteException catch (e) {
      throw ServerException(e.message ?? 'Error al obtener organizaciones');
    }
  }

  @override
  Future<void> corregirActaVeedor(
    String actaId,
    int totalSufragantes,
    int votosNulos,
    int votosBlancos,
    Map<String, int> votosPorOrganizacion,
    String modificadoPor,
  ) async {
    try {
      await databases.updateDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.actasCollectionId,
        documentId: actaId,
        data: {
          'total_sufragantes': totalSufragantes,
          'votos_nulos': votosNulos,
          'votos_blancos': votosBlancos,
          'ultima_modificacion_por': modificadoPor,
        },
      );

      for (final entry in votosPorOrganizacion.entries) {
        final votosDocs = await databases.listDocuments(
          databaseId: AppwriteConstants.databaseId,
          collectionId: AppwriteConstants.votosCollectionId,
          queries: [
            Query.equal('acta_id', actaId),
            Query.equal('organizacion_id', entry.key),
          ],
        );

        if (votosDocs.documents.isNotEmpty) {
          await databases.updateDocument(
            databaseId: AppwriteConstants.databaseId,
            collectionId: AppwriteConstants.votosCollectionId,
            documentId: votosDocs.documents.first.$id,
            data: {'cantidad_votos': entry.value},
          );
        }
      }
    } on AppwriteException catch (e) {
      throw ServerException(e.message ?? 'Error al corregir acta');
    }
  }

  @override
  Future<Map<String, dynamic>> getActaPorId(String actaId) async {
    try {
      final doc = await databases.getDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.actasCollectionId,
        documentId: actaId,
      );
      return {'id': doc.$id, ...doc.data};
    } on AppwriteException catch (e) {
      throw ServerException(e.message ?? 'Error al obtener acta');
    }
  }

  @override
  Future<void> eliminarActa(String actaId) async {
    try {
      await databases.deleteDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.actasCollectionId,
        documentId: actaId,
      );
    } on AppwriteException catch (e) {
      throw ServerException(e.message ?? 'Error al eliminar acta');
    }
  }
}
