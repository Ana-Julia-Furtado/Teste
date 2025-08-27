import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class FilterChipsWidget extends StatelessWidget {
  final Map<String, dynamic> activeFilters;
  final Function(String) onRemoveFilter;
  final VoidCallback onClearAll;

  const FilterChipsWidget({
    Key? key,
    required this.activeFilters,
    required this.onRemoveFilter,
    required this.onClearAll,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final filterChips = _buildFilterChips();

    if (filterChips.isEmpty) {
      return SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Filtros ativos',
                style: AppTheme.lightTheme.textTheme.labelMedium,
              ),
              Spacer(),
              TextButton(
                onPressed: onClearAll,
                child: Text(
                  'Limpar todos',
                  style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Wrap(
            spacing: 2.w,
            runSpacing: 1.h,
            children: filterChips,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFilterChips() {
    List<Widget> chips = [];

    // Categories filter chips
    final categories = activeFilters['categories'] as List<String>?;
    if (categories != null && categories.isNotEmpty) {
      for (String category in categories) {
        chips.add(_buildFilterChip(
          label: category,
          onRemove: () => onRemoveFilter('category_$category'),
        ));
      }
    }

    // Accounts filter chips
    final accounts = activeFilters['accounts'] as List<String>?;
    if (accounts != null && accounts.isNotEmpty) {
      for (String account in accounts) {
        chips.add(_buildFilterChip(
          label: account,
          onRemove: () => onRemoveFilter('account_$account'),
        ));
      }
    }

    // Date range filter chip
    final dateRange = activeFilters['dateRange'] as DateTimeRange?;
    if (dateRange != null) {
      chips.add(_buildFilterChip(
        label:
            '${_formatDate(dateRange.start)} - ${_formatDate(dateRange.end)}',
        onRemove: () => onRemoveFilter('dateRange'),
      ));
    }

    // Amount range filter chip
    final amountRange = activeFilters['amountRange'] as RangeValues?;
    if (amountRange != null &&
        (amountRange.start > 0 || amountRange.end < 10000)) {
      chips.add(_buildFilterChip(
        label:
            'R\$ ${amountRange.start.toInt()} - R\$ ${amountRange.end.toInt()}',
        onRemove: () => onRemoveFilter('amountRange'),
      ));
    }

    return chips;
  }

  Widget _buildFilterChip({
    required String label,
    required VoidCallback onRemove,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.primary,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 3.w),
            child: Text(
              label,
              style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onPrimaryContainer,
              ),
            ),
          ),
          IconButton(
            onPressed: onRemove,
            icon: CustomIconWidget(
              iconName: 'close',
              size: 16,
              color: AppTheme.lightTheme.colorScheme.onPrimaryContainer,
            ),
            constraints: BoxConstraints(
              minWidth: 8.w,
              minHeight: 8.w,
            ),
            padding: EdgeInsets.all(1.w),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
