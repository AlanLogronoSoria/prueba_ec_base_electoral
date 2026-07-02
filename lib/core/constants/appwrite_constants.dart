import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppwriteConstants {
  AppwriteConstants._();

  static String get endpoint =>
      dotenv.env['APPWRITE_ENDPOINT'] ?? 'http://localhost/v1';
  static String get projectId =>
      dotenv.env['APPWRITE_PROJECT_ID'] ?? 'control-electoral';

  static String get databaseId =>
      dotenv.env['APPWRITE_DATABASE_ID'] ?? 'control_electoral_db';

  static String get usuariosCollectionId =>
      dotenv.env['APPWRITE_USUARIOS_COLLECTION_ID'] ?? 'usuarios';
  static String get recintosCollectionId =>
      dotenv.env['APPWRITE_RECINTOS_COLLECTION_ID'] ?? 'recintos';
  static String get mesasCollectionId =>
      dotenv.env['APPWRITE_MESAS_COLLECTION_ID'] ?? 'mesas';
  static String get organizacionesCollectionId =>
      dotenv.env['APPWRITE_ORGANIZACIONES_COLLECTION_ID'] ?? 'organizaciones_politicas';
  static String get actasCollectionId =>
      dotenv.env['APPWRITE_ACTAS_COLLECTION_ID'] ?? 'actas';
  static String get votosCollectionId =>
      dotenv.env['APPWRITE_VOTOS_COLLECTION_ID'] ?? 'votos_por_organizacion';

  static String get bucketId =>
      dotenv.env['APPWRITE_BUCKET_ID'] ?? 'actas_fotos';

  static String get recoveryBaseUrl =>
      dotenv.env['APPWRITE_RECOVERY_URL'] ?? 'controlelectoral://';

  static String get adminKey =>
      dotenv.env['APPWRITE_ADMIN_KEY'] ?? '';
}
