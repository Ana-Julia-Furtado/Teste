import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class BudgetAlertsWidget extends StatelessWidget {
  final List<Map<String, dynamic>> alerts;
  final VoidCallback? onViewAll;

  const BudgetAlertsWidget({
    Key? key,
    required this.alerts,
    this.onViewAll,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (alerts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'notifications_active',
                      color: AppTheme.getWarningColor(true),
                      size: 5.w,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'Alertas Recentes',
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                if (alerts.length > 3)
                  GestureDetector(
                    onTap: onViewAll,
                    child: Text(
                      'Ver todos',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 2.h),
            ...alerts.take(3).map((alert) => _buildAlertItem(alert)),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertItem(Map<String, dynamic> alert) {
    final alertType = alert['type'] as String;
    final category = alert['category'] as String;
    final percentage = (alert['percentage'] as num).toDouble();
    final timestamp = alert['timestamp'] as DateTime;

    Color alertColor = _getAlertColor(alertType);
    IconData alertIcon = _getAlertIcon(alertType);
    String alertMessage = _getAlertMessage(alertType, category, percentage);

    return Container(
      margin: EdgeInsets.only(bottom: 1.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: alertColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: alertColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: alertColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: CustomIconWidget(
              iconName: alertIcon.toString().split('.').last,
              color: alertColor,
              size: 4.w,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alertMessage,
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
                SizedBox(height: 0.5.h),
                Text(
                  _formatTimestamp(timestamp),
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getAlertColor(String alertType) {
    switch (alertType) {
      case 'warning':
        return AppTheme.getWarningColor(true);
      case 'danger':
        return AppTheme.lightTheme.colorScheme.error;
      case 'exceeded':
        return AppTheme.lightTheme.colorScheme.error;
      default:
        return AppTheme.getWarningColor(true);
    }
  }

  IconData _getAlertIcon(String alertType) {
    switch (alertType) {
      case 'warning':
        return Icons.warning;
      case 'danger':
        return Icons.error;
      case 'exceeded':
        return Icons.trending_up;
      default:
        return Icons.info;
    }
  }

  String _getAlertMessage(
      String alertType, String category, double percentage) {
    switch (alertType) {
      case 'warning':
        return 'Você atingiu ${percentage.toStringAsFixed(1)}% do orçamento de $category';
      case 'danger':
        return 'Atenção! ${percentage.toStringAsFixed(1)}% do orçamento de $category foi usado';
      case 'exceeded':
        return 'Orçamento de $category foi excedido em ${(percentage - 100).toStringAsFixed(1)}%';
      default:
        return 'Alerta para categoria $category';
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}min atrás';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h atrás';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d atrás';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}
