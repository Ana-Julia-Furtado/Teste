import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/account_card_widget.dart';
import './widgets/balance_card_widget.dart';
import './widgets/quick_actions_widget.dart';
import './widgets/recent_transactions_widget.dart';
import './widgets/spending_chart_widget.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> with TickerProviderStateMixin {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Mock data
  final List<Map<String, dynamic>> _accounts = [
    {
      "id": 1,
      "name": "Conta Corrente",
      "type": "Conta Corrente",
      "balance": 2850.75,
      "color": "#2E7D5A",
    },
    {
      "id": 2,
      "name": "Poupança",
      "type": "Poupança",
      "balance": 5420.30,
      "color": "#4A90E2",
    },
    {
      "id": 3,
      "name": "Cartão Nubank",
      "type": "Cartão de Crédito",
      "balance": -1250.00,
      "color": "#E67E22",
    },
    {
      "id": 4,
      "name": "Investimentos",
      "type": "Investimentos",
      "balance": 12750.80,
      "color": "#27AE60",
    },
  ];

  final List<Map<String, dynamic>> _spendingData = [
    {"category": "Alimentação", "amount": 850.50},
    {"category": "Transporte", "amount": 420.30},
    {"category": "Saúde", "amount": 320.75},
    {"category": "Entretenimento", "amount": 280.90},
    {"category": "Compras", "amount": 650.25},
  ];

  final List<Map<String, dynamic>> _recentTransactions = [
    {
      "id": 1,
      "title": "Supermercado Extra",
      "category": "Alimentação",
      "amount": 127.50,
      "type": "expense",
      "date": DateTime.now().subtract(const Duration(hours: 2)),
      "description": "Compras da semana",
    },
    {
      "id": 2,
      "title": "Salário",
      "category": "Salário",
      "amount": 4500.00,
      "type": "income",
      "date": DateTime.now().subtract(const Duration(days: 1)),
      "description": "Salário mensal",
    },
    {
      "id": 3,
      "title": "Uber",
      "category": "Transporte",
      "amount": 25.80,
      "type": "expense",
      "date": DateTime.now().subtract(const Duration(days: 1)),
      "description": "Corrida para o trabalho",
    },
    {
      "id": 4,
      "title": "Netflix",
      "category": "Entretenimento",
      "amount": 32.90,
      "type": "expense",
      "date": DateTime.now().subtract(const Duration(days: 2)),
      "description": "Assinatura mensal",
    },
    {
      "id": 5,
      "title": "Farmácia",
      "category": "Saúde",
      "amount": 45.60,
      "type": "expense",
      "date": DateTime.now().subtract(const Duration(days: 3)),
      "description": "Medicamentos",
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  double get _totalBalance {
    return (_accounts as List).fold(
        0.0,
        (sum, account) =>
            sum + ((account['balance'] as num?)?.toDouble() ?? 0.0));
  }

  String get _lastUpdated {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _handleRefresh() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToAddTransaction({String type = 'expense'}) {
    Navigator.pushNamed(context, '/add-transaction', arguments: {'type': type});
  }

  void _navigateToTransactionHistory() {
    Navigator.pushNamed(context, '/transaction-history');
  }

  void _navigateToTransactionDetail(Map<String, dynamic> transaction) {
    // Navigate to transaction detail or show bottom sheet
    _showTransactionDetail(transaction);
  }

  void _showTransactionDetail(Map<String, dynamic> transaction) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 50.h,
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(6.w)),
        ),
        padding: EdgeInsets.all(6.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 12.w,
                height: 0.5.h,
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.outline
                      .withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(1.w),
                ),
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              'Detalhes da Transação',
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 3.h),
            _buildDetailRow('Título', (transaction['title'] as String?) ?? ''),
            _buildDetailRow(
                'Categoria', (transaction['category'] as String?) ?? ''),
            _buildDetailRow('Valor',
                'R\$ ${((transaction['amount'] as num?)?.toDouble() ?? 0.0).toStringAsFixed(2).replaceAll('.', ',')}'),
            _buildDetailRow('Tipo', (transaction['type'] as String?) ?? ''),
            _buildDetailRow(
                'Data',
                _formatTransactionDate(
                    transaction['date'] as DateTime? ?? DateTime.now())),
            if ((transaction['description'] as String?)?.isNotEmpty == true)
              _buildDetailRow(
                  'Descrição', (transaction['description'] as String?) ?? ''),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Fechar'),
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // Navigate to edit transaction
                    },
                    child: const Text('Editar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 25.w,
            child: Text(
              label,
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                fontSize: 14.sp,
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTransactionDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} às ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _handleScanReceipt() {
    // Navigate to camera screen for receipt scanning
    _navigateToAddTransaction(type: 'receipt');
  }

  void _handleTransfer() {
    // Navigate to transfer screen
    Navigator.pushNamed(context, '/add-transaction',
        arguments: {'type': 'transfer'});
  }

  void _expandSpendingChart() {
    // Navigate to detailed spending analysis
    Navigator.pushNamed(context, '/budget-management');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'FinanceTracker',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 2.w),
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
            decoration: BoxDecoration(
              color: AppTheme.getSuccessColor(true).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(2.w),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomIconWidget(
                  iconName: 'security',
                  color: AppTheme.getSuccessColor(true),
                  size: 16,
                ),
                SizedBox(width: 1.w),
                Text(
                  'Seguro',
                  style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                    fontSize: 10.sp,
                    color: AppTheme.getSuccessColor(true),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: RefreshIndicator(
          key: _refreshIndicatorKey,
          onRefresh: _handleRefresh,
          color: AppTheme.lightTheme.colorScheme.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Balance Card
                BalanceCardWidget(
                  balance: _totalBalance,
                  lastUpdated: _lastUpdated,
                  onRefresh: _handleRefresh,
                ),

                // Account Cards
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Suas Contas',
                        style:
                            AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      SizedBox(
                        height: 20.h,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.only(left: 0.w),
                          itemCount: _accounts.length,
                          itemBuilder: (context, index) {
                            return AccountCardWidget(
                              account: _accounts[index],
                              onTap: () {
                                // Navigate to account details
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // Spending Chart
                SpendingChartWidget(
                  spendingData: _spendingData,
                  onTap: _expandSpendingChart,
                ),

                // Quick Actions
                QuickActionsWidget(
                  onAddExpense: () =>
                      _navigateToAddTransaction(type: 'expense'),
                  onAddIncome: () => _navigateToAddTransaction(type: 'income'),
                  onTransfer: _handleTransfer,
                  onScanReceipt: _handleScanReceipt,
                ),

                // Recent Transactions
                RecentTransactionsWidget(
                  transactions: _recentTransactions,
                  onViewAll: _navigateToTransactionHistory,
                  onTransactionTap: _navigateToTransactionDetail,
                ),

                // Bottom padding for FAB
                SizedBox(height: 10.h),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddTransaction(),
        child: CustomIconWidget(
          iconName: 'add',
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }
}
