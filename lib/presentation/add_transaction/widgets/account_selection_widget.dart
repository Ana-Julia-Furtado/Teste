import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AccountSelectionWidget extends StatelessWidget {
  final String? selectedAccount;
  final Function(String) onAccountSelected;

  const AccountSelectionWidget({
    Key? key,
    this.selectedAccount,
    required this.onAccountSelected,
  }) : super(key: key);

  final List<Map<String, dynamic>> _accounts = const [
    {
      'name': 'Conta Corrente',
      'bank': 'Banco do Brasil',
      'balance': 2450.75,
      'icon': 'account_balance',
      'color': Colors.blue,
    },
    {
      'name': 'Poupança',
      'bank': 'Caixa Econômica',
      'balance': 8920.30,
      'icon': 'savings',
      'color': Colors.green,
    },
    {
      'name': 'Cartão de Crédito',
      'bank': 'Nubank',
      'balance': -1250.00,
      'icon': 'credit_card',
      'color': Colors.purple,
    },
    {
      'name': 'Carteira Digital',
      'bank': 'PicPay',
      'balance': 156.80,
      'icon': 'account_balance_wallet',
      'color': Colors.orange,
    },
  ];

  String _formatCurrency(double amount) {
    final isNegative = amount < 0;
    final absoluteAmount = amount.abs();
    final formatted =
        'R\$ ${absoluteAmount.toStringAsFixed(2).replaceAll('.', ',')}';
    return isNegative ? '-$formatted' : formatted;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Conta',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.lightTheme.colorScheme.outline
                  .withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Column(
            children: _accounts.asMap().entries.map((entry) {
              final index = entry.key;
              final account = entry.value;
              final isSelected = selectedAccount == account['name'];
              final isLast = index == _accounts.length - 1;

              return Column(
                children: [
                  ListTile(
                    onTap: () => onAccountSelected(account['name']),
                    leading: Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        color:
                            (account['color'] as Color).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: CustomIconWidget(
                        iconName: account['icon'],
                        color: account['color'],
                        size: 20,
                      ),
                    ),
                    title: Text(
                      account['name'],
                      style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          account['bank'],
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          'Saldo: ${_formatCurrency(account['balance'])}',
                          style: AppTheme.lightTheme.textTheme.labelMedium
                              ?.copyWith(
                            color: (account['balance'] as double) >= 0
                                ? AppTheme.getSuccessColor(true)
                                : AppTheme.lightTheme.colorScheme.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    trailing: isSelected
                        ? CustomIconWidget(
                            iconName: 'check_circle',
                            color: AppTheme.lightTheme.colorScheme.primary,
                            size: 24,
                          )
                        : CustomIconWidget(
                            iconName: 'radio_button_unchecked',
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                            size: 24,
                          ),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                  ),
                  if (!isLast)
                    Divider(
                      height: 1,
                      color: AppTheme.lightTheme.colorScheme.outline
                          .withValues(alpha: 0.1),
                      indent: 16.w,
                      endIndent: 4.w,
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
