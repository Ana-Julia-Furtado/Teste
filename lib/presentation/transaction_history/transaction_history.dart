import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/date_section_header.dart';
import './widgets/empty_state_widget.dart';
import './widgets/filter_chips_widget.dart';
import './widgets/search_bar_widget.dart';
import './widgets/transaction_card.dart';
import './widgets/transaction_filter_bottom_sheet.dart';

class TransactionHistory extends StatefulWidget {
  const TransactionHistory({Key? key}) : super(key: key);

  @override
  State<TransactionHistory> createState() => _TransactionHistoryState();
}

class _TransactionHistoryState extends State<TransactionHistory> {
  final ScrollController _scrollController = ScrollController();
  String _searchQuery = '';
  Map<String, dynamic> _activeFilters = {};
  List<int> _selectedTransactionIds = [];
  bool _isMultiSelectMode = false;
  bool _isLoading = false;
  bool _hasMoreData = true;
  int _currentPage = 1;

  // Mock transaction data
  final List<Map<String, dynamic>> _allTransactions = [
    {
      'id': 1,
      'description': 'Supermercado Extra',
      'amount': -156.78,
      'type': 'expense',
      'category': 'Alimentação',
      'account': 'Cartão de Crédito',
      'date': DateTime.now().subtract(Duration(hours: 2)),
    },
    {
      'id': 2,
      'description': 'Salário Mensal',
      'amount': 4500.00,
      'type': 'income',
      'category': 'Salário',
      'account': 'Conta Corrente',
      'date': DateTime.now().subtract(Duration(hours: 8)),
    },
    {
      'id': 3,
      'description': 'Posto Shell',
      'amount': -89.50,
      'type': 'expense',
      'category': 'Transporte',
      'account': 'Conta Corrente',
      'date': DateTime.now().subtract(Duration(days: 1, hours: 3)),
    },
    {
      'id': 4,
      'description': 'Farmácia São Paulo',
      'amount': -45.90,
      'type': 'expense',
      'category': 'Saúde',
      'account': 'Cartão de Crédito',
      'date': DateTime.now().subtract(Duration(days: 1, hours: 5)),
    },
    {
      'id': 5,
      'description': 'Netflix',
      'amount': -29.90,
      'type': 'expense',
      'category': 'Entretenimento',
      'account': 'Cartão de Crédito',
      'date': DateTime.now().subtract(Duration(days: 2, hours: 1)),
    },
    {
      'id': 6,
      'description': 'Freelance Design',
      'amount': 800.00,
      'type': 'income',
      'category': 'Freelance',
      'account': 'Conta Corrente',
      'date': DateTime.now().subtract(Duration(days: 3, hours: 2)),
    },
    {
      'id': 7,
      'description': 'Shopping Center Norte',
      'amount': -234.67,
      'type': 'expense',
      'category': 'Compras',
      'account': 'Cartão de Crédito',
      'date': DateTime.now().subtract(Duration(days: 4, hours: 4)),
    },
    {
      'id': 8,
      'description': 'Conta de Luz',
      'amount': -127.45,
      'type': 'expense',
      'category': 'Contas',
      'account': 'Conta Corrente',
      'date': DateTime.now().subtract(Duration(days: 5, hours: 1)),
    },
    {
      'id': 9,
      'description': 'Dividendos Ações',
      'amount': 150.30,
      'type': 'income',
      'category': 'Investimentos',
      'account': 'Conta Investimento',
      'date': DateTime.now().subtract(Duration(days: 6, hours: 3)),
    },
    {
      'id': 10,
      'description': 'Restaurante Japonês',
      'amount': -98.75,
      'type': 'expense',
      'category': 'Alimentação',
      'account': 'Cartão de Crédito',
      'date': DateTime.now().subtract(Duration(days: 7, hours: 2)),
    },
  ];

