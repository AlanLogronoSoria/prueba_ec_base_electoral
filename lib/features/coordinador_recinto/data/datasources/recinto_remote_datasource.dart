import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:appwrite/appwrite.dart';
import '../../../../core/appwrite/appwrite_client.dart';
import '../../../../core/constants/appwrite_constants.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../features/veedor/data/models/acta_model.dart';
import '../../../../features/veedor/data/models/organizacion_politica_model.dart';
import '../models/mesa_model.dart';

abstract class RecintoRemoteDatasource {
  Future<List<MesaModel>> getMesas(String recintoId);
  Future<String> createVeedor(
    String cedula,
    String nombres,
    String apellidos,
    String telefono,
    String correo,
    String creadoPor,
    String? mesaId,
  );
  Future<void> asignarVeedor(String mesaId, String veedorCedula);
  Future<List<OrganizacionPoliticaModel>> getOrganizaciones();
  Future<ActaModel> getActaPorMesa(String mesaId);
  Future<void> corregirActa(
    String actaId,
    int totalSufragantes,
    int votosNulos,
    int votosBlancos,
    Map<String, int> votosPorOrganizacion,
    String modificadoPor,
  );
  Future<String> subirFotoActa(String filePath, String actaId);
  Future<Map<String, int>> getAvance(String recintoId);
}

class RecintoRemoteDatasourceImpl implements RecintoRemoteDatasource {
  final Databases databases;
  final Account account;
  final Storage storage;
  final Functions functions;

  RecintoRemoteDatasourceImpl({
    required this.databases,
    required this.account,
    required this.storage,
    required this.functions,
  });

  @override
  Future<List<MesaModel>> getMesas(String recintoId) async {
    try {
      final documents = await databases.listDocuments(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.mesasCollectionId,
        queries: [Query.equal('recinto_id', recintoId)],
      );

      final mesaIds = documents.documents.map((d) => d.$id).toList();
      final mesasConActa = <String>{};

      if (mesaIds.isNotEmpty) {
        final actasDocs = await databases.listDocuments(
          databaseId: AppwriteConstants.databaseId,
          collectionId: AppwriteConstants.actasCollectionId,
          queries: [Query.equal('mesa_id', mesaIds)],
        );
        for (final doc in actasDocs.documents) {
          mesasConActa.add(doc.data['mesa_id'] as String);
        }
      }

      return documents.documents.map((doc) {
        return MesaModel.fromMap(doc.data, doc.$id,
            hasActa: mesasConActa.contains(doc.$id));
      }).toList();
    } on AppwriteException catch (e) {
      throw ServerException(e.message ?? 'Error al obtener mesas');
    }
  }

  @override
  Future<String> createVeedor(
    String cedula,
    String nombres,
    String apellidos,
    String telefono,
    String correo,
    String creadoPor,
    String? mesaId,
  ) async {
    try {
      final functionId = AppwriteConstants.createUserFunctionId;
      debugPrint('[DS:rec] === CREATE VEEDOR START ===');
      debugPrint('[DS:rec] Cedula: $cedula, Correo: $correo');
      if (functionId.isEmpty) {
        throw ServerException('Función de creación de usuarios no configurada');
      }

      final execution = await functions.createExecution(
        functionId: functionId,
        body: jsonEncode({
          'cedula': cedula,
          'nombres': nombres,
          'apellidos': apellidos,
          'telefono': telefono,
          'correo': correo,
          'rol': 'veedor',
        }),
      );

      debugPrint('[DS:rec] Execution ID: ${execution.$id}');

      await AppwriteClient.instance
          .waitForExecution(functionId, execution.$id);

      debugPrint('[DS:rec] Function completed, searching user by cedula: $cedula');

      final docs = await databases.listDocuments(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.usuariosCollectionId,
        queries: [Query.equal('cedula', cedula)],
      );

      debugPrint('[DS:rec] Search result count: ${docs.documents.length}');

      if (docs.documents.isEmpty) {
        debugPrint('[DS:rec] ERROR: Usuario no encontrado');
        throw ServerException('Usuario no encontrado tras creacion');
      }

      final veedorId = docs.documents.first.$id;

      debugPrint('[DS:rec] === SUCCESS === veedorId=$veedorId');

      if (mesaId != null) {
        await databases.updateDocument(
          databaseId: AppwriteConstants.databaseId,
          collectionId: AppwriteConstants.mesasCollectionId,
          documentId: mesaId,
          data: {'veedor_id': veedorId},
        );
      }

      return veedorId;
    } on ServerException {
      debugPrint('[DS:rec] SERVER EXCEPTION rethrow');
      rethrow;
    } on AppwriteException catch (e) {
      debugPrint('[DS:rec] APPWRITE ERROR: ${e.message} | code=${e.code}');
      throw ServerException(e.message ?? 'Error al crear veedor');
    }
  }

  @override
  Future<void> asignarVeedor(String mesaId, String veedorCedula) async {
    try {
      final users = await databases.listDocuments(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.usuariosCollectionId,
        queries: [Query.equal('cedula', veedorCedula)],
      );

      if (users.documents.isEmpty) {
        throw NotFoundException('Veedor no encontrado');
      }

      await databases.updateDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.mesasCollectionId,
        documentId: mesaId,
        data: {'veedor_id': users.documents.first.$id},
      );
    } on AppwriteException catch (e) {
      throw ServerException(e.message ?? 'Error al asignar veedor');
    }
  }

  @override
  Future<List<OrganizacionPoliticaModel>> getOrganizaciones() async {
    try {
      final documents = await databases.listDocuments(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.organizacionesCollectionId,
      );
      return documents.documents
          .map((doc) =>
              OrganizacionPoliticaModel.fromMap(doc.data, doc.$id))
          .toList();
    } on AppwriteException catch (e) {
      throw ServerException(e.message ?? 'Error al obtener organizaciones');
    }
  }

  @override
  Future<ActaModel> getActaPorMesa(String mesaId) async {
    try {
      final actasDocs = await databases.listDocuments(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.actasCollectionId,
        queries: [Query.equal('mesa_id', mesaId)],
      );

      if (actasDocs.documents.isEmpty) {
        throw NotFoundException('No hay acta registrada para esta mesa');
      }

      return ActaModel.fromMap(
          actasDocs.documents.first.data, actasDocs.documents.first.$id);
    } on AppwriteException catch (e) {
      throw ServerException(e.message ?? 'Error al obtener acta');
    }
  }

  @override
  Future<void> corregirActa(
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
  Future<Map<String, int>> getAvance(String recintoId) async {
    try {
      final mesasDocs = await databases.listDocuments(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.mesasCollectionId,
        queries: [Query.equal('recinto_id', recintoId)],
      );

      final totalMesas = mesasDocs.documents.length;
      final mesaIds = mesasDocs.documents.map((d) => d.$id).toList();

      int actasRegistradas = 0;
      if (mesaIds.isNotEmpty) {
        final actasDocs = await databases.listDocuments(
          databaseId: AppwriteConstants.databaseId,
          collectionId: AppwriteConstants.actasCollectionId,
          queries: [
            Query.equal('mesa_id', mesaIds),
            Query.equal('estado', 'registrada'),
          ],
        );
        actasRegistradas = actasDocs.documents.length;
      }

      return {
        'total_mesas': totalMesas,
        'actas_registradas': actasRegistradas,
      };
    } on AppwriteException catch (e) {
      throw ServerException(e.message ?? 'Error al obtener avance');
    }
  }
}
