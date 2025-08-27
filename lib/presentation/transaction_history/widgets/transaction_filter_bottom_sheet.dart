import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class TransactionFilterBottomSheet extends StatefulWidget {
  final Map<String, dynamic> currentFilters;
  final Function(Map<String, dynamic>) onFiltersApplied;

  const TransactionFilterBottomSheet({
    Key? key,
    required this.currentFilters,
    required this.onFiltersApplied,
  }) : super(key: key);

  @override
  State<TransactionFilterBottomSheet> createState() =>
      _TransactionFilterBottomSheetState();
}

class _TransactionFilterBottomSheetState
    extends State<TransactionFilterBottomSheet> {
  late Map<String, dynamic> _filters;
  DateTimeRange? _selectedDateRange;
  RangeValues _amountRange = const RangeValues(0, 10000);

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Alimentação', 'icon': 'restaurant', 'color': Colors.orange},
    {'name': 'Transporte', 'icon': 'directions_car', 'color': Colors.blue},
    {'name': 'Saúde', 'icon': 'local_hospital', 'color': Colors.red},
    {'name': 'Educação', 'icon': 'school', 'color': Colors.green},
    {'name': 'Entretenimento', 'icon': 'movie', 'color': Colors.purple},
    {'name': 'Compras', 'icon': 'shopping_bag', 'color': Colors.pink},
    {'name': 'Contas', 'icon': 'receipt', 'color': Colors.brown},
    {'name': 'Outros', 'icon': 'category', 'color': Colors.grey},
  ];

  final List<String> _accounts = [
    'Conta Corrente',
    'Poupança',
    'Cartão de Crédito',
    'Dinheiro',
    'Conta Investimento',
  ];

  @override
  void initState() {
    super.initState();
    _filters = Map<String, dynamic>.from(widget.currentFilters);
    _selectedDateRange = _filters['dateRange'] as DateTimeRange?;
    _amountRange =
        _filters['amountRange'] as RangeValues? ?? const RangeValues(0, 10000);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 85.h,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCategoryFilter(),
                  SizedBox(height: 3.h),
                  _buildDateRangeFilter(),
                  SizedBox(height: 3.h),
                  _buildAmountRangeFilter(),
                  SizedBox(height: 3.h),
                  _buildAccountFilter(),
                  SizedBox(height: 4.h),
                ],
              ),
            ),
          ),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Text(
            'Filtros',
            style: AppTheme.lightTheme.textTheme.titleLarge,
          ),
          Spacer(),
          TextButton(
            onPressed: _clearAllFilters,
            child: Text(
              'Limpar Tudo',
              style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                color: AppTheme.lightTheme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categorias',
          style: AppTheme.lightTheme.textTheme.titleMedium,
        ),
        SizedBox(height: 1.h),
        Wrap(
          spacing: 2.w,
          runSpacing: 1.h,
          children: _categories.map((category) {
            final isSelected = (_filters['categories'] as List<String>? ?? [])
                .contains(category['name']);
            return FilterChip(
              selected: isSelected,
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomIconWidget(
                    iconName: category['icon'],
                    size: 16,
                    color: isSelected
                        ? AppTheme.lightTheme.colorScheme.onPrimary
                        : category['color'],
                  ),
                  SizedBox(width: 1.w),
                  Text(category['name']),
                ],
              ),
              onSelected: (selected) =>
                  _toggleCategory(category['name'], selected),
              selectedColor: AppTheme.lightTheme.colorScheme.primary,
              backgroundColor: AppTheme.lightTheme.colorScheme.surface,
              side: BorderSide(
                color: isSelected
                    ? AppTheme.lightTheme.colorScheme.primary
                    : AppTheme.lightTheme.colorScheme.outline,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDateRangeFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Período',
          style: AppTheme.lightTheme.textTheme.titleMedium,
        ),
        SizedBox(height: 1.h),
        InkWell(
          onTap: _selectDateRange,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            decoration: BoxDecoration(
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.outline,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'calendar_today',
                  size: 20,
                  color: AppTheme.lightTheme.colorScheme.primary,
                ),
                SizedBox(width: 3.w),
                Text(
                  _selectedDateRange != null
                      ? '${_formatDate(_selectedDateRange!.start)} - ${_formatDate(_selectedDateRange!.end)}'
                      : 'Selecionar período',
                  style: AppTheme.lightTheme.textTheme.bodyMedium,
                ),
                Spacer(),
                CustomIconWidget(
                  iconName: 'arrow_forward_ios',
                  size: 16,
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAmountRangeFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Valor',
          style: AppTheme.lightTheme.textTheme.titleMedium,
        ),
        SizedBox(height: 1.h),
        Row(
          children: [
            Text(
              'R\$ ${_amountRange.start.toInt()}',
              style: AppTheme.lightTheme.textTheme.bodySmall,
            ),
            Spacer(),
            Text(
              'R\$ ${_amountRange.end.toInt()}',
              style: AppTheme.lightTheme.textTheme.bodySmall,
            ),
          ],
        ),
        RangeSlider(
          values: _amountRange,
          min: 0,
          max: 10000,
          divisions: 100,
          labels: RangeLabels(
            'R\$ ${_amountRange.start.toInt()}',
            'R\$ ${_amountRange.end.toInt()}',
          ),
          onChanged: (values) {
            setState(() {
              _amountRange = values;
            });
          },
        ),
      ],
    );
  }

  Widget _buildAccountFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Contas',
          style: AppTheme.lightTheme.textTheme.titleMedium,
        ),
        SizedBox(height: 1.h),
        Wrap(
          spacing: 2.w,
          runSpacing: 1.h,
          children: _accounts.map((account) {
            final isSelected =
                (_filters['accounts'] as List<String>? ?? []).contains(account);
            return FilterChip(
              selected: isSelected,
              label: Text(account),
              onSelected: (selected) => _toggleAccount(account, selected),
              selectedColor: AppTheme.lightTheme.colorScheme.primary,
              backgroundColor: AppTheme.lightTheme.colorScheme.surface,
              side: BorderSide(
                color: isSelected
                    ? AppTheme.lightTheme.colorScheme.primary
                    : AppTheme.lightTheme.colorScheme.outline,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar'),
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: ElevatedButton(
              onPressed: _applyFilters,
              child: Text('Aplicar Filtros'),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleCategory(String category, bool selected) {
    setState(() {
      final categories =
          (_filters['categories'] as List<String>? ?? []).toList();
      if (selected) {
        categories.add(category);
      } else {
        categories.remove(category);
      }
      _filters['categories'] = categories;
    });
  }

  void _toggleAccount(String account, bool selected) {
    setState(() {
      final accounts = (_filters['accounts'] as List<String>? ?? []).toList();
      if (selected) {
        accounts.add(account);
      } else {
        accounts.remove(account);
      }
      _filters['accounts'] = accounts;
    });
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: AppTheme.lightTheme.colorScheme,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
        _filters['dateRange'] = picked;
      });
    }
  }

  void _clearAllFilters() {
    setState(() {
      _filters.clear();
      _selectedDateRange = null;
      _amountRange = const RangeValues(0, 10000);
    });
  }

  void _applyFilters() {
    _filters['amountRange'] = _amountRange;
    widget.onFiltersApplied(_filters);
    Navigator.pop(context);
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
