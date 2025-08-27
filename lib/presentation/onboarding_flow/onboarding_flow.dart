import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/feature_demo_widget.dart';
import './widgets/onboarding_step_widget.dart';
import './widgets/permission_request_widget.dart';
import './widgets/progress_indicator_widget.dart';

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({Key? key}) : super(key: key);

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow>
    with TickerProviderStateMixin {
  late PageController _pageController;
  int _currentStep = 0;
  final int _totalSteps = 4;

  // Mock onboarding data
  final List<Map<String, dynamic>> _onboardingSteps = [
    {
      'title': 'Controle Total das Suas Finanças',
      'description':
          'Acompanhe todos os seus gastos e receitas em tempo real. Capture fotos de recibos e organize suas transações automaticamente.',
      'imageUrl':
          'https://images.unsplash.com/photo-1554224155-6726b3ff858f?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3',
      'demoType': 'expense_tracking',
    },
    {
      'title': 'Crie Orçamentos Inteligentes',
      'description':
          'Defina limites de gastos por categoria e receba alertas quando estiver próximo do limite. Mantenha suas finanças sempre sob controle.',
      'imageUrl':
          'https://images.unsplash.com/photo-1460925895917-afdab827c52f?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3',
      'demoType': 'budget_creation',
    },
    {
      'title': 'Alcance Seus Objetivos',
      'description':
          'Defina metas financeiras e acompanhe seu progresso. Seja para uma viagem, casa própria ou reserva de emergência.',
      'imageUrl':
          'https://images.unsplash.com/photo-1579621970563-ebec7560ff3e?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3',
      'demoType': 'goal_setting',
    },
    {
      'title': 'Visualize Seus Dados',
      'description':
          'Gráficos interativos e relatórios detalhados para entender melhor seus padrões de gastos e tomar decisões mais inteligentes.',
      'imageUrl':
          'https://images.unsplash.com/photo-1551288049-bebda4e38f71?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3',
      'demoType': 'chart_visualization',
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      HapticFeedback.lightImpact();
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      HapticFeedback.lightImpact();
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skipOnboarding() {
    HapticFeedback.lightImpact();
    Navigator.pushReplacementNamed(context, '/login-screen');
  }

  void _getStarted() {
    HapticFeedback.mediumImpact();
    Navigator.pushReplacementNamed(context, '/login-screen');
  }

  void _handleCameraPermission() {
    HapticFeedback.lightImpact();
    // In a real app, this would request camera permission
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Permissão de câmera concedida'),
        backgroundColor: AppTheme.getSuccessColor(true),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _handleNotificationPermission() {
    HapticFeedback.lightImpact();
    // In a real app, this would request notification permission
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Notificações ativadas'),
        backgroundColor: AppTheme.getSuccessColor(true),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _handleBiometricPermission() {
    HapticFeedback.lightImpact();
    // In a real app, this would set up biometric authentication
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Autenticação biométrica configurada'),
        backgroundColor: AppTheme.getSuccessColor(true),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            ProgressIndicatorWidget(
              currentStep: _currentStep,
              totalSteps: _totalSteps,
            ),

            // Main content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentStep = index;
                  });
                },
                itemCount: _totalSteps + 1, // +1 for permissions screen
                itemBuilder: (context, index) {
                  if (index < _totalSteps) {
                    final step = _onboardingSteps[index];
                    return Stack(
                      children: [
                        OnboardingStepWidget(
                          title: step['title'] as String,
                          description: step['description'] as String,
                          imageUrl: step['imageUrl'] as String,
                          isLastStep: index == _totalSteps - 1,
                          onNext: _nextStep,
                          onSkip: _skipOnboarding,
                          onGetStarted: _nextStep,
                        ),

                        // Feature demo overlay
                        if (step['demoType'] != null)
                          Positioned(
                            bottom: 20.h,
                            left: 6.w,
                            right: 6.w,
                            child: FeatureDemoWidget(
                              demoType: step['demoType'] as String,
                            ),
                          ),
                      ],
                    );
                  } else {
                    // Permissions screen
                    return PermissionRequestWidget(
                      onCameraPermission: _handleCameraPermission,
                      onNotificationPermission: _handleNotificationPermission,
                      onBiometricPermission: _handleBiometricPermission,
                      onContinue: _getStarted,
                    );
                  }
                },
              ),
            ),

            // Navigation hints
            if (_currentStep < _totalSteps)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Back button
                    _currentStep > 0
                        ? GestureDetector(
                            onTap: _previousStep,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 4.w,
                                vertical: 1.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.lightTheme.colorScheme.surface,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: AppTheme.lightTheme.colorScheme.outline
                                      .withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CustomIconWidget(
                                    iconName: 'arrow_back_ios',
                                    color: AppTheme
                                        .lightTheme.colorScheme.onSurface,
                                    size: 16,
                                  ),
                                  SizedBox(width: 1.w),
                                  Text(
                                    'Voltar',
                                    style: AppTheme
                                        .lightTheme.textTheme.labelMedium,
                                  ),
                                ],
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),

                    // Swipe hint
                    Text(
                      'Deslize para navegar',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant
                            .withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
