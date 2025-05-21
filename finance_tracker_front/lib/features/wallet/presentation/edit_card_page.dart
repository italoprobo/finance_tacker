import 'package:finance_tracker_front/features/transactions/presentation/add_transaction_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finance_tracker_front/common/constants/app_colors.dart';
import 'package:finance_tracker_front/common/constants/app_text_styles.dart';
import 'package:finance_tracker_front/common/extensions/sizes.dart';
import 'package:finance_tracker_front/common/widgets/app_header.dart';
import 'package:finance_tracker_front/common/widgets/primary_button.dart';
import 'package:finance_tracker_front/common/widgets/custom_text_form_field.dart';
import 'package:finance_tracker_front/common/widgets/custom_snackbar.dart';
import 'package:finance_tracker_front/common/widgets/custom_checkbox_field.dart';
import 'package:finance_tracker_front/features/auth/application/auth_cubit.dart';
import 'package:finance_tracker_front/models/card_cubit.dart';
import 'package:go_router/go_router.dart';

class EditCardPage extends StatefulWidget {
  final CardModel card;

  const EditCardPage({
    super.key,
    required this.card,
  });

  @override
  State<EditCardPage> createState() => _EditCardPageState();
}

class _EditCardPageState extends State<EditCardPage> with CustomSnackBar {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _lastDigitsController;
  late TextEditingController _limitController;
  late TextEditingController _closingDayController;
  late TextEditingController _dueDayController;
  
