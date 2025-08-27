import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CategorySelectionWidget extends StatefulWidget {
  final String? selectedCategory;
  final Function(String) onCategorySelected;

  const CategorySelectionWidget({
    Key? key,
    this.selectedCategory,
    required this.onCategorySelected,
  }) : super(key: key);

  @override
  State<CategorySelectionWidget> createState() =>
      _CategorySelectionWidgetState();
}

class _CategorySelectionWidgetState extends State<CategorySelectionWidget> {
  bool _showAllCategories = false;

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Alimentação', 'icon': 'restaurant', 'color': Colors.orange},
    {'name': 'Transporte', 'icon': 'directions_car', 'color': Colors.blue},
    {'name': 'Saúde', 'icon': 'local_hospital', 'color': Colors.red},
    {'name': 'Educação', 'icon': 'school', 'color': Colors.green},
    {'name': 'Lazer', 'icon': 'movie', 'color': Colors.purple},
    {'name': 'Casa', 'icon': 'home', 'color': Colors.brown},
    {'name': 'Roupas', 'icon': 'shopping_bag', 'color': Colors.pink},
    {'name': 'Tecnologia', 'icon': 'phone_android', 'color': Colors.indigo},
    {'name': 'Viagem', 'icon': 'flight', 'color': Colors.teal},
    {'name': 'Outros', 'icon': 'more_horiz', 'color': Colors.grey},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Categoria',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (!_showAllCategories)
              TextButton(
                onPressed: () {
                  setState(() {
                    _showAllCategories = true;
                  });
                },
                child: Text(
                  'Ver todas',
                  style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.primary,
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: 2.h),
        _showAllCategories ? _buildCategoryGrid() : _buildCategoryChips(),
      ],
    );
  }

  Widget _buildCategoryChips() {
    final displayCategories = _categories.take(5).toList();

    return SizedBox(
      height: 6.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: displayCategories.length,
        separatorBuilder: (context, index) => SizedBox(width: 2.w),
        itemBuilder: (context, index) {
          final category = displayCategories[index];
          final isSelected = widget.selectedCategory == category['name'];

          return _buildCategoryChip(category, isSelected);
        },
      ),
    );
  }

  Widget _buildCategoryGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 3.w,
        mainAxisSpacing: 2.h,
        childAspectRatio: 2.5,
      ),
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        final category = _categories[index];
        final isSelected = widget.selectedCategory == category['name'];

        return _buildCategoryChip(category, isSelected);
      },
    );
  }

  Widget _buildCategoryChip(Map<String, dynamic> category, bool isSelected) {
    return GestureDetector(
      onTap: () => widget.onCategorySelected(category['name']),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: isSelected
              ? category['color'].withValues(alpha: 0.1)
              : AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? category['color']
                : AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconWidget(
              iconName: category['icon'],
              color: isSelected
                  ? category['color']
                  : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 18,
            ),
            SizedBox(width: 1.w),
            Flexible(
              child: Text(
                category['name'],
                style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                  color: isSelected
                      ? category['color']
                      : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
