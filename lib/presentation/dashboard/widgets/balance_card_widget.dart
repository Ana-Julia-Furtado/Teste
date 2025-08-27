import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class BalanceCardWidget extends StatefulWidget {
  final double balance;
  final String lastUpdated;
  final VoidCallback onRefresh;

  const BalanceCardWidget({
    Key? key,
    required this.balance,
    required this.lastUpdated,
    required this.onRefresh,
  }) : super(key: key);

  @override
  State<BalanceCardWidget> createState() => _BalanceCardWidgetState();
}

class _BalanceCardWidgetState extends State<BalanceCardWidget> {
  bool _isBalanceVisible = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.lightTheme.colorScheme.primary,
            AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(4.w),
        boxShadow: [
          BoxShadow(
            color:
                AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Saldo Total',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 14.sp,
                ),
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isBalanceVisible = !_isBalanceVisible;
                      });
                    },
                    child: CustomIconWidget(
                      iconName:
                          _isBalanceVisible ? 'visibility' : 'visibility_off',
                      color: Colors.white.withValues(alpha: 0.9),
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 3.w),
                  GestureDetector(
                    onTap: widget.onRefresh,
                    child: CustomIconWidget(
                      iconName: 'refresh',
                      color: Colors.white.withValues(alpha: 0.9),
                      size: 20,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            _isBalanceVisible
                ? 'R\$ ${widget.balance.toStringAsFixed(2).replaceAll('.', ',')}'
                : '••••••',
            style: AppTheme.lightTheme.textTheme.headlineLarge?.copyWith(
              color: Colors.white,
              fontSize: 28.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Última atualização: ${widget.lastUpdated}',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 11.sp,
            ),
          ),
        ],
      ),
    );
  }
}