  List<Map<String, dynamic>> _filteredTransactions = [];
  Map<String, List<Map<String, dynamic>>> _groupedTransactions = {};

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _applyFilters();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreTransactions();
    }
  }

  void _loadMoreTransactions() {
    if (!_isLoading && _hasMoreData) {
      setState(() {
        _isLoading = true;
      });

      // Simulate loading more data
      Future.delayed(Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _currentPage++;
            // In a real app, you would load more transactions here
            if (_currentPage > 3) {
              _hasMoreData = false;
            }
          });
        }
      });
    }
  }

  void _applyFilters() {
    List<Map<String, dynamic>> filtered = List.from(_allTransactions);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((transaction) {
        final description =
            (transaction['description'] as String).toLowerCase();
        final category = (transaction['category'] as String).toLowerCase();
        final query = _searchQuery.toLowerCase();
        return description.contains(query) || category.contains(query);
      }).toList();
    }

    // Apply category filter
    final categories = _activeFilters['categories'] as List<String>?;
    if (categories != null && categories.isNotEmpty) {
      filtered = filtered.where((transaction) {
        return categories.contains(transaction['category']);
      }).toList();
    }

    // Apply account filter
    final accounts = _activeFilters['accounts'] as List<String>?;
    if (accounts != null && accounts.isNotEmpty) {
      filtered = filtered.where((transaction) {
        return accounts.contains(transaction['account']);
      }).toList();
    }

    // Apply date range filter
    final dateRange = _activeFilters['dateRange'] as DateTimeRange?;
    if (dateRange != null) {
      filtered = filtered.where((transaction) {
        final date = transaction['date'] as DateTime;
        return date.isAfter(dateRange.start.subtract(Duration(days: 1))) &&
            date.isBefore(dateRange.end.add(Duration(days: 1)));
      }).toList();
    }

    // Apply amount range filter
    final amountRange = _activeFilters['amountRange'] as RangeValues?;
    if (amountRange != null) {
      filtered = filtered.where((transaction) {
        final amount = (transaction['amount'] as double).abs();
        return amount >= amountRange.start && amount <= amountRange.end;
      }).toList();
    }

    // Sort by date (newest first)
    filtered.sort(
        (a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));

    setState(() {
      _filteredTransactions = filtered;
      _groupedTransactions = _groupTransactionsByDate(filtered);
    });
  }

  Map<String, List<Map<String, dynamic>>> _groupTransactionsByDate(
      List<Map<String, dynamic>> transactions) {
    Map<String, List<Map<String, dynamic>>> grouped = {};

    for (var transaction in transactions) {
      final date = transaction['date'] as DateTime;
      final dateKey =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(transaction);
    }

    return grouped;
  }

  double _getDayTotal(List<Map<String, dynamic>> transactions) {
    return transactions.fold(
        0.0, (sum, transaction) => sum + (transaction['amount'] as double));
  }

  int _getActiveFiltersCount() {
    int count = 0;

    final categories = _activeFilters['categories'] as List<String>?;
    if (categories != null && categories.isNotEmpty) count += categories.length;

    final accounts = _activeFilters['accounts'] as List<String>?;
    if (accounts != null && accounts.isNotEmpty) count += accounts.length;

    if (_activeFilters['dateRange'] != null) count++;

    final amountRange = _activeFilters['amountRange'] as RangeValues?;
    if (amountRange != null &&
        (amountRange.start > 0 || amountRange.end < 10000)) count++;

    return count;
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TransactionFilterBottomSheet(
        currentFilters: _activeFilters,
        onFiltersApplied: (filters) {
          setState(() {
            _activeFilters = filters;
          });
          _applyFilters();
        },
      ),
    );
  }

  void _removeFilter(String filterKey) {
    setState(() {
      if (filterKey.startsWith('category_')) {
        final category = filterKey.substring(9);
        final categories =
            (_activeFilters['categories'] as List<String>? ?? []).toList();
        categories.remove(category);
        if (categories.isEmpty) {
          _activeFilters.remove('categories');
        } else {
          _activeFilters['categories'] = categories;
        }
      } else if (filterKey.startsWith('account_')) {
        final account = filterKey.substring(8);
        final accounts =
            (_activeFilters['accounts'] as List<String>? ?? []).toList();
        accounts.remove(account);
        if (accounts.isEmpty) {
          _activeFilters.remove('accounts');
        } else {
          _activeFilters['accounts'] = accounts;
        }
      } else {
        _activeFilters.remove(filterKey);
      }
    });
    _applyFilters();
  }

  void _clearAllFilters() {
    setState(() {
      _activeFilters.clear();
      _searchQuery = '';
    });
    _applyFilters();
  }

  void _toggleTransactionSelection(int transactionId) {
    setState(() {
      if (_selectedTransactionIds.contains(transactionId)) {
        _selectedTransactionIds.remove(transactionId);
      } else {
        _selectedTransactionIds.add(transactionId);
      }

      if (_selectedTransactionIds.isEmpty) {
        _isMultiSelectMode = false;
      }
    });
  }

  void _enterMultiSelectMode(int transactionId) {
    setState(() {
      _isMultiSelectMode = true;
      _selectedTransactionIds = [transactionId];
    });
  }

  void _exitMultiSelectMode() {
    setState(() {
      _isMultiSelectMode = false;
      _selectedTransactionIds.clear();
    });
  }

  void _showBulkActionsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Ações em Lote'),
        content:
            Text('${_selectedTransactionIds.length} transações selecionadas'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteSelectedTransactions();
            },
            child: Text(
              'Excluir',
              style: TextStyle(color: AppTheme.lightTheme.colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  void _deleteSelectedTransactions() {
    setState(() {
      _allTransactions.removeWhere(
          (transaction) => _selectedTransactionIds.contains(transaction['id']));
      _exitMultiSelectMode();
    });
    _applyFilters();
  }

  Future<void> _refreshTransactions() async {
    await Future.delayed(Duration(seconds: 1));
    _applyFilters();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          SearchBarWidget(
            searchQuery: _searchQuery,
            onSearchChanged: (query) {
              setState(() {
                _searchQuery = query;
              });
              _applyFilters();
            },
            onFilterPressed: _showFilterBottomSheet,
            activeFiltersCount: _getActiveFiltersCount(),
          ),
          if (_getActiveFiltersCount() > 0)
            FilterChipsWidget(
              activeFilters: _activeFilters,
              onRemoveFilter: _removeFilter,
              onClearAll: _clearAllFilters,
            ),
          Expanded(
            child: _buildTransactionsList(),
          ),
        ],
      ),
      floatingActionButton: _isMultiSelectMode ? null : _buildFAB(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(_isMultiSelectMode
          ? '${_selectedTransactionIds.length} selecionadas'
          : 'Histórico de Transações'),
      leading: _isMultiSelectMode
          ? IconButton(
              onPressed: _exitMultiSelectMode,
              icon: CustomIconWidget(
                iconName: 'close',
                size: 24,
                color: AppTheme.lightTheme.colorScheme.onSurface,
              ),
            )
          : IconButton(
              onPressed: () => Navigator.pop(context),
              icon: CustomIconWidget(
                iconName: 'arrow_back',
                size: 24,
                color: AppTheme.lightTheme.colorScheme.onSurface,
              ),
            ),
      actions: _isMultiSelectMode
          ? [
              IconButton(
                onPressed: _showBulkActionsDialog,
                icon: CustomIconWidget(
                  iconName: 'more_vert',
                  size: 24,
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                ),
              ),
            ]
          : [
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'export') {
                    _showExportDialog();
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'export',
                    child: Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'download',
                          size: 20,
                          color: AppTheme.lightTheme.colorScheme.onSurface,
                        ),
                        SizedBox(width: 2.w),
                        Text('Exportar'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
    );
  }

  Widget _buildTransactionsList() {
    if (_filteredTransactions.isEmpty) {
      return EmptyStateWidget(
        isSearchResult: _searchQuery.isNotEmpty || _getActiveFiltersCount() > 0,
        searchQuery: _searchQuery,
        onAddTransaction: () =>
            Navigator.pushNamed(context, '/add-transaction'),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshTransactions,
      child: ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.only(bottom: 10.h),
        itemCount: _groupedTransactions.length + (_isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _groupedTransactions.length) {
            return _buildLoadingIndicator();
          }

          final dateKey = _groupedTransactions.keys.elementAt(index);
          final transactions = _groupedTransactions[dateKey]!;
          final date = DateTime.parse(dateKey);
          final dayTotal = _getDayTotal(transactions);

          return Column(
            children: [
              DateSectionHeader(
                date: date,
                totalAmount: dayTotal,
                transactionCount: transactions.length,
              ),
              ...transactions
                  .map((transaction) => TransactionCard(
                        transaction: transaction,
                        isSelected:
                            _selectedTransactionIds.contains(transaction['id']),
                        onTap: () {
                          if (_isMultiSelectMode) {
                            _toggleTransactionSelection(transaction['id']);
                          }
                        },
                        onLongPress: () {
                          if (!_isMultiSelectMode) {
                            _enterMultiSelectMode(transaction['id']);
                          }
                        },
                        onEdit: () => _editTransaction(transaction),
                        onDelete: () => _deleteTransaction(transaction),
                        onDuplicate: () => _duplicateTransaction(transaction),
                      ))
                  .toList(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      padding: EdgeInsets.all(4.w),
      child: Center(
        child: CircularProgressIndicator(
          color: AppTheme.lightTheme.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton(
      onPressed: () => Navigator.pushNamed(context, '/add-transaction'),
      child: CustomIconWidget(
        iconName: 'add',
        size: 24,
        color: AppTheme.lightTheme.colorScheme.onPrimary,
      ),
    );
  }

  void _editTransaction(Map<String, dynamic> transaction) {
    // Navigate to edit transaction screen
    Navigator.pushNamed(context, '/add-transaction', arguments: transaction);
  }

  void _deleteTransaction(Map<String, dynamic> transaction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Excluir Transação'),
        content: Text('Tem certeza que deseja excluir esta transação?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _allTransactions
                    .removeWhere((t) => t['id'] == transaction['id']);
              });
              _applyFilters();
              Navigator.pop(context);
            },
            child: Text(
              'Excluir',
              style: TextStyle(color: AppTheme.lightTheme.colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  void _duplicateTransaction(Map<String, dynamic> transaction) {
    final newTransaction = Map<String, dynamic>.from(transaction);
    newTransaction['id'] = DateTime.now().millisecondsSinceEpoch;
    newTransaction['date'] = DateTime.now();

    setState(() {
      _allTransactions.insert(0, newTransaction);
    });
    _applyFilters();
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Exportar Transações'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: CustomIconWidget(
                iconName: 'picture_as_pdf',
                size: 24,
                color: Colors.red,
              ),
              title: Text('Exportar como PDF'),
              onTap: () {
                Navigator.pop(context);
                _exportToPDF();
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'table_chart',
                size: 24,
                color: Colors.green,
              ),
              title: Text('Exportar como CSV'),
              onTap: () {
                Navigator.pop(context);
                _exportToCSV();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  void _exportToPDF() {
    // Simulate PDF export
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Exportando para PDF...'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _exportToCSV() {
    // Simulate CSV export
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Exportando para CSV...'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
