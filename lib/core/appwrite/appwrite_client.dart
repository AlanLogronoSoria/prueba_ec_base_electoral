import 'package:appwrite/appwrite.dart';
import '../constants/appwrite_constants.dart';

class AppwriteClient {
  AppwriteClient._internal();

  static final AppwriteClient _instance = AppwriteClient._internal();
  static AppwriteClient get instance => _instance;

  late final Client _client;
  late final Account account;
  late final Databases databases;
  late final Storage storage;
  late final Functions functions;

  void init() {
    _client = Client()
        .setEndpoint(AppwriteConstants.endpoint)
        .setProject(AppwriteConstants.projectId);

    account = Account(_client);
    databases = Databases(_client);
    storage = Storage(_client);
    functions = Functions(_client);
  }

  Future<void> waitForExecution(String functionId, String executionId) async {
    dynamic exec;
    for (int i = 0; i < 30; i++) {
      await Future.delayed(const Duration(milliseconds: 500));
      exec = await functions.getExecution(
        functionId: functionId,
        executionId: executionId,
      );
      final status = exec.status?.toString() ?? '';
      if (status == 'completed') return;
      if (status == 'failed') throw Exception('La funcion fallo');
    }
    throw Exception('Timeout esperando la funcion');
  }
}
