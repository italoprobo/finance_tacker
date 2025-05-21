import 'package:finance_tracker_front/common/widgets/custom_modal_bottom_sheet.dart';
import 'package:finance_tracker_front/common/widgets/custom_snackbar.dart';
import 'package:finance_tracker_front/features/auth/application/auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:finance_tracker_front/common/constants/app_colors.dart';
import 'package:finance_tracker_front/common/constants/app_text_styles.dart';
import 'package:finance_tracker_front/common/extensions/sizes.dart';
import 'package:finance_tracker_front/common/widgets/app_header.dart';
import 'package:finance_tracker_front/models/card_cubit.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finance_tracker_front/common/widgets/primary_button.dart';

class CardDetailsPage extends StatefulWidget {
  final CardModel card;

  const CardDetailsPage({
    super.key,
    required this.card,
  });

  @override
  State<CardDetailsPage> createState() => _CardDetailsPageState();
}

class _CardDetailsPageState extends State<CardDetailsPage> with CustomSnackBar {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          AppHeader(
            title: "Detalhes do Cartão",
            hasOptions: true,
            onBackPressed: () => context.pop(),
            onOptionsPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.edit, color: AppColors.purple),
                      title: const Text('Editar cartão'),
                      onTap: () {
                        context.pop();
                        context.pushNamed('edit-card', extra: widget.card);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.delete, color: AppColors.expense),
                      title: const Text('Excluir cartão'),
                      onTap: () {
                        context.pop();
                        _showDeleteConfirmation(context);
                      },
                    ),
                  ],
                ),
              );
            },
          ),
          Positioned(
            top: 164.h,
            left: 0,
            right: 0,
            bottom: 0.5.h,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildCardHeader(),
                    const SizedBox(height: 24),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildCardDetails(),
                          const SizedBox(height: 24),
                          _buildCardLimits(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 24),
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.purple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(40),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: Image.asset(
              _getCardIconPath(widget.card.name),
              width: 80,
              height: 80,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.credit_card,
                  color: AppColors.purple,
                  size: 40,
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          widget.card.name,
          style: AppTextStyles.mediumText16w600,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: AppColors.purple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            '•••• ${widget.card.lastDigits}',
            style: AppTextStyles.smalltextw600.copyWith(
              color: AppColors.purple,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCardDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Detalhes do Cartão',
          style: AppTextStyles.mediumText16w600,
        ),
        const SizedBox(height: 16),
        _buildDetailItem(
          'Tipo',
          widget.card.cardType.map((type) => type.toUpperCase()).join(', '),
        ),
        if (widget.card.closingDay != null)
          _buildDetailItem(
            'Dia de Fechamento',
            widget.card.closingDay.toString(),
          ),
        if (widget.card.dueDay != null)
          _buildDetailItem(
            'Dia de Vencimento',
            widget.card.dueDay.toString(),
          ),
      ],
    );
  }

  Widget _buildCardLimits() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Limites e Saldos',
          style: AppTextStyles.mediumText16w600,
        ),
        const SizedBox(height: 16),
        if (widget.card.cardType.contains('debito')) ...[
          _buildDetailItem(
            'Saldo em Conta',
            'R\$ ${widget.card.salary?.toStringAsFixed(2) ?? "0.00"}',
          ),
          BlocBuilder<AuthCubit, AuthState>(
            builder: (context, authState) {
              if (authState is! AuthSuccess) {
                return const Text('Não autorizado');
              }
              
              return BlocBuilder<CardCubit, CardState>(
                builder: (context, state) {
                  if (state is CardLoading) {
                    return const CircularProgressIndicator();
                  }
                  return FutureBuilder<double>(
                    future: context.read<CardCubit>().getCardBalance(
                      authState.accessToken,
                      widget.card.id,
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Text('Erro: ${snapshot.error}');
                      }
                      return _buildDetailItem(
                        'Saldo Disponível',
                        'R\$ ${snapshot.data?.toStringAsFixed(2) ?? "0.00"}',
                      );
                    },
                  );
                },
              );
            },
          ),
        ],
        if (widget.card.cardType.contains('credito')) ...[
          _buildDetailItem(
            'Limite Total',
            'R\$ ${widget.card.limit.toStringAsFixed(2)}',
          ),
          BlocBuilder<CardCubit, CardState>(
            builder: (context, state) {
              if (state is CardLoading) {
                return const CircularProgressIndicator();
              }
              return FutureBuilder<Map<String, dynamic>>(
                future: context.read<CardCubit>().getCurrentInvoice(
                  context.read<AuthCubit>().state is AuthSuccess 
                      ? (context.read<AuthCubit>().state as AuthSuccess).accessToken 
                      : '',
                  widget.card.id,
                ),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Erro: ${snapshot.error}');
                  }
                  
                  final faturaAtual = snapshot.data?['total'] ?? 0.0;
                  final limiteDisponivel = widget.card.limit + faturaAtual; // Como faturaAtual já é negativo, usamos +
                  
                  return Column(
                    children: [
                      _buildDetailItem(
                        'Fatura Atual',
                        'R\$ ${faturaAtual.abs().toStringAsFixed(2)}',
                      ),
                      _buildDetailItem(
                        'Limite Disponível',
                        'R\$ ${limiteDisponivel.toStringAsFixed(2)}',
                      ),
                    ],
                  );
                },
              );
            },
          ),
          const SizedBox(height: 24),
          _buildInvoiceSection(),
        ],
      ],
    );
  }

  Widget _buildInvoiceSection() {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        if (authState is! AuthSuccess) {
          return const Text('Não autorizado');
        }

        return BlocBuilder<CardCubit, CardState>(
          builder: (context, state) {
            return FutureBuilder<Map<String, dynamic>>(
              future: context.read<CardCubit>().getCurrentInvoice(
                authState.accessToken,
                widget.card.id,
              ),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Erro: ${snapshot.error}');
                }
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }

                final invoice = snapshot.data!;
                final transactions = invoice['transactions'] as List;
                
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Fatura Atual',
                      style: AppTextStyles.mediumText16w600,
                    ),
                    const SizedBox(height: 16),
                    _buildDetailItem(
                      'Fechamento',
                      _formatDate(invoice['closingDate']),
                    ),
                    _buildDetailItem(
                      'Vencimento',
                      _formatDate(invoice['dueDate']),
                    ),
                    const SizedBox(height: 16),
                    if (transactions.isEmpty)
                      const Text('Nenhuma transação encontrada')
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: transactions.length,
                        itemBuilder: (context, index) {
                          final transaction = transactions[index];
                          final amount = double.parse(transaction['amount'].toString());
                          
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.antiFlashWhite,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          transaction['description'],
                                          style: AppTextStyles.smalltextw600,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _formatDate(transaction['date']),
                                          style: AppTextStyles.smalltextw400.copyWith(
                                            color: AppColors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    'R\$ ${amount.abs().toStringAsFixed(2)}',
                                    style: AppTextStyles.smalltextw600.copyWith(
                                      color: AppColors.expense,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.smalltextw400.copyWith(
              color: const Color(0xFF666666),
            ),
          ),
          Text(
            value,
            style: AppTextStyles.smalltextw600,
          ),
        ],
      ),
    );
  }

  String _getCardIconPath(String cardName) {
    cardName = cardName.toLowerCase();
    if (cardName.contains('nubank')) return 'images/nubank_logo.png';
    if (cardName.contains('inter')) return 'assets/images/inter_logo.png';
    if (cardName.contains('itau')) return 'assets/images/itau_logo.png';
    if (cardName.contains('santander')) return 'assets/images/santander_logo.png';
    if (cardName.contains('bradesco')) return 'assets/images/bradesco_logo.png';
    if (cardName.contains('caixa')) return 'assets/images/caixa_logo.png';
    if (cardName.contains('bb')) return 'assets/images/bb_logo.png';
    return 'assets/images/credit_card.png';
  }

  void _showDeleteConfirmation(BuildContext context) {
    showCustomModalBottomSheet(
      context: context,
      title: 'Confirmar exclusão',
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Tem certeza que deseja excluir este cartão?",
            textAlign: TextAlign.center,
            style: AppTextStyles.smalltext.copyWith(color: AppColors.grey),
          ),
          const SizedBox(height: 20.0),
          SizedBox(
            width: double.infinity,
            child: PrimaryButton(
              text: "Excluir",
              backgroundColor: AppColors.expense,
              onPressed: () async {
                try {
                  final authState = context.read<AuthCubit>().state;
                  if (authState is AuthSuccess) {
                    // Primeiro fecha o modal
                    Navigator.pop(context);
                    
                    // Depois deleta o cartão
                    await context.read<CardCubit>().deleteCard(
                      authState.accessToken,
                      widget.card.id,
                    );
                    
                    if (context.mounted) {
                      // Mostra mensagem de sucesso
                      showCustomSnackBar(
                        context: context,
                        text: 'Cartão excluído com sucesso!',
                        type: SnackBarType.success,
                      );
                      
                      // Por fim, navega para a wallet
                      context.goNamed('wallet');
                    }
                  }
                } catch (e) {
                  if (context.mounted) {
                    // Mostra mensagem de erro
                    showCustomSnackBar(
                      context: context,
                      text: e.toString().contains('transações vinculadas')
                          ? 'Não é possível excluir este cartão pois existem transações vinculadas a ele'
                          : 'Erro ao excluir cartão',
                      type: SnackBarType.error,
                    );
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String date) {
    final DateTime dateTime = DateTime.parse(date);
    return "${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}";
  }
}
