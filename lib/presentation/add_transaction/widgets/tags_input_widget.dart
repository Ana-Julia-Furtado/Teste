import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class TagsInputWidget extends StatefulWidget {
  final List<String> selectedTags;
  final Function(List<String>) onTagsChanged;

  const TagsInputWidget({
    Key? key,
    required this.selectedTags,
    required this.onTagsChanged,
  }) : super(key: key);

  @override
  State<TagsInputWidget> createState() => _TagsInputWidgetState();
}

class _TagsInputWidgetState extends State<TagsInputWidget> {
  final TextEditingController _tagController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _showSuggestions = false;

  final List<String> _availableTags = [
    'trabalho',
    'pessoal',
    'urgente',
    'recorrente',
    'investimento',
    'lazer',
    'saúde',
    'educação',
    'família',
    'viagem',
    'casa',
    'carro',
    'presente',
    'emergência',
    'economia',
  ];

  List<String> _filteredTags = [];

  @override
  void initState() {
    super.initState();
    _tagController.addListener(_onTagInputChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _tagController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTagInputChanged() {
    final text = _tagController.text.toLowerCase();
    if (text.isNotEmpty) {
      _filteredTags = _availableTags
          .where((tag) =>
              tag.toLowerCase().contains(text) &&
              !widget.selectedTags.contains(tag))
          .take(5)
          .toList();
    } else {
      _filteredTags = _availableTags
          .where((tag) => !widget.selectedTags.contains(tag))
          .take(5)
          .toList();
    }
    setState(() {});
  }

  void _onFocusChanged() {
    setState(() {
      _showSuggestions = _focusNode.hasFocus;
    });
  }

  void _addTag(String tag) {
    if (tag.isNotEmpty && !widget.selectedTags.contains(tag)) {
      final updatedTags = [...widget.selectedTags, tag];
      widget.onTagsChanged(updatedTags);
      _tagController.clear();
      _onTagInputChanged();
    }
  }

  void _removeTag(String tag) {
    final updatedTags = widget.selectedTags.where((t) => t != tag).toList();
    widget.onTagsChanged(updatedTags);
    _onTagInputChanged();
  }

  void _onSubmitted(String value) {
    _addTag(value.trim().toLowerCase());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tags (Opcional)',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),

        // Selected tags display
        if (widget.selectedTags.isNotEmpty) ...[
          Wrap(
            spacing: 2.w,
            runSpacing: 1.h,
            children: widget.selectedTags
                .map((tag) => _buildSelectedTag(tag))
                .toList(),
          ),
          SizedBox(height: 1.h),
        ],

        // Tag input field
        TextField(
          controller: _tagController,
          focusNode: _focusNode,
          style: AppTheme.lightTheme.textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: 'Digite uma tag...',
            prefixIcon: Padding(
              padding: EdgeInsets.all(3.w),
              child: CustomIconWidget(
                iconName: 'local_offer',
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
            ),
            suffixIcon: _tagController.text.isNotEmpty
                ? IconButton(
                    onPressed: () => _addTag(_tagController.text.trim()),
                    icon: CustomIconWidget(
                      iconName: 'add',
                      color: AppTheme.lightTheme.colorScheme.primary,
                      size: 20,
                    ),
                  )
                : null,
          ),
          textCapitalization: TextCapitalization.none,
          onSubmitted: _onSubmitted,
          maxLines: 1,
        ),

        // Tag suggestions
        if (_showSuggestions && _filteredTags.isNotEmpty) ...[
          SizedBox(height: 1.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(3.w),
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
                Text(
                  'Sugestões',
                  style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: 1.h),
                Wrap(
                  spacing: 2.w,
                  runSpacing: 1.h,
                  children: _filteredTags
                      .map((tag) => _buildSuggestionTag(tag))
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSelectedTag(String tag) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.primary,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            tag,
            style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 1.w),
          GestureDetector(
            onTap: () => _removeTag(tag),
            child: CustomIconWidget(
              iconName: 'close',
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionTag(String tag) {
    return GestureDetector(
      onTap: () => _addTag(tag),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconWidget(
              iconName: 'add',
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 14,
            ),
            SizedBox(width: 1.w),
            Text(
              tag,
              style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
