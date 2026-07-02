import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AppLoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final String? message;

  const AppLoadingOverlay({super.key, required this.isLoading, this.message});

  @override
  Widget build(BuildContext context) {
    if (!isLoading) return const SizedBox.shrink();

    return Container(
      color: AppColors.overlay,
      child: Center(
        child: Card(
          margin: const EdgeInsets.all(32),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(strokeWidth: 3),
                ),
                if (message != null) ...[
                  const SizedBox(height: 16),
                  Text(message!, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
