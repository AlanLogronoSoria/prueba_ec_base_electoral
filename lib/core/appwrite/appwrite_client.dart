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
}
