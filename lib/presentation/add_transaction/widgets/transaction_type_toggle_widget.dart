import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

enum TransactionType { expense, income }

class TransactionTypeToggleWidget extends StatelessWidget {
  final TransactionType selectedType;
  final Function(TransactionType) onTypeChanged;

  const TransactionTypeToggleWidget({
    Key? key,
    required this.selectedType,
    required this.onTypeChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(1.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildToggleButton(
              context,
              'Despesa',
              TransactionType.expense,
              AppTheme.lightTheme.colorScheme.error,
              CustomIconWidget(
                iconName: 'remove_circle_outline',
                color: selectedType == TransactionType.expense
                    ? Colors.white
                    : AppTheme.lightTheme.colorScheme.error,
                size: 20,
              ),
            ),
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: _buildToggleButton(
              context,
              'Receita',
              TransactionType.income,
              AppTheme.getSuccessColor(true),
              CustomIconWidget(
                iconName: 'add_circle_outline',
                color: selectedType == TransactionType.income
                    ? Colors.white
                    : AppTheme.getSuccessColor(true),
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton(
    BuildContext context,
    String label,
    TransactionType type,
    Color color,
    Widget icon,
  ) {
    final isSelected = selectedType == type;

    return GestureDetector(
      onTap: () => onTypeChanged(type),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 3.w),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            SizedBox(width: 2.w),
            Text(
              label,
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                color: isSelected ? Colors.white : color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
