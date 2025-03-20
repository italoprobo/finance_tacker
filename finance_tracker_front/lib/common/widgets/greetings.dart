import 'package:flutter/material.dart';
import 'package:finance_tracker_front/common/constants/app_colors.dart';
import 'package:finance_tracker_front/common/constants/app_text_styles.dart';
import 'package:finance_tracker_front/features/auth/application/auth_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GreetingsWidget extends StatelessWidget {
  const GreetingsWidget({super.key});

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Bom dia,';
    } else if (hour < 18) {
      return 'Boa tarde,';
    } else {
      return 'Boa noite,';
    }
  }

  /// função para formatar o nome corretamente (primeiro e último nome)
  String formatName(String name) {
    List<String> words = name.toLowerCase().split(' ');
    
    if (words.length == 1) return words[0][0].toUpperCase() + words[0].substring(1); // se for um nome só

    String firstName = words.first;
    String lastName = words.last;

    firstName = firstName[0].toUpperCase() + firstName.substring(1);
    lastName = lastName[0].toUpperCase() + lastName.substring(1);

    return '$firstName $lastName';
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;

    String userName = '';
    if (authState is AuthSuccess) {
      userName = formatName(authState.name); 
    }

    double textScaleFactor = MediaQuery.of(context).size.width < 360 ? 0.7 : 1.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _greeting,
          textScaler: TextScaler.linear(textScaleFactor),
          style: AppTextStyles.smalltext.copyWith(color: AppColors.white),
        ),
        Text(
          userName.isNotEmpty ? userName : 'Usuário',
          textScaler: TextScaler.linear(textScaleFactor),
          style: AppTextStyles.mediumText20.copyWith(color: AppColors.white),
        ),
      ],
    );
  }
}
