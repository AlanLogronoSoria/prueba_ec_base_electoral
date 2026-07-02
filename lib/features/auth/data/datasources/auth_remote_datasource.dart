import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:appwrite/appwrite.dart';
import '../../../../core/appwrite/appwrite_client.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/appwrite_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/retry_helper.dart';
import '../models/usuario_model.dart';

abstract class AuthRemoteDatasource {
  Future<UsuarioModel> login(String cedula, String email, String password);
  Future<void> logout();
  Future<UsuarioModel> getCurrentUser();
  Future<UsuarioModel> createUser({
    required String cedula,
    required String nombres,
    required String apellidos,
    required String telefono,
    required String correo,
    required String rol,
    required String creadoPor,
    String? recintoId,
  });
  Future<void> changePassword(String currentPassword, String newPassword);
  Future<void> recoverPassword(String email);
  Future<String> requestPasswordReset(String cedula, String resetUrl);
  Future<void> completePasswordReset(
      String userId, String secret, String newPassword);
}

class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  final Account account;
  final Databases databases;
  final Functions functions;

  AuthRemoteDatasourceImpl({
    required this.account,
    required this.databases,
    required this.functions,
  });

  @override
  Future<UsuarioModel> login(String cedula, String email, String password) async {
    debugPrint('[LOGIN] Intentando login: cedula=$cedula email=$email');
    try {
      try {
        debugPrint('[LOGIN] Eliminando sesión previa...');
        await account.deleteSession(sessionId: 'current');
        debugPrint('[LOGIN] Sesión previa eliminada');
      } catch (e) {
        debugPrint('[LOGIN] No había sesión previa: $e');
      }

      try {
        debugPrint('[LOGIN] createEmailPasswordSession con email real: $email');
        await account.createEmailPasswordSession(
          email: email,
          password: password,
        );
        debugPrint('[LOGIN] Sesión creada con email real');
      } on AppwriteException catch (e) {
        debugPrint('[LOGIN] Falló con email real (${e.message}), intentando con $cedula@electoral.ec...');
        await account.createEmailPasswordSession(
          email: '$cedula@electoral.ec',
          password: password,
        );
        debugPrint('[LOGIN] Sesión creada con email legacy');
      }

      debugPrint('[LOGIN] Obteniendo usuario actual...');
      final usuario = await getCurrentUser();
      debugPrint('[LOGIN] Usuario obtenido: id=${usuario.id} correo=${usuario.correo}');

      if (usuario.correo != email) {
        debugPrint('[LOGIN] Actualizando correo en BD de ${usuario.correo} a $email');
        try {
          await databases.updateDocument(
            databaseId: AppwriteConstants.databaseId,
            collectionId: AppwriteConstants.usuariosCollectionId,
            documentId: usuario.id,
            data: {'correo': email},
          );
          debugPrint('[LOGIN] Correo actualizado en BD');
        } catch (e) {
          debugPrint('[LOGIN] Error al actualizar correo en BD: $e');
        }
      }
      debugPrint('[LOGIN] Login exitoso');
      return usuario;
    } on AuthException {
      debugPrint('[LOGIN] AuthException, eliminando sesión y re-lanzando');
      try {
        await account.deleteSession(sessionId: 'current');
      } catch (_) {}
      rethrow;
    } on AppwriteException catch (e) {
      debugPrint('[LOGIN] AppwriteException: ${e.message}');
      throw AuthException(e.message ?? 'Error al iniciar sesión');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await account.deleteSession(sessionId: 'current');
    } on AppwriteException catch (e) {
      throw AuthException(e.message ?? 'Error al cerrar sesión');
    }
  }

  @override
  Future<UsuarioModel> getCurrentUser() async {
    debugPrint('[GET_USER] Iniciando getCurrentUser');
    try {
      debugPrint('[GET_USER] Llamando account.get()...');
      final user = await account.get();
      debugPrint('[GET_USER] Auth user obtenido: id=${user.$id} email=${user.email}');
      final userId = user.$id;

      try {
        debugPrint('[GET_USER] Buscando documento por ID: $userId');
        final doc = await databases.getDocument(
          databaseId: AppwriteConstants.databaseId,
          collectionId: AppwriteConstants.usuariosCollectionId,
          documentId: userId,
        );
        debugPrint('[GET_USER] Documento encontrado por ID, id=${doc.$id}');
        return UsuarioModel.fromMap(doc.data, doc.$id);
      } on AppwriteException catch (e) {
        debugPrint('[GET_USER] No se encontró documento por ID: ${e.message}');
        // Fallback: buscar por cédula (usuarios legacy creados antes
        // de la unificación de IDs entre Auth y documento)
        final cedula = user.email.split('@').first;
        debugPrint('[GET_USER] Buscando documento por cédula: $cedula');
        final documents = await databases.listDocuments(
          databaseId: AppwriteConstants.databaseId,
          collectionId: AppwriteConstants.usuariosCollectionId,
          queries: [Query.equal('cedula', cedula)],
        );
        if (documents.documents.isEmpty) {
          debugPrint('[GET_USER] No se encontró documento por cédula');
          throw AuthException('Usuario no encontrado en la base de datos');
        }
        debugPrint('[GET_USER] Documento encontrado por cédula, id=${documents.documents.first.$id}');
        return UsuarioModel.fromMap(
          documents.documents.first.data,
          documents.documents.first.$id,
        );
      }
    } on AuthException {
      debugPrint('[GET_USER] AuthException re-lanzada');
      rethrow;
    } on AppwriteException catch (e) {
      debugPrint('[GET_USER] AppwriteException: ${e.message}');
      throw AuthException(e.message ?? 'Error al obtener usuario');
    }
  }

  @override
  Future<UsuarioModel> createUser({
    required String cedula,
    required String nombres,
    required String apellidos,
    required String telefono,
    required String correo,
    required String rol,
    required String creadoPor,
    String? recintoId,
  }) async {
    try {
      final functionId = AppwriteConstants.createUserFunctionId;
      debugPrint('[DS:auth] === CREATE USER START ===');
      debugPrint('[DS:auth] Function ID: $functionId');
      if (functionId.isEmpty) {
        throw ServerException(
          'Función de creación de usuarios no configurada. '
          'Configura APPWRITE_CREATE_USER_FUNCTION_ID en .env',
        );
      }

      final body = <String, dynamic>{
        'cedula': cedula,
        'nombres': nombres,
        'apellidos': apellidos,
        'telefono': telefono,
        'correo': correo,
        'rol': rol,
      };
      if (recintoId != null) body['recintoId'] = recintoId;

      debugPrint('[DS:auth] Payload: ${jsonEncode(body)}');

      final execution = await retryWithBackoffAndCheck(
        action: () => functions.createExecution(
          functionId: functionId,
          body: jsonEncode(body),
        ),
        alreadyDone: () async {
          final check = await databases.listDocuments(
            databaseId: AppwriteConstants.databaseId,
            collectionId: AppwriteConstants.usuariosCollectionId,
            queries: [Query.equal('cedula', cedula)],
          );
          return check.documents.isNotEmpty;
        },
      );

      debugPrint('[DS:auth] Execution ID: ${execution.$id}');

      await AppwriteClient.instance
          .waitForExecution(functionId, execution.$id);

      debugPrint('[DS:auth] Function completed, searching user by cedula: $cedula');

      final docs = await databases.listDocuments(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.usuariosCollectionId,
        queries: [Query.equal('cedula', cedula)],
      );

      debugPrint('[DS:auth] Search result count: ${docs.documents.length}');

      if (docs.documents.isEmpty) {
        debugPrint('[DS:auth] ERROR: Usuario no encontrado tras creacion');
        throw ServerException('Usuario no encontrado tras creacion');
      }

      final userDoc = docs.documents.first;

      debugPrint('[DS:auth] === CREATE USER SUCCESS === userId=${userDoc.$id}');

      return UsuarioModel.fromMap(userDoc.data, userDoc.$id);
    } on ServerException {
      debugPrint('[DS:auth] SERVER EXCEPTION rethrow');
      rethrow;
    } on AppwriteException catch (e) {
      debugPrint('[DS:auth] APPWRITE ERROR: ${e.message} | code=${e.code}');
      throw ServerException(e.message ?? 'Error al crear usuario');
    }
  }

  @override
  Future<void> changePassword(String currentPassword, String newPassword) async {
    try {
      debugPrint('[CHANGE_PASSWORD] Actualizando contraseña en Auth...');
      await account.updatePassword(
        password: newPassword,
        oldPassword: currentPassword,
      );
      debugPrint('[CHANGE_PASSWORD] Contraseña actualizada en Auth');

      debugPrint('[CHANGE_PASSWORD] Obteniendo usuario actual...');
      final user = await account.get();
      final userId = user.$id;
      debugPrint('[CHANGE_PASSWORD] Usuario: id=$userId');

      try {
        debugPrint('[CHANGE_PASSWORD] Actualizando primer_login=false por ID...');
        await databases.updateDocument(
          databaseId: AppwriteConstants.databaseId,
          collectionId: AppwriteConstants.usuariosCollectionId,
          documentId: userId,
          data: {'primer_login': false},
        );
        debugPrint('[CHANGE_PASSWORD] primer_login actualizado por ID');
      } on AppwriteException catch (e) {
        debugPrint('[CHANGE_PASSWORD] Falló por ID (${e.message}), buscando por cédula...');
        // Fallback: buscar por cédula (usuarios legacy)
        final cedula = user.email.split('@').first;
        final documents = await databases.listDocuments(
          databaseId: AppwriteConstants.databaseId,
          collectionId: AppwriteConstants.usuariosCollectionId,
          queries: [Query.equal('cedula', cedula)],
        );
        if (documents.documents.isNotEmpty) {
          await databases.updateDocument(
            databaseId: AppwriteConstants.databaseId,
            collectionId: AppwriteConstants.usuariosCollectionId,
            documentId: documents.documents.first.$id,
            data: {'primer_login': false},
          );
          debugPrint('[CHANGE_PASSWORD] primer_login actualizado por cédula');
        }
      }
      debugPrint('[CHANGE_PASSWORD] Cambio de contraseña completado exitosamente');
    } on AppwriteException catch (e) {
      debugPrint('[CHANGE_PASSWORD] Error: ${e.message}');
      throw AuthException(e.message ?? 'Error al cambiar contraseña');
    }
  }

  @override
  Future<void> recoverPassword(String email) async {
    try {
      await account.createRecovery(
        email: email,
        url: '${AppwriteConstants.recoveryBaseUrl}/reset-password',
      );
    } on AppwriteException catch (e) {
      throw AuthException(e.message ?? 'Error al recuperar contraseña');
    }
  }

  @override
  Future<String> requestPasswordReset(String cedula, String resetUrl) async {
    try {
      final documents = await databases.listDocuments(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.usuariosCollectionId,
        queries: [Query.equal('cedula', cedula)],
      );

      if (documents.documents.isEmpty) {
        throw AuthException('No se encontró un usuario con esa cédula');
      }

      final email = documents.documents.first.data['correo'] as String;

      await account.createRecovery(
        email: email,
        url: resetUrl,
      );

      return email;
    } on AuthException {
      rethrow;
    } on AppwriteException catch (e) {
      throw AuthException(e.message ?? 'Error al solicitar recuperación');
    }
  }

  @override
  Future<void> completePasswordReset(
      String userId, String secret, String newPassword) async {
    try {
      await account.updateRecovery(
        userId: userId,
        secret: secret,
        password: newPassword,
      );
    } on AppwriteException catch (e) {
      throw AuthException(e.message ?? 'Error al restablecer la contraseña');
    }
  }
}
