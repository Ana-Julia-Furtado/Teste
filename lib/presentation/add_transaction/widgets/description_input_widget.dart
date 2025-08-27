import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class DescriptionInputWidget extends StatefulWidget {
  final Function(String) onDescriptionChanged;
  final String? initialDescription;

  const DescriptionInputWidget({
    Key? key,
    required this.onDescriptionChanged,
    this.initialDescription,
  }) : super(key: key);

  @override
  State<DescriptionInputWidget> createState() => _DescriptionInputWidgetState();
}

class _DescriptionInputWidgetState extends State<DescriptionInputWidget> {
  final TextEditingController _descriptionController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _showSuggestions = false;

  final List<String> _recentTransactions = [
    'Almoço no restaurante',
    'Combustível posto Shell',
    'Supermercado Extra',
    'Farmácia Drogasil',
    'Uber para trabalho',
    'Netflix mensalidade',
    'Academia Smart Fit',
    'Padaria da esquina',
  ];

  List<String> _filteredSuggestions = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialDescription != null) {
      _descriptionController.text = widget.initialDescription!;
    }
    _descriptionController.addListener(_onDescriptionChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onDescriptionChanged() {
    final text = _descriptionController.text;
    widget.onDescriptionChanged(text);

    if (text.isNotEmpty) {
      _filteredSuggestions = _recentTransactions
          .where((suggestion) =>
              suggestion.toLowerCase().contains(text.toLowerCase()))
          .take(3)
          .toList();
    } else {
      _filteredSuggestions = _recentTransactions.take(3).toList();
    }

    setState(() {});
  }

  void _onFocusChanged() {
    setState(() {
      _showSuggestions = _focusNode.hasFocus;
    });
  }

  void _selectSuggestion(String suggestion) {
    _descriptionController.text = suggestion;
    widget.onDescriptionChanged(suggestion);
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Descrição',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        TextField(
          controller: _descriptionController,
          focusNode: _focusNode,
          style: AppTheme.lightTheme.textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: 'Digite uma descrição...',
            prefixIcon: Padding(
              padding: EdgeInsets.all(3.w),
              child: CustomIconWidget(
                iconName: 'edit',
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
            ),
          ),
          textCapitalization: TextCapitalization.sentences,
          maxLines: 1,
        ),
        if (_showSuggestions && _filteredSuggestions.isNotEmpty) ...[
          SizedBox(height: 1.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 1.h),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Text(
                    'Sugestões recentes',
                    style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                SizedBox(height: 0.5.h),
                ..._filteredSuggestions.map((suggestion) => ListTile(
                      dense: true,
                      leading: CustomIconWidget(
                        iconName: 'history',
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        size: 18,
                      ),
                      title: Text(
                        suggestion,
                        style: AppTheme.lightTheme.textTheme.bodyMedium,
                      ),
                      onTap: () => _selectSuggestion(suggestion),
                    )),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
