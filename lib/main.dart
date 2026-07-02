import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/recovery_bloc.dart';
import 'features/coordinador_provincial/presentation/bloc/provincial_bloc.dart';
import 'features/coordinador_recinto/presentation/bloc/recinto_bloc.dart';
import 'features/veedor/presentation/bloc/veedor_bloc.dart';
import 'features/veedor/presentation/sync/sync_bloc.dart';
import 'injection_container.dart' as di;
import 'injection_container.dart';
import 'router/app_router.dart' as router;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await Hive.initFlutter();
  await di.init();
  runApp(const ControlElectoralApp());
}

class ControlElectoralApp extends StatefulWidget {
  const ControlElectoralApp({super.key});

  @override
  State<ControlElectoralApp> createState() => _ControlElectoralAppState();
}

class _ControlElectoralAppState extends State<ControlElectoralApp> {
  late final GoRouter _appRouter = router.createAppRouter(sl<AuthBloc>());

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<AuthBloc>()),
        BlocProvider(create: (_) => sl<RecoveryBloc>()),
        BlocProvider(create: (_) => sl<ProvincialBloc>()),
        BlocProvider(create: (_) => sl<RecintoBloc>()),
        BlocProvider(create: (_) => sl<VeedorBloc>()),
        BlocProvider(create: (_) => sl<SyncBloc>()),
      ],
      child: MaterialApp.router(
        title: 'Control Electoral',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        routerConfig: _appRouter,
      ),
    );
  }
}
