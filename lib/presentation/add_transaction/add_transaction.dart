import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/account_selection_widget.dart';
import './widgets/amount_input_widget.dart';
import './widgets/category_selection_widget.dart';
import './widgets/date_picker_widget.dart';
import './widgets/description_input_widget.dart';
import './widgets/receipt_camera_widget.dart';
import './widgets/recurring_transaction_widget.dart';
import './widgets/tags_input_widget.dart';
import './widgets/transaction_type_toggle_widget.dart';

class AddTransaction extends StatefulWidget {
  const AddTransaction({Key? key}) : super(key: key);

  @override
  State<AddTransaction> createState() => _AddTransactionState();
}

class _AddTransactionState extends State<AddTransaction> {
  // Form data
  double _amount = 0.0;
  TransactionType _transactionType = TransactionType.expense;
  String? _selectedCategory;
  String _description = '';
  DateTime _selectedDate = DateTime.now();
  XFile? _receiptImage;
  String? _selectedAccount;
  List<String> _selectedTags = [];
  bool _isRecurring = false;
  RecurringFrequency _recurringFrequency = RecurringFrequency.none;

  // UI state
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Set default account
    _selectedAccount = 'Conta Corrente';
  }

  bool get _isFormValid {
    return _amount > 0 &&
        _selectedCategory != null &&
        _description.isNotEmpty &&
        _selectedAccount != null;
  }

  Future<void> _saveTransaction() async {
    if (!_isFormValid) {
      _showValidationError();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Show success message
      Fluttertoast.showToast(
        msg: 'Transação salva com sucesso!',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppTheme.getSuccessColor(true),
        textColor: Colors.white,
      );

      // Show option to add another transaction
      _showSuccessDialog();
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Erro ao salvar transação. Tente novamente.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppTheme.lightTheme.colorScheme.error,
        textColor: Colors.white,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showValidationError() {
    String message = 'Por favor, preencha todos os campos obrigatórios:';
    List<String> missingFields = [];

    if (_amount <= 0) missingFields.add('• Valor');
    if (_selectedCategory == null) missingFields.add('• Categoria');
    if (_description.isEmpty) missingFields.add('• Descrição');
    if (_selectedAccount == null) missingFields.add('• Conta');

    if (missingFields.isNotEmpty) {
      message += '\n${missingFields.join('\n')}';
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Campos Obrigatórios',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          message,
          style: AppTheme.lightTheme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                color: AppTheme.lightTheme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            CustomIconWidget(
              iconName: 'check_circle',
              color: AppTheme.getSuccessColor(true),
              size: 24,
            ),
            SizedBox(width: 2.w),
            Text(
              'Sucesso!',
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Text(
          'Transação adicionada com sucesso!',
          style: AppTheme.lightTheme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close add transaction screen
            },
            child: Text(
              'Voltar',
              style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              _resetForm(); // Reset form for new transaction
            },
            child: Text('Adicionar Outra'),
          ),
        ],
      ),
    );
  }

  void _resetForm() {
    setState(() {
      _amount = 0.0;
      _transactionType = TransactionType.expense;
      _selectedCategory = null;
      _description = '';
      _selectedDate = DateTime.now();
      _receiptImage = null;
      _selectedAccount = 'Conta Corrente';
      _selectedTags = [];
      _isRecurring = false;
      _recurringFrequency = RecurringFrequency.none;
    });
  }

  Future<bool> _onWillPop() async {
    if (_amount > 0 || _description.isNotEmpty || _selectedTags.isNotEmpty) {
      return await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(
                'Descartar alterações?',
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              content: Text(
                'Você tem alterações não salvas. Deseja realmente sair?',
                style: AppTheme.lightTheme.textTheme.bodyMedium,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(
                    'Cancelar',
                    style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(
                    'Descartar',
                    style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.error,
                    ),
                  ),
                ),
              ],
            ),
          ) ??
          false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text('Adicionar Transação'),
          leading: IconButton(
            onPressed: () async {
              if (await _onWillPop()) {
                Navigator.pop(context);
              }
            },
            icon: CustomIconWidget(
              iconName: 'close',
              color: AppTheme.lightTheme.colorScheme.onSurface,
              size: 24,
            ),
          ),
          actions: [
            if (_isFormValid)
              TextButton(
                onPressed: _isLoading ? null : _saveTransaction,
                child: _isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppTheme.lightTheme.colorScheme.primary,
                        ),
                      )
                    : Text(
                        'Salvar',
                        style:
                            AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
          ],
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Amount Input
              AmountInputWidget(
                onAmountChanged: (amount) {
                  setState(() {
                    _amount = amount;
                  });
                },
                initialAmount: _amount > 0 ? _amount : null,
              ),

              SizedBox(height: 3.h),

              // Transaction Type Toggle
              TransactionTypeToggleWidget(
                selectedType: _transactionType,
                onTypeChanged: (type) {
                  setState(() {
                    _transactionType = type;
                  });
                },
              ),

              SizedBox(height: 3.h),

              // Category Selection
              CategorySelectionWidget(
                selectedCategory: _selectedCategory,
                onCategorySelected: (category) {
                  setState(() {
                    _selectedCategory = category;
                  });
                },
              ),

              SizedBox(height: 3.h),

              // Description Input
              DescriptionInputWidget(
                onDescriptionChanged: (description) {
                  setState(() {
                    _description = description;
                  });
                },
                initialDescription:
                    _description.isNotEmpty ? _description : null,
              ),

              SizedBox(height: 3.h),

              // Date Picker
              DatePickerWidget(
                selectedDate: _selectedDate,
                onDateChanged: (date) {
                  setState(() {
                    _selectedDate = date;
                  });
                },
              ),

              SizedBox(height: 3.h),

              // Receipt Camera
              ReceiptCameraWidget(
                onImageCaptured: (image) {
                  setState(() {
                    _receiptImage = image;
                  });
                },
              ),

              SizedBox(height: 3.h),

              // Account Selection
              AccountSelectionWidget(
                selectedAccount: _selectedAccount,
                onAccountSelected: (account) {
                  setState(() {
                    _selectedAccount = account;
                  });
                },
              ),

              SizedBox(height: 3.h),

              // Tags Input
              TagsInputWidget(
                selectedTags: _selectedTags,
                onTagsChanged: (tags) {
                  setState(() {
                    _selectedTags = tags;
                  });
                },
              ),

              SizedBox(height: 3.h),

              // Recurring Transaction
              RecurringTransactionWidget(
                isRecurring: _isRecurring,
                frequency: _recurringFrequency,
                onRecurringChanged: (isRecurring) {
                  setState(() {
                    _isRecurring = isRecurring;
                    if (!isRecurring) {
                      _recurringFrequency = RecurringFrequency.none;
                    }
                  });
                },
                onFrequencyChanged: (frequency) {
                  setState(() {
                    _recurringFrequency = frequency;
                  });
                },
              ),

              SizedBox(height: 4.h),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      _isFormValid && !_isLoading ? _saveTransaction : null,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                    backgroundColor: _isFormValid
                        ? AppTheme.lightTheme.colorScheme.primary
                        : AppTheme.lightTheme.colorScheme.onSurfaceVariant
                            .withValues(alpha: 0.3),
                  ),
                  child: _isLoading
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 2.w),
                            Text(
                              'Salvando...',
                              style: AppTheme.lightTheme.textTheme.titleMedium
                                  ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        )
                      : Text(
                          'Salvar Transação',
                          style: AppTheme.lightTheme.textTheme.titleMedium
                              ?.copyWith(
                            color: _isFormValid
                                ? Colors.white
                                : AppTheme
                                    .lightTheme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),

              SizedBox(height: 2.h),
            ],
          ),
        ),
      ),
    );
  }
}
