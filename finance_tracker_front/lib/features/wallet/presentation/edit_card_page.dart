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
  late TextEditingController _closingDateController;
  late TextEditingController _dueDateController;
  
  bool _isCredit = false;
  bool _isDebit = false;
  bool _isLoading = false;
  DateTime? _selectedClosingDate;
  DateTime? _selectedDueDate;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.card.name);
    _lastDigitsController = TextEditingController(text: widget.card.lastDigits);
    _limitController = TextEditingController(text: widget.card.limit.toString());
    _closingDateController = TextEditingController(
      text: widget.card.closingDate != null 
        ? '${widget.card.closingDate!.day}/${widget.card.closingDate!.month}/${widget.card.closingDate!.year}'
        : '',
    );
    _dueDateController = TextEditingController(
      text: widget.card.dueDate != null 
        ? '${widget.card.dueDate!.day}/${widget.card.dueDate!.month}/${widget.card.dueDate!.year}'
        : '',
    );
    
    _isCredit = widget.card.cardType.contains('credito');
    _isDebit = widget.card.cardType.contains('debito');
    _selectedClosingDate = widget.card.closingDate;
    _selectedDueDate = widget.card.dueDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lastDigitsController.dispose();
    _limitController.dispose();
    _closingDateController.dispose();
    _dueDateController.dispose();
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
                          controller: _closingDateController,
                          labelText: 'DATA DE FECHAMENTO',
                          hintText: 'Selecione a data',
                          readOnly: true,
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: _selectedClosingDate ?? DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (date != null) {
                              setState(() {
                                _selectedClosingDate = date;
                                _closingDateController.text = 
                                    '${date.day}/${date.month}/${date.year}';
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 12.0),
                        CustomTextFormField(
                          padding: EdgeInsets.zero,
                          controller: _dueDateController,
                          labelText: 'DATA DE VENCIMENTO',
                          hintText: 'Selecione a data',
                          readOnly: true,
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: _selectedDueDate ?? DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (date != null) {
                              setState(() {
                                _selectedDueDate = date;
                                _dueDateController.text = 
                                    '${date.day}/${date.month}/${date.year}';
                              });
                            }
                          },
                        ),
                      ],
                      const SizedBox(height: 26.0),
                      BlocListener<CardCubit, CardState>(
                        listener: (context, state) {
                          if (state is CardSuccess) {
                            _showSuccessSnackBar();
                            context.pop();
                          } else if (state is CardFailure) {
                            _showErrorSnackBar(state.message);
                          }
                        },
                        child: PrimaryButton(
                          text: 'Salvar',
                          isLoading: _isLoading,
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              if (!_isCredit && !_isDebit) {
                                _showErrorSnackBar('Selecione pelo menos um tipo de cartão');
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
                                    'closingDate': _selectedClosingDate?.toIso8601String(),
                                    'dueDate': _selectedDueDate?.toIso8601String(),
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
        ],
      ),
    );
  }
}
