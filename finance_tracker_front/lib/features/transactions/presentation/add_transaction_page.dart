import 'package:finance_tracker_front/common/extensions/currency_extension.dart';
import 'package:finance_tracker_front/common/widgets/custom_checkbox_field.dart';
import 'package:finance_tracker_front/common/widgets/payment_form_field.dart';
import 'package:finance_tracker_front/features/clients/application/client_cubit.dart';
import 'package:finance_tracker_front/features/transactions/presentation/add_transaction_skeleton.dart';
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
import 'package:finance_tracker_front/common/widgets/client_form_field.dart';
import 'package:finance_tracker_front/models/card_cubit.dart';
import 'package:finance_tracker_front/common/widgets/card_form_field.dart';

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
  final _clientController = TextEditingController();
  
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  late TabController _tabController;
  String _selectedCategoryId = '';
  bool _isLoading = false;
  String? _selectedClientId;
  bool _isRecurring = false;

  // Novas variáveis para cartões
  String _paymentMethod = 'dinheiro'; // 'dinheiro', 'debito', 'credito'
  String? _selectedCardId;
  CardModel? _selectedCard;

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
    _clientController.dispose();
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

  Future<bool> _confirmHighValueTransaction(double amount) async {
    bool? result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmação de Transação'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Atenção! Transação de alto valor detectada.',
              style: AppTextStyles.mediumText16w600,
            ),
            const SizedBox(height: 8),
            Text(
              'Valor: R\$ ${amount.toStringAsFixed(2)}',
              style: AppTextStyles.mediumText16w500.copyWith(
                color: AppColors.expense,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Tem certeza que deseja prosseguir com esta transação?',
              style: AppTextStyles.smalltextw400,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.expense,
            ),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
    return result ?? false;
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
            top: 150.h,
            left: 28.w,
            right: 28.w,
            bottom: 0.5.h,
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
                  child: MultiBlocListener(
                    listeners: [
                      BlocListener<TransactionCubit, TransactionState>(
                        listener: (context, state) {
                          if (state is TransactionsSuccess) {
                            _showSuccessSnackBar();
                            context.pop();
                          } else if (state is TransactionsFailure) {
                            _showErrorSnackBar(state.message);
                          }
                        },
                      ),
                      BlocListener<CardCubit, CardState>(
                        listener: (context, state) {
                          if (state is CardLoading) {
                            // Handle loading state
                          } else if (state is CardSuccess) {
                            // Handle success state
                          } else if (state is CardFailure) {
                            _showErrorSnackBar(state.message);
                          }
                        },
                      ),
                      BlocListener<CategoriesCubit, CategoriesState>(
                        listener: (context, state) {
                          if (state is CategoriesLoading) {
                            // Handle loading state
                          } else if (state is CategoriesSuccess) {
                            // Handle success state
                          } else if (state is CategoriesFailure) {
                            _showErrorSnackBar(state.message);
                          }
                        },
                      ),
                    ],
                    child: BlocBuilder<CategoriesCubit, CategoriesState>(
                      builder: (context, state) {
                        if (state is CategoriesLoading) {
                          return const TransactionFormSkeleton();
                        }

                        if (state is CategoriesFailure) {
                          return Padding(
                            padding: EdgeInsets.zero,
                  child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  'Erro ao carregar categorias',
                                  style: AppTextStyles.smalltextw400.copyWith(
                                    color: AppColors.error,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextButton(
                                  onPressed: () {
                                    context.read<CategoriesCubit>().fetchCategories();
                                  },
                                  child: const Text('Tentar novamente'),
                                ),
                              ],
                            ),
                          );
                        }

                        return Column(
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
                                      cursor: SystemMouseCursors.click,
                                  categories: categories
                                      .map((category) => category.name)
                                      .toList(),
                                  onCategorySelected: (categoryName) {
                                          if (categoryName.isNotEmpty) {
                                    final selectedCategory = categories.firstWhere(
                                      (category) => category.name == categoryName,
                                    );
                                    setState(() {
                                      _selectedCategoryId = selectedCategory.id;
                                              _categoryController.text = categoryName;
                                    });
                                          }
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Selecione uma categoria';
                                    }
                                    return null;
                                  },
                                );
                              }
                              
                              return const SizedBox.shrink();
                            },
                          ),
                          const SizedBox(height: 12.0),
                          BlocBuilder<ClientCubit, ClientState>(
                            builder: (context, state) {
                              if (state is ClientLoading) {
                                return const CircularProgressIndicator();
                              }
                              
                              if (state is ClientSuccess) {
                                final clients = state.clients;
                                return ClientFormField(
                                  padding: EdgeInsets.zero,
                                  controller: _clientController,
                                  labelText: 'CLIENTE',
                                  hintText: 'Selecione um cliente (opcional)',
                                  cursor: SystemMouseCursors.click,
                                  clients: clients,
                                  onClientSelected: (client) {
                                    setState(() {
                                      _selectedClientId = client?.id;
                                      if (client != null) {
                                        _isRecurring = true;
                                      }
                                    });
                                  },
                                );
                              }
                              
                              if (state is ClientFailure) {
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
                                labelText: 'DATA E HORA',
                                hintText: 'Selecione uma data e hora',
                                cursor: SystemMouseCursors.click,
                            suffixIcon: const Icon(Icons.calendar_month_outlined, color: AppColors.purple),
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(1970),
                                lastDate: DateTime(2030),
                              );
                                  
                              if (date != null) {
                                    // Após selecionar a data, mostrar seletor de hora
                                    final time = await showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay.now(),
                                    );
                                    
                                    if (time != null) {
                                setState(() {
                                        _selectedTime = time;
                                        _selectedDate = DateTime(
                                          date.year,
                                          date.month,
                                          date.day,
                                          time.hour,
                                          time.minute,
                                        );
                                        // Atualizar o texto do campo com data e hora
                                  _dateController.text = 
                                          '${date.day}/${date.month}/${date.year} ${time.format(context)}';
                                });
                                    }
                              }
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Este campo não pode estar vazio';
                              }
                              return null;
                                  },
                                ),
                                const SizedBox(height: 12.0),
                                CustomCheckboxField(
                                  labelText: 'Transação Recorrente',
                                  value: _isRecurring,
                                  onChanged: (value) {
                                    setState(() {
                                      _isRecurring = value ?? false;
                                    });
                                  },
                                ),
                                PaymentMethodFormField(
                                  value: _paymentMethod,
                                  onMethodSelected: (method) {
                                    setState(() {
                                      _paymentMethod = method;
                                      if (method == 'dinheiro') {
                                        _selectedCard = null;
                                        _selectedCardId = null;
                                      }
                                    });
                                  },
                                  padding: EdgeInsets.zero,
                                ),
                                if (_paymentMethod != 'dinheiro')
                                  BlocBuilder<CardCubit, CardState>(
                                    builder: (context, state) {
                                      if (state is CardLoading) {
                                        return const CircularProgressIndicator();
                                      }

                                      if (state is CardSuccess) {
                                        final cards = state.cards.where((card) => 
                                          card.cardType.contains(_paymentMethod == 'credito' ? 'credito' : 'debito')
                                        ).toList();

                                        if (cards.isEmpty) {
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                                            child: Text(
                                              'Nenhum cartão ${_paymentMethod == 'credito' ? 'de crédito' : 'de débito'} cadastrado',
                                              style: AppTextStyles.smalltextw400.copyWith(
                                                color: AppColors.error,
                                              ),
                                            ),
                                          );
                                        }

                                        return CardFormField(
                                          selectedCardId: _selectedCardId,
                                          cards: cards,
                                          paymentMethod: _paymentMethod,
                                          onCardSelected: (cardId) {
                                            setState(() {
                                              _selectedCardId = cardId;
                                              _selectedCard = cardId != null 
                                                  ? cards.firstWhere((card) => card.id == cardId)
                                                  : null;
                                            });
                                          },
                                          padding: EdgeInsets.zero,
                                        );
                                      }

                                      return const SizedBox.shrink();
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
                                  // Validar categoria
                                  if (_selectedCategoryId.isEmpty) {
                                    _showErrorSnackBar('Por favor, selecione uma categoria');
                                    return;
                                  }

                                  // Validar cartão quando método de pagamento não é dinheiro
                                  if (_paymentMethod != 'dinheiro' && _selectedCardId == null) {
                                    _showErrorSnackBar('Por favor, selecione um cartão');
                                    return;
                                  }

                                  final amount = double.parse(
                                    _amountController.text
                                        .replaceAll('R\$', '')
                                        .replaceAll('.', '')
                                        .replaceAll(',', '.')
                                        .trim(),
                                  );

                                  // Validar limite do cartão de crédito
                                  if (_paymentMethod == 'credito' && _selectedCard != null) {
                                    final authState = context.read<AuthCubit>().state;
                                    if (authState is AuthSuccess) {
                                      // Busca a fatura atual do cartão
                                      final invoice = await context.read<CardCubit>().getCurrentInvoice(
                                        authState.accessToken,
                                        _selectedCard!.id,
                                      );
                                      
                                      final faturaAtual = invoice['total'] as double;
                                      final limiteDisponivel = _selectedCard!.limit + faturaAtual;

                                      // Verifica se há limite disponível
                                      if (amount > limiteDisponivel) {
                                        _showErrorSnackBar(
                                          'Limite insuficiente. Disponível: R\$ ${limiteDisponivel.toStringAsFixed(2)}'
                                        );
                                        return;
                                      }
                                    }
                                  }

                                  // Confirmar transação de alto valor
                                  if (amount >= 1000) {
                                    final confirmed = await _confirmHighValueTransaction(amount);
                                    if (!confirmed) {
                                      return;
                                    }
                                  }

                                  setState(() => _isLoading = true);
                                  
                                  final authState = context.read<AuthCubit>().state;
                                  if (authState is AuthSuccess) {
                                    try {
                                      final transactionData = {
                                        'description': _descriptionController.text,
                                        'amount': _tabController.index == 1 ? -amount : amount,
                                        'type': _tabController.index == 0 ? 'entrada' : 'saida',
                                        'date': _selectedDate?.toIso8601String() ?? DateTime.now().toIso8601String(),
                                        'categoryId': _selectedCategoryId,
                                        'userId': authState.id,
                                        'clientId': _selectedClientId,
                                        'isRecurring': _isRecurring,
                                        'cardId': _selectedCardId,
                                        'paymentMethod': _paymentMethod == 'dinheiro' ? null : _paymentMethod == 'credito' ? 'credit' : 'debit',
                                      };

                                      await context.read<TransactionCubit>().addTransaction(
                                        authState.accessToken,
                                        transactionData,
                                      );
                                    } catch (e) {
                                      if (e.toString().contains('transação similar detectada')) {
                                        // Mostrar confirmação de duplicata
                                        final confirmDuplicate = await showDialog<bool>(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text('Possível Transação Duplicada'),
                                            content: const Text(
                                              'Uma transação similar foi detectada nos últimos 5 minutos. '
                                              'Deseja prosseguir mesmo assim?'
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(context, false),
                                                child: const Text('Cancelar'),
                                              ),
                                              TextButton(
                                                onPressed: () => Navigator.pop(context, true),
                                                style: TextButton.styleFrom(
                                                  foregroundColor: AppColors.expense,
                                                ),
                                                child: const Text('Prosseguir'),
                                              ),
                                            ],
                                          ),
                                        );

                                        if (confirmDuplicate != true) {
                                          setState(() => _isLoading = false);
                                          return;
                                        }
                                      } else if (e.toString().contains('Limite diário')) {
                                        _showErrorSnackBar('Você atingiu o limite diário de transações');
                                        setState(() => _isLoading = false);
                                        return;
                                      } else {
                                        _showErrorSnackBar('Erro ao processar a transação');
                                      }
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
                        );
                      },
                    ),
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