import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class EmptyStateWidget extends StatelessWidget {
  final bool isSearchResult;
  final String searchQuery;
  final VoidCallback? onAddTransaction;

  const EmptyStateWidget({
    Key? key,
    this.isSearchResult = false,
    this.searchQuery = '',
    this.onAddTransaction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildIllustration(),
            SizedBox(height: 4.h),
            _buildTitle(),
            SizedBox(height: 2.h),
            _buildDescription(),
            SizedBox(height: 4.h),
            if (!isSearchResult) _buildActionButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildIllustration() {
    return Container(
      width: 40.w,
      height: 40.w,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(20.w),
      ),
      child: Center(
        child: CustomIconWidget(
          iconName: isSearchResult ? 'search_off' : 'receipt_long',
          size: 20.w,
          color: AppTheme.lightTheme.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      isSearchResult
          ? 'Nenhum resultado encontrado'
          : 'Nenhuma transação ainda',
      style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildDescription() {
    String description;
    if (isSearchResult) {
      description = searchQuery.isNotEmpty
          ? 'Não encontramos transações para "$searchQuery". Tente usar outros termos ou ajustar os filtros.'
          : 'Não encontramos transações com os filtros aplicados. Tente ajustar os critérios de busca.';
    } else {
      description =
          'Comece a controlar suas finanças adicionando sua primeira transação. É rápido e fácil!';
    }

    return Text(
      description,
      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildActionButton() {
    return ElevatedButton.icon(
      onPressed: onAddTransaction,
      icon: CustomIconWidget(
        iconName: 'add',
        size: 20,
        color: AppTheme.lightTheme.colorScheme.onPrimary,
      ),
      label: Text('Adicionar primeira transação'),
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      ),
    );
  }
}
