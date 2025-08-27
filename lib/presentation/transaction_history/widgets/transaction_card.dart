import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class TransactionCard extends StatelessWidget {
  final Map<String, dynamic> transaction;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onDuplicate;

  const TransactionCard({
    Key? key,
    required this.transaction,
    this.isSelected = false,
    this.onTap,
    this.onLongPress,
    this.onEdit,
    this.onDelete,
    this.onDuplicate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final amount = transaction['amount'] as double? ?? 0.0;
    final isIncome = transaction['type'] == 'income';
    final category = transaction['category'] as String? ?? 'Outros';
    final description = transaction['description'] as String? ?? '';
    final account = transaction['account'] as String? ?? '';
    final date = transaction['date'] as DateTime? ?? DateTime.now();

    return Dismissible(
      key: Key(transaction['id'].toString()),
      background: _buildSwipeBackground(true),
      secondaryBackground: _buildSwipeBackground(false),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          onEdit?.call();
        } else {
          onDelete?.call();
        }
        return false;
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1)
              : AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(
                  color: AppTheme.lightTheme.colorScheme.primary,
                  width: 2,
                )
              : null,
          boxShadow: [
            BoxShadow(
              color: AppTheme.lightTheme.colorScheme.shadow,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            onLongPress: onLongPress,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Row(
                children: [
                  _buildCategoryIcon(category),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                description.isNotEmpty ? description : category,
                                style:
                                    AppTheme.lightTheme.textTheme.titleMedium,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              '${isIncome ? '+' : '-'} R\$ ${amount.toStringAsFixed(2).replaceAll('.', ',')}',
                              style: AppTheme.lightTheme.textTheme.titleMedium
                                  ?.copyWith(
                                color: isIncome
                                    ? AppTheme.getSuccessColor(true)
                                    : AppTheme.lightTheme.colorScheme.error,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 0.5.h),
                        Row(
                          children: [
                            Text(
                              category,
                              style: AppTheme.lightTheme.textTheme.bodySmall,
                            ),
                            Text(
                              ' • ',
                              style: AppTheme.lightTheme.textTheme.bodySmall,
                            ),
                            Text(
                              account,
                              style: AppTheme.lightTheme.textTheme.bodySmall,
                            ),
                            Spacer(),
                            Text(
                              _formatTime(date),
                              style: AppTheme.lightTheme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Container(
                      margin: EdgeInsets.only(left: 2.w),
                      child: CustomIconWidget(
                        iconName: 'check_circle',
                        size: 24,
                        color: AppTheme.lightTheme.colorScheme.primary,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryIcon(String category) {
    final categoryData = _getCategoryData(category);
    return Container(
      width: 12.w,
      height: 12.w,
      decoration: BoxDecoration(
        color: categoryData['color'].withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: CustomIconWidget(
          iconName: categoryData['icon'],
          size: 24,
          color: categoryData['color'],
        ),
      ),
    );
  }

  Widget _buildSwipeBackground(bool isLeftSwipe) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: isLeftSwipe
            ? AppTheme.lightTheme.colorScheme.primary
            : AppTheme.lightTheme.colorScheme.error,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Align(
        alignment: isLeftSwipe ? Alignment.centerLeft : Alignment.centerRight,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomIconWidget(
                iconName: isLeftSwipe ? 'edit' : 'delete',
                size: 24,
                color: Colors.white,
              ),
              SizedBox(height: 0.5.h),
              Text(
                isLeftSwipe ? 'Editar' : 'Excluir',
                style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> _getCategoryData(String category) {
    final categoryMap = {
      'Alimentação': {'icon': 'restaurant', 'color': Colors.orange},
      'Transporte': {'icon': 'directions_car', 'color': Colors.blue},
      'Saúde': {'icon': 'local_hospital', 'color': Colors.red},
      'Educação': {'icon': 'school', 'color': Colors.green},
      'Entretenimento': {'icon': 'movie', 'color': Colors.purple},
      'Compras': {'icon': 'shopping_bag', 'color': Colors.pink},
      'Contas': {'icon': 'receipt', 'color': Colors.brown},
      'Salário': {'icon': 'work', 'color': Colors.green},
      'Freelance': {'icon': 'computer', 'color': Colors.blue},
      'Investimentos': {'icon': 'trending_up', 'color': Colors.teal},
    };

    return categoryMap[category] ?? {'icon': 'category', 'color': Colors.grey};
  }

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Ontem';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} dias atrás';
    } else {
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
    }
  }
}
