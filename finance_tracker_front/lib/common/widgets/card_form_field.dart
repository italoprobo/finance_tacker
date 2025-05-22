import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finance_tracker_front/common/constants/app_colors.dart';
import 'package:finance_tracker_front/common/constants/app_text_styles.dart';
import 'package:finance_tracker_front/models/card_cubit.dart';
import 'package:finance_tracker_front/common/extensions/currency_extension.dart';
import 'package:finance_tracker_front/features/auth/application/auth_cubit.dart';

class CardFormField extends StatelessWidget {
  final String? selectedCardId;
  final List<CardModel> cards;
  final Function(String?) onCardSelected;
  final EdgeInsetsGeometry? padding;
  final String paymentMethod;

  const CardFormField({
    super.key,
    required this.selectedCardId,
    required this.cards,
    required this.onCardSelected,
    required this.paymentMethod,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final selectedCard = selectedCardId != null 
        ? cards.firstWhere((card) => card.id == selectedCardId)
        : null;

    const defaultBorder = OutlineInputBorder(
      borderSide: BorderSide(color: AppColors.purple),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        TextFormField(
          readOnly: true,
          style: AppTextStyles.smalltext.copyWith(color: AppColors.purpleligth),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
            hintText: 'Selecione um cartão',
            hintStyle: AppTextStyles.smalltext.copyWith(color: AppColors.purpleligth),
            floatingLabelBehavior: FloatingLabelBehavior.always,
            labelText: 'CARTÃO',
            labelStyle: AppTextStyles.inputLabelText.copyWith(color: AppColors.inputcolor),
            suffixIcon: const Icon(Icons.arrow_drop_down, color: AppColors.purple),
            focusedBorder: defaultBorder,
            errorBorder: defaultBorder.copyWith(borderSide: const BorderSide(color: AppColors.error)),
            focusedErrorBorder: defaultBorder.copyWith(borderSide: const BorderSide(color: AppColors.error)),
            enabledBorder: defaultBorder,
            disabledBorder: defaultBorder,
          ),
          onTap: () => showModalBottomSheet(
            context: context,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            builder: (context) => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Selecione um cartão',
                    style: AppTextStyles.mediumText16w500,
                    textAlign: TextAlign.center,
                  ),
                ),
                const Divider(),
                ...cards.map(
                  (card) => _buildCardOption(context, card),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
          mouseCursor: SystemMouseCursors.click,
        ),
        if (selectedCard != null) ...[
          const SizedBox(height: 8.0),
          _buildSelectedCardInfo(context, selectedCard),
        ],
      ],
    );
  }

  Widget _buildCardOption(BuildContext context, CardModel card) {
    return Builder(
      builder: (context) {
        final authState = context.watch<AuthCubit>().state;
        if (authState is! AuthSuccess) {
          return Text('${card.name} (*${card.lastDigits})');
        }

        if (paymentMethod == 'credito') {
          return FutureBuilder<Map<String, dynamic>>(
            future: context.read<CardCubit>().getCurrentInvoice(
              authState.accessToken,
              card.id,
            ),
            builder: (context, snapshot) {
              double faturaAtual = 0.0;
              if (snapshot.hasData) {
                faturaAtual = snapshot.data!['total'] as double;
              }
              final limiteDisponivel = card.limit + faturaAtual;

              return TextButton(
                onPressed: () {
                  onCardSelected(card.id);
                  Navigator.pop(context);
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  alignment: Alignment.centerLeft,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${card.name} (*${card.lastDigits})',
                      style: AppTextStyles.mediumText16w500.copyWith(
                        color: AppColors.darkGrey,
                      ),
                    ),
                    Text(
                      'Limite disponível: ${limiteDisponivel.toCurrency()}',
                      style: AppTextStyles.smalltext.copyWith(
                        color: AppColors.darkGrey,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        } else {
          return TextButton(
            onPressed: () {
              onCardSelected(card.id);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              alignment: Alignment.centerLeft,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${card.name} (*${card.lastDigits})',
                  style: AppTextStyles.mediumText16w500.copyWith(
                    color: AppColors.darkGrey,
                  ),
                ),
                Text(
                  'Saldo disponível: ${card.currentBalance.toCurrency()}',
                  style: AppTextStyles.smalltext.copyWith(
                    color: AppColors.darkGrey,
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  Widget _buildSelectedCardInfo(BuildContext context, CardModel selectedCard) {
    if (paymentMethod != 'credito') {
      return Text(
        'Saldo disponível: ${selectedCard.currentBalance.toCurrency()}',
        style: AppTextStyles.smalltextw400.copyWith(
          color: AppColors.inputcolor,
        ),
      );
    }

    final authState = context.watch<AuthCubit>().state;
    if (authState is! AuthSuccess) {
      return const SizedBox.shrink();
    }

    return FutureBuilder<Map<String, dynamic>>(
      future: context.read<CardCubit>().getCurrentInvoice(
        authState.accessToken,
        selectedCard.id,
      ),
      builder: (context, snapshot) {
        double faturaAtual = 0.0;
        if (snapshot.hasData) {
          faturaAtual = snapshot.data!['total'] as double;
        }
        final limiteDisponivel = selectedCard.limit + faturaAtual;

        return Text(
          'Limite disponível: ${limiteDisponivel.toCurrency()}',
          style: AppTextStyles.smalltextw400.copyWith(
            color: AppColors.inputcolor,
          ),
        );
      },
    );
  }
}