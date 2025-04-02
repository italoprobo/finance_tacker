import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finance_tracker_front/common/constants/app_colors.dart';
import 'package:finance_tracker_front/common/constants/app_text_styles.dart';
import 'package:finance_tracker_front/common/extensions/sizes.dart';
import 'package:finance_tracker_front/common/widgets/app_header.dart';
import 'package:finance_tracker_front/common/widgets/primary_button.dart';
import 'package:finance_tracker_front/common/widgets/custom_text_form_field.dart';
import 'package:finance_tracker_front/common/widgets/category_form_field.dart';
import 'package:finance_tracker_front/common/widgets/custom_snackbar.dart';
import 'package:finance_tracker_front/features/auth/application/auth_cubit.dart';
import 'package:finance_tracker_front/models/transaction_cubit.dart';
import 'package:finance_tracker_front/features/categories/application/categories_cubit.dart';
import 'package:go_router/go_router.dart';

class MoneyInputFormatter extends TextInputFormatter {
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

class AddTransactionPage extends StatefulWidget {
  const AddTransactionPage({super.key});

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> with SingleTickerProviderStateMixin, CustomSnackBar {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _dateController = TextEditingController();
  final _categoryController = TextEditingController();
  
  DateTime? _selectedDate;
  late TabController _tabController;
  String _selectedCategoryId = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedCategoryId = '';
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    _dateController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  void _showErrorSnackBar(String message) {
    showCustomSnackBar(
      context: context,
      text: message,
      type: SnackBarType.error,
    );
  }

  void _showSuccessSnackBar() {
    showCustomSnackBar(
      context: context,
      text: 'Transação adicionada com sucesso!',
      type: SnackBarType.success,
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
                title: 'Adicionar Transação',
                hideNavBar: true,
              ),
              Positioned(
                top: 164.h,
                left: 28.w,
                right: 28.w,
                bottom: 140.h,
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
                          TabBar(
                            controller: _tabController,
                            indicatorColor: Colors.transparent,
                            dividerColor: Colors.transparent,
                            labelPadding: const EdgeInsets.symmetric(horizontal: 8.0),
                            padding: EdgeInsets.zero,
                            onTap: (index) {
                              setState(() {});
                            },
                            tabs: [
                              Tab(
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: _tabController.index == 0
                                        ? AppColors.iceWhite
                                        : AppColors.white,
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(24.0),
                                    ),
                                  ),
                                  child: Text(
                                    'Entradas',
                                    style: AppTextStyles.mediumText16w500
                                        .apply(color: AppColors.darkGrey),
                                  ),
                                ),
                              ),
                              Tab(
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: _tabController.index == 1
                                        ? AppColors.iceWhite
                                        : AppColors.white,
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(24.0),
                                    ),
                                  ),
                                  child: Text(
                                    'Saídas',
                                    style: AppTextStyles.mediumText16w500
                                        .apply(color: AppColors.darkGrey),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16.0),
                          Column(
                            children: [
                              CustomTextFormField(
                                padding: EdgeInsets.zero,
                                controller: _amountController,
                                keyboardType: TextInputType.number,
                                labelText: 'VALOR',
                                hintText: 'Digite um valor',
                                suffixIcon: Icon(
                                  _tabController.index == 0 
                                    ? Icons.thumb_up 
                                    : Icons.thumb_down,
                                  color: AppColors.purple,
                                ),
                                inputFormatters: [
                                  MoneyInputFormatter(),
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
                                    initialDate: DateTime.now(),
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
                                  text: 'Adicionar',
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

                                          final amount = double.parse(
                                            _amountController.text
                                                .replaceAll('R\$', '')
                                                .replaceAll('.', '')
                                                .replaceAll(',', '.')
                                                .trim(),
                                          );

                                          final transactionData = {
                                            'description': _descriptionController.text,
                                            'amount': _tabController.index == 1 ? -amount : amount,
                                            'type': _tabController.index == 0 ? 'entrada' : 'saida',
                                            'date': _selectedDate?.toIso8601String() ?? 
                                                DateTime.now().toIso8601String(),
                                            'categoryId': _selectedCategoryId,
                                            'userId': authState.id,
                                          };

                                          await context.read<TransactionCubit>().addTransaction(
                                            authState.accessToken,
                                            transactionData,
                                          );
                                        } catch (e) {
                                          _showErrorSnackBar('Erro ao processar o valor');
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