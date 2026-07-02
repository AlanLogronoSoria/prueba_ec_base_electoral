import 'dart:io';
import 'package:appwrite/appwrite.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:workmanager/workmanager.dart';
import 'features/veedor/data/datasources/veedor_local_datasource.dart';
import 'features/veedor/data/datasources/veedor_remote_datasource.dart';
import 'core/sync/sync_service.dart';

const _syncTaskName = 'syncPendientes';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    if (taskName != _syncTaskName) return false;
    try {
      WidgetsFlutterBinding.ensureInitialized();
      await dotenv.load(fileName: '.env');
      await Hive.initFlutter();

      final client = Client()
          .setEndpoint(dotenv.env['APPWRITE_ENDPOINT'] ?? '')
          .setProject(dotenv.env['APPWRITE_PROJECT_ID'] ?? '');

      final endpoint = dotenv.env['APPWRITE_ENDPOINT'] ?? '';
      final projectId = dotenv.env['APPWRITE_PROJECT_ID'] ?? '';
      if (endpoint.isEmpty || projectId.isEmpty) return false;

      final local = VeedorLocalDatasourceImpl();
      final remote = VeedorRemoteDatasourceImpl(
        databases: Databases(client),
        storage: Storage(client),
      );

      final result = await SyncService.sincronizarPendientes(
        local: local,
        remote: remote,
      );

      debugPrint(
        '[WORKMANAGER] Sync completada — ${result.sincronizados} OK, '
        '${result.conflictos} conflictos, ${result.errores} errores',
      );
      return true;
    } catch (e) {
      debugPrint('[WORKMANAGER] Error en sync: $e');
      return false;
    }
  });
}

Future<void> registerBackgroundSync() async {
  await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);

  await Workmanager().registerPeriodicTask(
    _syncTaskName,
    _syncTaskName,
    frequency: const Duration(minutes: 15),
    constraints: Constraints(networkType: NetworkType.connected),
    existingWorkPolicy: ExistingWorkPolicy.replace,
  );
}

Future<void> triggerOneTimeSync() async {
  await Workmanager().registerOneOffTask(
    '${_syncTaskName}_onetimer',
    _syncTaskName,
    initialDelay: const Duration(seconds: 5),
    constraints: Constraints(networkType: NetworkType.connected),
    existingWorkPolicy: ExistingWorkPolicy.replace,
  );
}
