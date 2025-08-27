import 'package:flutter/material.dart';
import '../presentation/budget_management/budget_management.dart';
import '../presentation/login_screen/login_screen.dart';
import '../presentation/dashboard/dashboard.dart';
import '../presentation/transaction_history/transaction_history.dart';
import '../presentation/onboarding_flow/onboarding_flow.dart';
import '../presentation/add_transaction/add_transaction.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String budgetManagement = '/budget-management';
  static const String login = '/login-screen';
  static const String dashboard = '/dashboard';
  static const String transactionHistory = '/transaction-history';
  static const String onboardingFlow = '/onboarding-flow';
  static const String addTransaction = '/add-transaction';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const LoginScreen(),
    budgetManagement: (context) => const BudgetManagement(),
    login: (context) => const LoginScreen(),
    dashboard: (context) => const Dashboard(),
    transactionHistory: (context) => const TransactionHistory(),
    onboardingFlow: (context) => const OnboardingFlow(),
    addTransaction: (context) => const AddTransaction(),
    // TODO: Add your other routes here
  };
}
