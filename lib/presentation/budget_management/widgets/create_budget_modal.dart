import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CreateBudgetModal extends StatefulWidget {
  final Function(Map<String, dynamic>) onBudgetCreated;

  const CreateBudgetModal({
    Key? key,
    required this.onBudgetCreated,
  }) : super(key: key);

  @override
  State<CreateBudgetModal> createState() => _CreateBudgetModalState();
}

class _CreateBudgetModalState extends State<CreateBudgetModal> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notificationController = TextEditingController(text: '80');

  String? _selectedCategory;
  String? _selectedIcon;

  final List<Map<String, String>> _categories = [
    {'name': 'Alimentação', 'icon': 'restaurant'},
    {'name': 'Transporte', 'icon': 'directions_car'},
    {'name': 'Moradia', 'icon': 'home'},
    {'name': 'Saúde', 'icon': 'local_hospital'},
    {'name': 'Educação', 'icon': 'school'},
    {'name': 'Entretenimento', 'icon': 'movie'},
    {'name': 'Compras', 'icon': 'shopping_bag'},
    {'name': 'Serviços', 'icon': 'build'},
    {'name': 'Viagem', 'icon': 'flight'},
    {'name': 'Outros', 'icon': 'category'},
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _notificationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 85.h,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.primary,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Container(
                  width: 12.w,
                  height: 0.5.h,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(height: 2.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Criar Orçamento',
                      style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: EdgeInsets.all(2.w),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: CustomIconWidget(
                          iconName: 'close',
                          color: Colors.white,
                          size: 5.w,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(4.w),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Categoria',
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    _buildCategoryGrid(),
                    SizedBox(height: 3.h),
                    Text(
                      'Valor do Orçamento',
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    TextFormField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        _CurrencyInputFormatter(),
                      ],
                      decoration: InputDecoration(
                        hintText: 'R\$ 0,00',
                        prefixIcon: Padding(
                          padding: EdgeInsets.all(3.w),
                          child: CustomIconWidget(
                            iconName: 'attach_money',
                            color: AppTheme.lightTheme.colorScheme.primary,
                            size: 5.w,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira um valor';
                        }
                        final numericValue = _parseAmount(value);
                        if (numericValue <= 0) {
                          return 'O valor deve ser maior que zero';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      'Alerta de Notificação (%)',
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    TextFormField(
                      controller: _notificationController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(3),
                      ],
                      decoration: InputDecoration(
                        hintText: '80',
                        suffixText: '%',
                        prefixIcon: Padding(
                          padding: EdgeInsets.all(3.w),
                          child: CustomIconWidget(
                            iconName: 'notifications',
                            color: AppTheme.lightTheme.colorScheme.primary,
                            size: 5.w,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          final percentage = int.tryParse(value);
                          if (percentage == null ||
                              percentage < 1 ||
                              percentage > 100) {
                            return 'Insira um valor entre 1 e 100';
                          }
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      'Você será notificado quando atingir esta porcentagem do orçamento',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _createBudget,
                        child: Text('Criar Orçamento'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2.w,
        mainAxisSpacing: 1.h,
        childAspectRatio: 1.2,
      ),
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        final category = _categories[index];
        final isSelected = _selectedCategory == category['name'];

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedCategory = category['name'];
              _selectedIcon = category['icon'];
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.lightTheme.colorScheme.primary
                      .withValues(alpha: 0.1)
                  : AppTheme.lightTheme.colorScheme.surface,
              border: Border.all(
                color: isSelected
                    ? AppTheme.lightTheme.colorScheme.primary
                    : AppTheme.lightTheme.colorScheme.outline,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomIconWidget(
                  iconName: category['icon']!,
                  color: isSelected
                      ? AppTheme.lightTheme.colorScheme.primary
                      : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  size: 6.w,
                ),
                SizedBox(height: 0.5.h),
                Text(
                  category['name']!,
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: isSelected
                        ? AppTheme.lightTheme.colorScheme.primary
                        : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _createBudget() {
    if (_formKey.currentState!.validate() && _selectedCategory != null) {
      final amount = _parseAmount(_amountController.text);
      final notificationThreshold =
          int.tryParse(_notificationController.text) ?? 80;

      final budgetData = {
        'id': DateTime.now().millisecondsSinceEpoch,
        'category': _selectedCategory!,
        'icon': _selectedIcon!,
        'allocated': amount,
        'spent': 0.0,
        'notificationThreshold': notificationThreshold,
        'createdAt': DateTime.now(),
      };

      widget.onBudgetCreated(budgetData);
      Navigator.pop(context);
    } else if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecione uma categoria'),
        ),
      );
    }
  }

  double _parseAmount(String text) {
    final cleanText = text.replaceAll(RegExp(r'[^\d]'), '');
    if (cleanText.isEmpty) return 0.0;
    return double.parse(cleanText) / 100;
  }
}

class _CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    final value =
        int.tryParse(newValue.text.replaceAll(RegExp(r'[^\d]'), '')) ?? 0;
    final formattedValue =
        (value / 100).toStringAsFixed(2).replaceAll('.', ',');
    final newText = 'R\$ $formattedValue';

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
