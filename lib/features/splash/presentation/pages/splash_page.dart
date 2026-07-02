import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;
  bool _ready = false;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _fadeController.forward();

    context.read<AuthBloc>().add(const CheckAuthStatus());

    Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      _ready = true;
      final state = context.read<AuthBloc>().state;

      if (state is AuthAuthenticated) {
        final route = switch (state.usuario.rol) {
          'coordinador_provincial' => '/provincial',
          'coordinador_recinto' => '/recinto',
          'veedor' => '/veedor',
          _ => '/login',
        };
        context.go(route);
      } else {
        context.go('/login');
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(color: AppColors.primaryDark),
          Positioned(
            top: -100,
            left: -80,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(12),
                borderRadius: BorderRadius.circular(280),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withAlpha(5),
                    blurRadius: 100,
                    spreadRadius: 40,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: -120,
            right: -80,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                color: AppColors.secondary.withAlpha(20),
                borderRadius: BorderRadius.circular(320),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.secondary.withAlpha(8),
                    blurRadius: 120,
                    spreadRadius: 60,
                  ),
                ],
              ),
            ),
          ),
          CustomPaint(
            size: Size.infinite,
            painter: _DotGridPainter(),
          ),
          Center(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(8),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(color: Colors.white.withAlpha(15)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(80),
                          blurRadius: 32,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.how_to_vote_rounded,
                      size: 96,
                      color: Color(0xFFB3C7F0),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'ELECCIONES',
                    style: AppTypography.plusJakarta(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -1.5,
                    ),
                  ),
                  Text(
                    'ECUADOR',
                    style: AppTypography.plusJakarta(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 80,
            left: 24,
            right: 24,
            child: Column(
              children: [
                const Text(
                  'Estableciendo conexión segura...',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textTertiary,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Container(
                    width: 240,
                    height: 1,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(13),
                      borderRadius: BorderRadius.circular(1),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: 0.4,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          borderRadius: BorderRadius.circular(1),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.secondary.withAlpha(80),
                              blurRadius: 8,
                              offset: Offset.zero,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withAlpha(3)
      ..style = PaintingStyle.fill;

    const spacing = 16.0;
    const dotSize = 1.0;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), dotSize, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
