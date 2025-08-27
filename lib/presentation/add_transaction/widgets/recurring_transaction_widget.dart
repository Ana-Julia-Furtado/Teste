import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

enum RecurringFrequency { none, weekly, monthly, yearly }

class RecurringTransactionWidget extends StatelessWidget {
  final bool isRecurring;
  final RecurringFrequency frequency;
  final Function(bool) onRecurringChanged;
  final Function(RecurringFrequency) onFrequencyChanged;

  const RecurringTransactionWidget({
    Key? key,
    required this.isRecurring,
    required this.frequency,
    required this.onRecurringChanged,
    required this.onFrequencyChanged,
  }) : super(key: key);

  String _getFrequencyLabel(RecurringFrequency freq) {
    switch (freq) {
      case RecurringFrequency.weekly:
        return 'Semanal';
      case RecurringFrequency.monthly:
        return 'Mensal';
      case RecurringFrequency.yearly:
        return 'Anual';
      case RecurringFrequency.none:
        return 'Selecionar';
    }
  }

  String _getFrequencyDescription(RecurringFrequency freq) {
    switch (freq) {
      case RecurringFrequency.weekly:
        return 'Toda semana no mesmo dia';
      case RecurringFrequency.monthly:
        return 'Todo mês no mesmo dia';
      case RecurringFrequency.yearly:
        return 'Todo ano na mesma data';
      case RecurringFrequency.none:
        return 'Escolha a frequência';
    }
  }

  void _showFrequencySelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Frequência',
                    style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: CustomIconWidget(
                      iconName: 'close',
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
            _buildFrequencyOption(
              context,
              RecurringFrequency.weekly,
              'repeat',
              Colors.blue,
            ),
            _buildFrequencyOption(
              context,
              RecurringFrequency.monthly,
              'calendar_month',
              Colors.green,
            ),
            _buildFrequencyOption(
              context,
              RecurringFrequency.yearly,
              'event_repeat',
              Colors.orange,
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  Widget _buildFrequencyOption(
    BuildContext context,
    RecurringFrequency freq,
    String iconName,
    Color color,
  ) {
    final isSelected = frequency == freq;

    return ListTile(
      onTap: () {
        onFrequencyChanged(freq);
        Navigator.pop(context);
      },
      leading: Container(
        padding: EdgeInsets.all(2.w),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: CustomIconWidget(
          iconName: iconName,
          color: color,
          size: 20,
        ),
      ),
      title: Text(
        _getFrequencyLabel(freq),
        style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        _getFrequencyDescription(freq),
        style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
          color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: isSelected
          ? CustomIconWidget(
              iconName: 'check_circle',
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 24,
            )
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Transação Recorrente',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Switch(
              value: isRecurring,
              onChanged: onRecurringChanged,
            ),
          ],
        ),
        if (isRecurring) ...[
          SizedBox(height: 1.h),
          GestureDetector(
            onTap: () => _showFrequencySelector(context),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.lightTheme.colorScheme.outline
                      .withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.primary
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: CustomIconWidget(
                      iconName: frequency == RecurringFrequency.weekly
                          ? 'repeat'
                          : frequency == RecurringFrequency.monthly
                              ? 'calendar_month'
                              : frequency == RecurringFrequency.yearly
                                  ? 'event_repeat'
                                  : 'schedule',
                      color: AppTheme.lightTheme.colorScheme.primary,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getFrequencyLabel(frequency),
                          style: AppTheme.lightTheme.textTheme.titleSmall
                              ?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          _getFrequencyDescription(frequency),
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  CustomIconWidget(
                    iconName: 'keyboard_arrow_down',
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          if (frequency != RecurringFrequency.none) ...[
            SizedBox(height: 1.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.primary
                    .withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.lightTheme.colorScheme.primary
                      .withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'info',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 16,
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      'Esta transação será repetida automaticamente conforme a frequência selecionada.',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ],
    );
  }
}
