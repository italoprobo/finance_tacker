import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finance_tracker_front/common/constants/app_colors.dart';
import 'package:finance_tracker_front/common/extensions/sizes.dart';
import 'package:finance_tracker_front/common/widgets/app_header.dart';
import 'package:finance_tracker_front/common/widgets/primary_button.dart';
import 'package:finance_tracker_front/common/widgets/custom_text_form_field.dart';
import 'package:finance_tracker_front/common/widgets/category_form_field.dart';
import 'package:finance_tracker_front/features/auth/application/auth_cubit.dart';
import 'package:finance_tracker_front/models/transaction_cubit.dart';
import 'package:finance_tracker_front/features/categories/application/categories_cubit.dart';
import 'package:go_router/go_router.dart';

class EditMoneyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Remove tudo que não é número
    String value = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    // Se não tiver números, retorna vazio
    if (value.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Converte o valor para centavos
    double amount = int.parse(value) / 100;
    
    // Formata o número com separador de milhares e decimais
    String formatted = 'R\$ ${amount.toStringAsFixed(2)}'
        .replaceAll('.', ',')
        .replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class EditTransactionPage extends StatefulWidget {
  final TransactionModel transaction;

  const EditTransactionPage({
    super.key,
    required this.transaction,
  });

  @override
  State<EditTransactionPage> createState() => _EditTransactionPageState();
}

class _EditTransactionPageState extends State<EditTransactionPage> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _dateController = TextEditingController();
  final _categoryController = TextEditingController();
  
  DateTime? _selectedDate;
  String? _selectedCategoryId;
  bool _isLoading = false;
  double? _originalAmount;

  @override
  void initState() {
    super.initState();
    final transaction = widget.transaction;
    _descriptionController.text = transaction.description;
    _amountController.text = 'R\$ ${transaction.amount.toStringAsFixed(2)}';
    _selectedDate = transaction.date;
    _dateController.text = '${transaction.date.day}/${transaction.date.month}/${transaction.date.year}';
    _selectedCategoryId = transaction.categoryId;
    _originalAmount = transaction.amount;

    // Configura a categoria inicial
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final categoriesState = context.read<CategoriesCubit>().state;
      if (categoriesState is CategoriesSuccess && _selectedCategoryId != null) {
        try {
          final selectedCategory = categoriesState.categories.firstWhere(
            (category) => category.id == _selectedCategoryId,
            orElse: () => categoriesState.categories.first,
          );
          _categoryController.text = selectedCategory.name;
        } catch (e) {
          print('Erro ao encontrar categoria inicial: $e');
        }
      }
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _dateController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.zero,
        dismissDirection: DismissDirection.horizontal,
      ),
    );
  }

  void _showSuccessSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Transação atualizada com sucesso!'),
        backgroundColor: AppColors.income,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.zero,
        dismissDirection: DismissDirection.horizontal,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Impedir que widgets de sobreposição afetem esta página
    return MediaQuery.removePadding(
      context: context,
      removeBottom: true, // Remove o espaço reservado para a barra de navegação
      child: WillPopScope(
        // Capturar o botão de voltar do sistema
        onWillPop: () async {
          return true;
        },
        child: Scaffold(
          // Definir o extendBody como false para evitar sobreposições
          extendBody: false,
          // Definir o próprio bottomNavigationBar como null para evitar que um widget pai aplique
          bottomNavigationBar: null,
          body: Stack(
            children: [
              const AppHeader(
                title: 'Editar Transação',
                hideNavBar: true,
              ),
              Positioned(
                top: 164.h,
                left: 28.w,
                right: 28.w,
                bottom: 300.h,
                child: Container(
                  width: 358.w,
                  height: 500.h,
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          Column(
                            children: [
                              CustomTextFormField(
                                padding: EdgeInsets.zero,
                                controller: _amountController,
                                keyboardType: TextInputType.number,
                                labelText: 'VALOR',
                                hintText: 'Digite um valor',
                                suffixIcon: Icon(
                                  widget.transaction.type == 'entrada'
                                    ? Icons.thumb_up 
                                    : Icons.thumb_down,
                                  color: AppColors.purple,
                                ),
                                inputFormatters: [
                                  EditMoneyInputFormatter(),
                                ],
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Este campo não pode estar vazio';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12.0),
                              CustomTextFormField(
                                padding: EdgeInsets.zero,
                                controller: _descriptionController,
                                labelText: 'DESCRIÇÃO',
                                hintText: 'Adicione uma descrição',
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Este campo não pode estar vazio';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12.0),
                              BlocBuilder<CategoriesCubit, CategoriesState>(
                                builder: (context, state) {
                                  if (state is CategoriesLoading) {
                                    return const CircularProgressIndicator();
                                  }
                                  
                                  if (state is CategoriesSuccess) {
                                    final categories = state.categories;
                                    
                                    // Se ainda não tiver categoria selecionada e tiver ID, tenta selecionar
                                    if (_categoryController.text.isEmpty && _selectedCategoryId != null) {
                                      try {
                                        final selectedCategory = categories.firstWhere(
                                          (category) => category.id == _selectedCategoryId,
                                          orElse: () => categories.first,
                                        );
                                        _categoryController.text = selectedCategory.name;
                                      } catch (e) {
                                        print('Erro ao encontrar categoria: $e');
                                      }
                                    }

                                    return CategoryFormField(
                                      padding: EdgeInsets.zero,
                                      controller: _categoryController,
                                      labelText: 'CATEGORIA',
                                      hintText: 'Selecione uma categoria',
                                      categories: categories
                                          .map((category) => category.name)
                                          .toList(),
                                      onCategorySelected: (categoryName) {
                                        final selectedCategory = categories.firstWhere(
                                          (category) => category.name == categoryName,
                                        );
                                        setState(() {
                                          _selectedCategoryId = selectedCategory.id;
                                        });
                                      },
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Selecione uma categoria';
                                        }
                                        return null;
                                      },
                                    );
                                  }
                                  
                                  if (state is CategoriesFailure) {
                                    return Text('Erro: ${state.message}');
                                  }
                                  
                                  return const SizedBox.shrink();
                                },
                              ),
                              const SizedBox(height: 12.0),
                              CustomTextFormField(
                                padding: EdgeInsets.zero,
                                controller: _dateController,
                                readOnly: true,
                                labelText: 'DATA',
                                hintText: 'Selecione uma data',
                                suffixIcon: const Icon(Icons.calendar_month_outlined, color: AppColors.purple),
                                onTap: () async {
                                  final date = await showDatePicker(
                                    context: context,
                                    initialDate: _selectedDate ?? DateTime.now(),
                                    firstDate: DateTime(1970),
                                    lastDate: DateTime(2030),
                                  );
                                  if (date != null) {
                                    setState(() {
                                      _selectedDate = date;
                                      _dateController.text = 
                                          '${date.day}/${date.month}/${date.year}';
                                    });
                                  }
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Este campo não pode estar vazio';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 26.0),
                              BlocListener<TransactionCubit, TransactionState>(
                                listener: (context, state) {
                                  if (state is TransactionsSuccess) {
                                    _showSuccessSnackBar();
                                    context.pop();
                                  } else if (state is TransactionsFailure) {
                                    _showErrorSnackBar(state.message);
                                  }
                                },
                                child: PrimaryButton(
                                  text: 'Salvar',
                                  isLoading: _isLoading,
                                  onPressed: () async {
                                    if (_formKey.currentState!.validate()) {
                                      setState(() => _isLoading = true);
                                      
                                      final authState = context.read<AuthCubit>().state;
                                      if (authState is AuthSuccess) {
                                        try {
                                          if (authState.id.isEmpty) {
                                            _showErrorSnackBar('Erro de autenticação. Por favor, faça login novamente.');
                                            setState(() => _isLoading = false);
                                            context.goNamed('login');
                                            return;
                                          }

                                          final amount = _amountController.text == 'R\$ ${_originalAmount?.toStringAsFixed(2)}'
                                              ? _originalAmount!
                                              : double.parse(
                                                  _amountController.text
                                                      .replaceAll('R\$', '')
                                                      .replaceAll('.', '')
                                                      .replaceAll(',', '.')
                                                      .trim(),
                                                );

                                          final transactionData = {
                                            'description': _descriptionController.text,
                                            'amount': amount,
                                            'type': widget.transaction.type,
                                            'date': _selectedDate?.toIso8601String() ?? 
                                                widget.transaction.date.toIso8601String(),
                                            'categoryId': _selectedCategoryId ?? widget.transaction.categoryId ?? '',
                                            'userId': authState.id,
                                          };

                                          await context.read<TransactionCubit>().updateTransaction(
                                            widget.transaction.id,
                                            authState.accessToken,
                                            transactionData,
                                          );
                                        } catch (e) {
                                          _showErrorSnackBar(e.toString().replaceAll('Exception: ', ''));
                                          setState(() => _isLoading = false);
                                        }
                                      } else {
                                        _showErrorSnackBar('Usuário não autenticado');
                                      }
                                      
                                      setState(() => _isLoading = false);
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 