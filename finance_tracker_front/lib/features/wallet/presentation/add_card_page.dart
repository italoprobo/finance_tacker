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
class AddCardPage extends StatefulWidget {
  const AddCardPage({super.key});

  @override
  State<AddCardPage> createState() => _AddCardPageState();
}

class _AddCardPageState extends State<AddCardPage> with CustomSnackBar, SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _lastDigitsController = TextEditingController();
  final _limitController = TextEditingController();
  final _closingDayController = TextEditingController();
  final _dueDayController = TextEditingController();
  
  bool _isCredit = true;
  bool _isDebit = false;
  bool _isLoading = false;
  int? _selectedClosingDay;
  int? _selectedDueDay;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
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
      text: 'Cartão adicionado com sucesso!',
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
            title: "Adicionar Cartão",
            hasOptions: false,
            onBackPressed: () => context.pop(),
          ),
          Positioned(
            top: 150.h,
            left: 28.w,
            right: 28.w,
            bottom: 0.5.h,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
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
                              if (state is CardSuccess) {
                                _showSuccessSnackBar();
                                _showSuccessAnimation();
                                context.pop();
                              } else if (state is CardFailure) {
                                _showErrorSnackBar(state.message);
                                _showErrorAnimation();
                              }
                            },
                            child: PrimaryButton(
                              text: 'Adicionar',
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
                                        'current_balance': 0.0,
                                        'closingDay': int.tryParse(_closingDayController.text),
                                        'dueDay': int.tryParse(_dueDayController.text),
                                        'userId': authState.id,
                                      };

                                      await context.read<CardCubit>().addCard(
                                        authState.accessToken,
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
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessAnimation() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle,
                color: AppColors.purple,
                size: 50,
              ),
              SizedBox(height: 16),
              Text(
                'Cartão adicionado com sucesso!',
                style: AppTextStyles.mediumText16w500,
              ),
            ],
          ),
        ),
      ),
    );
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pop();
    });
  }

  void _showErrorAnimation() {
    _animationController.forward(from: 0);
    HapticFeedback.vibrate();
  }
}
