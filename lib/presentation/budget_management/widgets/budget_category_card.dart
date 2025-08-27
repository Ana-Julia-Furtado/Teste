import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class BudgetCategoryCard extends StatelessWidget {
  final Map<String, dynamic> budgetData;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onNotificationSettings;

  const BudgetCategoryCard({
    Key? key,
    required this.budgetData,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onNotificationSettings,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final allocated = (budgetData['allocated'] as num).toDouble();
    final spent = (budgetData['spent'] as num).toDouble();
    final percentage = allocated > 0 ? (spent / allocated) * 100 : 0.0;
    final remaining = allocated - spent;

    Color progressColor = _getProgressColor(percentage);

    return Dismissible(
      key: Key(budgetData['id'].toString()),
      background: _buildSwipeBackground(context, isLeft: true),
      secondaryBackground: _buildSwipeBackground(context, isLeft: false),
      onDismissed: (direction) {
        if (direction == DismissDirection.startToEnd && onEdit != null) {
          onEdit!();
        } else if (direction == DismissDirection.endToStart &&
            onDelete != null) {
          onDelete!();
        }
      },
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        color: progressColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: CustomIconWidget(
                        iconName: budgetData['icon'] as String,
                        color: progressColor,
                        size: 6.w,
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            budgetData['category'] as String,
                            style: AppTheme.lightTheme.textTheme.titleMedium
                                ?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 0.5.h),
                          Text(
                            'R\$ ${allocated.toStringAsFixed(2).replaceAll('.', ',')} orçado',
                            style: AppTheme.lightTheme.textTheme.bodySmall
                                ?.copyWith(
                              color: AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'R\$ ${spent.toStringAsFixed(2).replaceAll('.', ',')}',
                          style: AppTheme.lightTheme.textTheme.titleMedium
                              ?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: progressColor,
                          ),
                        ),
                        Text(
                          remaining >= 0
                              ? 'R\$ ${remaining.toStringAsFixed(2).replaceAll('.', ',')} restante'
                              : 'R\$ ${(-remaining).toStringAsFixed(2).replaceAll('.', ',')} excedido',
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: remaining >= 0
                                ? AppTheme.getSuccessColor(true)
                                : AppTheme.lightTheme.colorScheme.error,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${percentage.toStringAsFixed(1)}% usado',
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (percentage > 80)
                          CustomIconWidget(
                            iconName: 'warning',
                            color: AppTheme.getWarningColor(true),
                            size: 4.w,
                          ),
                      ],
                    ),
                    SizedBox(height: 1.h),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: (percentage / 100).clamp(0.0, 1.0),
                        backgroundColor: progressColor.withValues(alpha: 0.2),
                        valueColor:
                            AlwaysStoppedAnimation<Color>(progressColor),
                        minHeight: 1.h,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getProgressColor(double percentage) {
    if (percentage >= 100) {
      return AppTheme.lightTheme.colorScheme.error;
    } else if (percentage >= 80) {
      return AppTheme.getWarningColor(true);
    } else {
      return AppTheme.getSuccessColor(true);
    }
  }

  Widget _buildSwipeBackground(BuildContext context, {required bool isLeft}) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: isLeft
            ? AppTheme.lightTheme.colorScheme.primary
            : AppTheme.lightTheme.colorScheme.error,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Align(
        alignment: isLeft ? Alignment.centerLeft : Alignment.centerRight,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomIconWidget(
                iconName: isLeft ? 'edit' : 'delete',
                color: Colors.white,
                size: 6.w,
              ),
              SizedBox(height: 0.5.h),
              Text(
                isLeft ? 'Editar' : 'Excluir',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
