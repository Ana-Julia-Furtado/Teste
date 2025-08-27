import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AccountCardWidget extends StatelessWidget {
  final Map<String, dynamic> account;
  final VoidCallback? onTap;

  const AccountCardWidget({
    Key? key,
    required this.account,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String accountName = (account['name'] as String?) ?? '';
    final double balance = (account['balance'] as num?)?.toDouble() ?? 0.0;
    final String accountType = (account['type'] as String?) ?? '';
    final String color = (account['color'] as String?) ?? '#2E7D5A';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 45.w,
        margin: EdgeInsets.only(right: 3.w),
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(3.w),
          border: Border.all(
            color:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 8.w,
                  height: 8.w,
                  decoration: BoxDecoration(
                    color: Color(int.parse(color.replaceFirst('#', '0xFF'))),
                    borderRadius: BorderRadius.circular(2.w),
                  ),
                  child: CustomIconWidget(
                    iconName: _getAccountIcon(accountType),
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    accountName,
                    style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            Text(
              accountType,
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                fontSize: 10.sp,
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 0.5.h),
            Text(
              'R\$ ${balance.toStringAsFixed(2).replaceAll('.', ',')}',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: balance >= 0
                    ? AppTheme.getSuccessColor(true)
                    : AppTheme.lightTheme.colorScheme.error,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getAccountIcon(String accountType) {
    switch (accountType.toLowerCase()) {
      case 'conta corrente':
        return 'account_balance';
      case 'poupança':
        return 'savings';
      case 'cartão de crédito':
        return 'credit_card';
      case 'investimentos':
        return 'trending_up';
      default:
        return 'account_balance_wallet';
    }
  }
}
