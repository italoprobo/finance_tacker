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
import 'package:finance_tracker_front/features/clients/application/client_cubit.dart';
import 'package:go_router/go_router.dart';
import 'package:finance_tracker_front/features/auth/application/auth_cubit.dart';
import 'package:finance_tracker_front/common/widgets/custom_dropdown_form_field.dart';

class AddClientPage extends StatefulWidget {
  const AddClientPage({super.key});

  @override
  State<AddClientPage> createState() => _AddClientPageState();
}

class _AddClientPageState extends State<AddClientPage> with CustomSnackBar, SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _companyController = TextEditingController();
  final _monthlyPaymentController = TextEditingController();
  final _paymentDayController = TextEditingController();
  DateTime? _contractStart;
  DateTime? _contractEnd;
  String _status = 'ativo';
  bool _isLoading = false;

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
    _emailController.dispose();
    _phoneController.dispose();
    _companyController.dispose();
    _monthlyPaymentController.dispose();
    _paymentDayController.dispose();
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
      text: 'Cliente adicionado com sucesso!',
      type: SnackBarType.success,
    );
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _contractStart = picked;
        } else {
          _contractEnd = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          AppHeader(
            title: "Adicionar Cliente",
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
                          const SizedBox(height: 4.0),
                          CustomTextFormField(
                            padding: EdgeInsets.zero,
                            controller: _nameController,
                            labelText: 'NOME',
                            hintText: 'Nome do cliente',
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
                            controller: _emailController,
                            labelText: 'EMAIL',
                            hintText: 'exemplo@email.com',
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 12.0),
                          CustomTextFormField(
                            padding: EdgeInsets.zero,
                            controller: _phoneController,
                            labelText: 'TELEFONE',
                            hintText: '(99) 99999-9999',
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 12.0),
                          CustomTextFormField(
                            padding: EdgeInsets.zero,
                            controller: _companyController,
                            labelText: 'EMPRESA',
                            hintText: 'Empresa do cliente',
                          ),
                          const SizedBox(height: 12.0),
                          CustomTextFormField(
                            padding: EdgeInsets.zero,
                            controller: _monthlyPaymentController,
                            labelText: 'MENSALIDADE',
                            hintText: 'R\$ 0,00',
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
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
                            controller: _paymentDayController,
                            labelText: 'DIA DE PAGAMENTO',
                            hintText: 'Ex: 10',
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(2),
                            ],
                            validator: (value) {
                              if (value != null && value.isNotEmpty) {
                                final day = int.tryParse(value);
                                if (day == null || day < 1 || day > 31) {
                                  return 'Digite um dia válido (1-31)';
                                }
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12.0),
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => _selectDate(context, true),
                                  child: AbsorbPointer(
                                    child: CustomTextFormField(
                                      padding: EdgeInsets.zero,
                                      controller: TextEditingController(
                                        text: _contractStart != null
                                            ? "${_contractStart!.day.toString().padLeft(2, '0')}/${_contractStart!.month.toString().padLeft(2, '0')}/${_contractStart!.year}"
                                            : '',
                                      ),
                                      labelText: 'INÍCIO CONTRATO',
                                      hintText: 'dd/mm/aaaa',
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8.0),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => _selectDate(context, false),
                                  child: AbsorbPointer(
                                    child: CustomTextFormField(
                                      padding: EdgeInsets.zero,
                                      controller: TextEditingController(
                                        text: _contractEnd != null
                                            ? "${_contractEnd!.day.toString().padLeft(2, '0')}/${_contractEnd!.month.toString().padLeft(2, '0')}/${_contractEnd!.year}"
                                            : '',
                                      ),
                                      labelText: 'FIM CONTRATO',
                                      hintText: 'dd/mm/aaaa',
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12.0),
                          CustomDropdownFormField<String>(
                            labelText: 'STATUS',
                            hintText: 'Selecione o status',
                            value: _status,
                            items: const [
                              DropdownMenuItem(
                                value: 'ativo',
                                child: Text('Ativo'),
                              ),
                              DropdownMenuItem(
                                value: 'inativo',
                                child: Text('Inativo'),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _status = value ?? 'ativo';
                              });
                            },
                          ),
                          const SizedBox(height: 26.0),
                          BlocListener<ClientCubit, ClientState>(
                            listener: (context, state) {
                              if (state is ClientSuccess) {
                                _showSuccessSnackBar();
                                _showSuccessAnimation();
                                context.pop();
                              } else if (state is ClientFailure) {
                                _showErrorSnackBar(state.message);
                                _showErrorAnimation();
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
                                      final clientData = {
                                        'name': _nameController.text,
                                        'email': _emailController.text,
                                        'phone': _phoneController.text,
                                        'company': _companyController.text,
                                        'status': _status,
                                        'monthly_payment': double.tryParse(_monthlyPaymentController.text.replaceAll(',', '.')) ?? 0.0,
                                        'payment_day': int.tryParse(_paymentDayController.text),
                                        'contract_start': _contractStart?.toIso8601String(),
                                        'contract_end': _contractEnd?.toIso8601String(),
                                      };

                                      await context.read<ClientCubit>().createClient(
                                        authState.accessToken,
                                        clientData,
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
                'Cliente adicionado com sucesso!',
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
