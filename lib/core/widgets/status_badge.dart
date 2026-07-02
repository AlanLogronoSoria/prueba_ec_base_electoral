import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum StatusType { completed, pending, error, warning }

class StatusBadge extends StatelessWidget {
  final String label;
  final StatusType type;

  const StatusBadge._({super.key, required this.label, required this.type});

  factory StatusBadge.completed({required String label}) =>
      StatusBadge._(label: label, type: StatusType.completed);

  factory StatusBadge.pending({required String label}) =>
      StatusBadge._(label: label, type: StatusType.pending);

  factory StatusBadge.error({required String label}) =>
      StatusBadge._(label: label, type: StatusType.error);

  factory StatusBadge.warning({required String label}) =>
      StatusBadge._(label: label, type: StatusType.warning);

  Color get _color => switch (type) {
        StatusType.completed => AppColors.success,
        StatusType.pending => AppColors.warning,
        StatusType.error => AppColors.error,
        StatusType.warning => AppColors.warning,
      };

  Color get _bgColor => switch (type) {
        StatusType.completed => AppColors.successLight,
        StatusType.pending => AppColors.warningLight,
        StatusType.error => AppColors.errorLight,
        StatusType.warning => AppColors.warningLight,
      };

  IconData get _icon => switch (type) {
        StatusType.completed => Icons.check_circle_rounded,
        StatusType.pending => Icons.schedule_rounded,
        StatusType.error => Icons.cancel_rounded,
        StatusType.warning => Icons.warning_rounded,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: 14, color: _color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _color)),
        ],
      ),
    );
  }
}