  bool _isCredit = false;
  bool _isDebit = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.card.name);
    _lastDigitsController = TextEditingController(text: widget.card.lastDigits);
    _limitController = TextEditingController(text: widget.card.limit.toString());
    _closingDayController = TextEditingController(
      text: widget.card.closingDay?.toString() ?? '',
    );
    _dueDayController = TextEditingController(
      text: widget.card.dueDay?.toString() ?? '',
    );
    
    _isCredit = widget.card.cardType.contains('credito');
    _isDebit = widget.card.cardType.contains('debito');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lastDigitsController.dispose();
    _limitController.dispose();
    _closingDayController.dispose();
    _dueDayController.dispose();
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
      text: 'Cartão atualizado com sucesso!',
      type: SnackBarType.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          AppHeader(
            title: "Editar Cartão",
            hasOptions: false,
            onBackPressed: () => context.pop(),
          ),
          Positioned(
            top: 150.h,
            left: 0,
            right: 0,
            bottom: 0.5.h,
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Tooltip(
                          message: 'Digite o nome do banco ou bandeira do cartão',
                          child: CustomTextFormField(
                            padding: EdgeInsets.zero,
                            controller: _nameController,
                            labelText: 'NOME DO CARTÃO',
                            hintText: 'Ex: Nubank, Inter',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Este campo não pode estar vazio';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 12.0),
                        Tooltip(
                          message: 'Os últimos 4 dígitos do seu cartão',
                          child: CustomTextFormField(
                            padding: EdgeInsets.zero,
                            controller: _lastDigitsController,
                            labelText: 'ÚLTIMOS 4 DÍGITOS',
                            hintText: 'Ex: 1234',
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(4),
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Este campo não pode estar vazio';
                              }
                              if (value.length != 4) {
                                return 'Digite os 4 dígitos';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 12.0),
                        Text(
                          'TIPO DE CARTÃO',
                          style: AppTextStyles.smalltext13.copyWith(
                            color: AppColors.darkGrey,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Row(
                          children: [
                            Expanded(
                              child: Tooltip(
                                message: 'Selecione se o cartão é de crédito',
                                child: CustomCheckboxField(
                                  labelText: 'Crédito',
                                  value: _isCredit,
                                  onChanged: (value) {
                                    setState(() {
                                      _isCredit = value ?? false;
                                    });
                                  },
                                  padding: EdgeInsets.zero,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Tooltip(
                                message: 'Selecione se o cartão é de débito',
                                child: CustomCheckboxField(
                                  labelText: 'Débito',
                                  value: _isDebit,
                                  onChanged: (value) {
                                    setState(() {
                                      _isDebit = value ?? false;
                                    });
                                  },
                                  padding: EdgeInsets.zero,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (_isCredit) ...[
                          const SizedBox(height: 12.0),
                          Tooltip(
                            message: 'Limite total disponível no cartão',
                            child: CustomTextFormField(
                              padding: EdgeInsets.zero,
                              controller: _limitController,
                              labelText: 'LIMITE',
                              hintText: 'R\$ 0,00',
                              keyboardType: TextInputType.number,
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
                          ),
                          const SizedBox(height: 12.0),
                          CustomTextFormField(
                            padding: EdgeInsets.zero,
                            controller: _closingDayController,
                            labelText: 'DIA DE FECHAMENTO',
                            hintText: 'Ex: 26',
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(2),
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Este campo não pode estar vazio';
                              }
                              final day = int.tryParse(value);
                              if (day == null || day < 1 || day > 31) {
                                return 'Digite um dia válido (1-31)';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12.0),
                          CustomTextFormField(
                            padding: EdgeInsets.zero,
                            controller: _dueDayController,
                            labelText: 'DIA DE VENCIMENTO',
                            hintText: 'Ex: 2',
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(2),
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Este campo não pode estar vazio';
                              }
                              final day = int.tryParse(value);
                              if (day == null || day < 1 || day > 31) {
                                return 'Digite um dia válido (1-31)';
                              }
                              return null;
                            },
                          ),
                        ],
                        const SizedBox(height: 26.0),
                        BlocListener<CardCubit, CardState>(
                          listener: (context, state) {
                            setState(() => _isLoading = state is CardLoading);
                            
                            if (state is CardSuccess && state.message != null) {
                              showCustomSnackBar(
                                context: context,
                                text: state.message!,
                                type: SnackBarType.success,
                              );
                              
                              if (context.mounted) {
                                context.goNamed('wallet');
                              }
                            } else if (state is CardFailure) {
                              showCustomSnackBar(
                                context: context,
                                text: state.message,
                                type: SnackBarType.error,
                              );
                            }
                          },
                          child: PrimaryButton(
                            text: 'Salvar',
                            isLoading: _isLoading,
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                if (!_isCredit && !_isDebit) {
                                  showCustomSnackBar(
                                    context: context,
                                    text: 'Selecione pelo menos um tipo de cartão',
                                    type: SnackBarType.error,
                                  );
                                  return;
                                }

                                try {
                                  final limit = _isCredit ? double.tryParse(
                                    _limitController.text
                                        .replaceAll('R\$', '')
                                        .replaceAll('.', '')
                                        .replaceAll(',', '.')
                                        .trim()
                                  ) : 0.0;

                                  if (_isCredit && (limit == null || limit <= 0)) {
                                    showCustomSnackBar(
                                      context: context,
                                      text: 'Digite um limite válido',
                                      type: SnackBarType.error,
                                    );
                                    return;
                                  }

                                  setState(() => _isLoading = true);
                                  
                                  final authState = context.read<AuthCubit>().state;
                                  if (authState is AuthSuccess) {
                                    try {
                                      final cardTypes = <String>[];
                                      if (_isCredit) cardTypes.add('credito');
                                      if (_isDebit) cardTypes.add('debito');

                                      final cardData = {
                                        'name': _nameController.text,
                                        'lastDigits': _lastDigitsController.text,
                                        'cardType': cardTypes,
                                        'limit': _isCredit ? double.parse(
                                          _limitController.text
                                              .replaceAll('R\$', '')
                                              .replaceAll('.', '')
                                              .replaceAll(',', '.')
                                              .trim()
                                        ) : 0.0,
                                        'current_balance': widget.card.currentBalance,
                                        'closingDay': int.tryParse(_closingDayController.text),
                                        'dueDay': int.tryParse(_dueDayController.text),
                                        'userId': authState.id,
                                      };

                                      await context.read<CardCubit>().updateCard(
                                        authState.accessToken,
                                        widget.card.id,
                                        cardData,
                                      );
                                    } catch (e) {
                                      _showErrorSnackBar('Erro ao processar os dados');
                                    }
                                  } else {
                                    _showErrorSnackBar('Usuário não autenticado');
                                  }
                                  
                                  setState(() => _isLoading = false);
                                } catch (e) {
                                  _showErrorSnackBar('Erro ao processar os dados');
                                }
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
