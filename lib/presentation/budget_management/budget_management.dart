import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/budget_alerts_widget.dart';
import './widgets/budget_category_card.dart';
import './widgets/budget_chart_widget.dart';
import './widgets/budget_overview_card.dart';
import './widgets/create_budget_modal.dart';

class BudgetManagement extends StatefulWidget {
  const BudgetManagement({Key? key}) : super(key: key);

  @override
  State<BudgetManagement> createState() => _BudgetManagementState();
}

class _BudgetManagementState extends State<BudgetManagement>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  String _selectedPeriod = 'Mensal';
  final List<String> _periods = ['Mensal', 'Anual'];

  // Mock data for budgets
  List<Map<String, dynamic>> _budgets = [
    {
      'id': 1,
      'category': 'Alimentação',
      'icon': 'restaurant',
      'allocated': 800.0,
      'spent': 650.0,
      'notificationThreshold': 80,
      'createdAt': DateTime.now().subtract(const Duration(days: 15)),
    },
    {
      'id': 2,
      'category': 'Transporte',
      'icon': 'directions_car',
      'allocated': 400.0,
      'spent': 380.0,
      'notificationThreshold': 85,
      'createdAt': DateTime.now().subtract(const Duration(days: 10)),
    },
    {
      'id': 3,
      'category': 'Moradia',
      'icon': 'home',
      'allocated': 1200.0,
      'spent': 1200.0,
      'notificationThreshold': 90,
      'createdAt': DateTime.now().subtract(const Duration(days: 5)),
    },
    {
      'id': 4,
      'category': 'Entretenimento',
      'icon': 'movie',
      'allocated': 300.0,
      'spent': 150.0,
      'notificationThreshold': 75,
      'createdAt': DateTime.now().subtract(const Duration(days: 3)),
    },
  ];

  // Mock data for alerts
  List<Map<String, dynamic>> _alerts = [
    {
      'type': 'exceeded',
      'category': 'Moradia',
      'percentage': 100.0,
      'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
    },
    {
      'type': 'danger',
      'category': 'Transporte',
      'percentage': 95.0,
      'timestamp': DateTime.now().subtract(const Duration(hours: 6)),
    },
    {
      'type': 'warning',
      'category': 'Alimentação',
      'percentage': 81.25,
      'timestamp': DateTime.now().subtract(const Duration(days: 1)),
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: _isLoading ? _buildLoadingState() : _buildBody(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateBudgetModal,
        icon: CustomIconWidget(
          iconName: 'add',
          color: Colors.white,
          size: 5.w,
        ),
        label: Text(
          'Criar Orçamento',
          style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        'Gerenciar Orçamentos',
        style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
      actions: [
        PopupMenuButton<String>(
          onSelected: (value) {
            setState(() {
              _selectedPeriod = value;
            });
          },
          itemBuilder: (context) => _periods
              .map((period) => PopupMenuItem(
                    value: period,
                    child: Row(
                      children: [
                        CustomIconWidget(
                          iconName: period == 'Mensal'
                              ? 'calendar_month'
                              : 'calendar_today',
                          color: _selectedPeriod == period
                              ? AppTheme.lightTheme.colorScheme.primary
                              : AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                          size: 5.w,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          period,
                          style: TextStyle(
                            color: _selectedPeriod == period
                                ? AppTheme.lightTheme.colorScheme.primary
                                : null,
                            fontWeight: _selectedPeriod == period
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ))
              .toList(),
          child: Container(
            margin: EdgeInsets.only(right: 4.w),
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.primary
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _selectedPeriod,
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(width: 1.w),
                CustomIconWidget(
                  iconName: 'arrow_drop_down',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 4.w,
                ),
              ],
            ),
          ),
        ),
      ],
      bottom: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(text: 'Orçamentos'),
          Tab(text: 'Análises'),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildBudgetsTab(),
          _buildAnalyticsTab(),
        ],
      ),
    );
  }

  Widget _buildBudgetsTab() {
    if (_budgets.isEmpty) {
      return _buildEmptyState();
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        children: [
          SizedBox(height: 1.h),
          BudgetOverviewCard(
            totalBudget: _getTotalBudget(),
            totalSpent: _getTotalSpent(),
            onRefresh: _refreshData,
          ),
          BudgetAlertsWidget(
            alerts: _alerts,
            onViewAll: _showAllAlerts,
          ),
          SizedBox(height: 1.h),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _budgets.length,
            itemBuilder: (context, index) {
              final budget = _budgets[index];
              return BudgetCategoryCard(
                budgetData: budget,
                onTap: () => _navigateToDetails(budget),
                onEdit: () => _editBudget(budget),
                onDelete: () => _deleteBudget(budget),
                onNotificationSettings: () => _showNotificationSettings(budget),
              );
            },
          ),
          SizedBox(height: 10.h),
        ],
      ),
    );
  }

  Widget _buildAnalyticsTab() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        children: [
          SizedBox(height: 1.h),
          BudgetChartWidget(
            budgetData: _budgets,
            chartType: 'pie',
          ),
          BudgetChartWidget(
            budgetData: _budgets,
            chartType: 'bar',
          ),
          SizedBox(height: 10.h),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.all(8.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.primary
                      .withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: CustomIconWidget(
                  iconName: 'account_balance_wallet',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 15.w,
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                'Nenhum orçamento criado',
                style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 1.h),
              Text(
                'Comece criando seu primeiro orçamento para controlar melhor seus gastos',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 4.h),
              _buildSuggestedCategories(),
              SizedBox(height: 4.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _showCreateBudgetModal,
                  icon: CustomIconWidget(
                    iconName: 'add',
                    color: Colors.white,
                    size: 5.w,
                  ),
                  label: const Text('Criar Primeiro Orçamento'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestedCategories() {
    final suggestions = [
      {'name': 'Alimentação', 'icon': 'restaurant', 'amount': 'R\$ 800'},
      {'name': 'Transporte', 'icon': 'directions_car', 'amount': 'R\$ 400'},
      {'name': 'Moradia', 'icon': 'home', 'amount': 'R\$ 1.200'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sugestões populares:',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        ...suggestions.map((suggestion) => Container(
              margin: EdgeInsets.only(bottom: 1.h),
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.lightTheme.colorScheme.outline
                      .withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: suggestion['icon']!,
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 5.w,
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Text(
                      suggestion['name']!,
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Text(
                    suggestion['amount']!,
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppTheme.lightTheme.colorScheme.primary,
          ),
          SizedBox(height: 2.h),
          Text(
            'Atualizando orçamentos...',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  double _getTotalBudget() {
    return _budgets.fold(
        0.0, (sum, budget) => sum + (budget['allocated'] as num).toDouble());
  }

  double _getTotalSpent() {
    return _budgets.fold(
        0.0, (sum, budget) => sum + (budget['spent'] as num).toDouble());
  }

  Future<void> _refreshData() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    // Update spent amounts with mock data
    setState(() {
      for (var budget in _budgets) {
        final currentSpent = (budget['spent'] as num).toDouble();
        final allocated = (budget['allocated'] as num).toDouble();
        // Simulate some spending changes
        budget['spent'] =
            (currentSpent + (allocated * 0.05)).clamp(0.0, allocated * 1.2);
      }
      _isLoading = false;
    });
  }

  void _showCreateBudgetModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreateBudgetModal(
        onBudgetCreated: (budgetData) {
          setState(() {
            _budgets.add(budgetData);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Orçamento para ${budgetData['category']} criado com sucesso!'),
              backgroundColor: AppTheme.getSuccessColor(true),
            ),
          );
        },
      ),
    );
  }

  void _navigateToDetails(Map<String, dynamic> budget) {
    Navigator.pushNamed(context, '/transaction-history', arguments: {
      'category': budget['category'],
      'budgetId': budget['id'],
    });
  }

  void _editBudget(Map<String, dynamic> budget) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreateBudgetModal(
        onBudgetCreated: (updatedBudget) {
          setState(() {
            final index = _budgets.indexWhere((b) => b['id'] == budget['id']);
            if (index != -1) {
              _budgets[index] = {...budget, ...updatedBudget};
            }
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Orçamento atualizado com sucesso!'),
              backgroundColor: AppTheme.getSuccessColor(true),
            ),
          );
        },
      ),
    );
  }

  void _deleteBudget(Map<String, dynamic> budget) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Orçamento'),
        content: Text(
            'Tem certeza que deseja excluir o orçamento de ${budget['category']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _budgets.removeWhere((b) => b['id'] == budget['id']);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Orçamento excluído com sucesso!'),
                  backgroundColor: AppTheme.lightTheme.colorScheme.error,
                ),
              );
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

  void _showNotificationSettings(Map<String, dynamic> budget) {
    // Implementation for notification settings modal
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Configurações de notificação em desenvolvimento'),
      ),
    );
  }

  void _showAllAlerts() {
    // Implementation for showing all alerts
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Visualização completa de alertas em desenvolvimento'),
      ),
    );
  }
}
