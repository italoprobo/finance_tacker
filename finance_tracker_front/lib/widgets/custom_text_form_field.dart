import 'package:finance_tracker_front/common/constants/app_colors.dart';
import 'package:finance_tracker_front/common/constants/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextFormField extends StatefulWidget {
  final EdgeInsetsGeometry? padding;
  final String? hintText;
  final String? labelText;
  final TextCapitalization? textCapitalization;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final int? maxLength;
  final TextInputAction? textInputAction;
  final Widget? suffixIcon;
  final bool? obscureText;
  final List<TextInputFormatter>? inputFormatters;
  final FormFieldValidator<String>? validator;

  const CustomTextFormField({
    super.key,
    this.padding, this.hintText, this.labelText, this.textCapitalization, this.controller, this.keyboardType, this.maxLength, this.textInputAction, this.suffixIcon, this.obscureText, this.inputFormatters, this.validator,
  });

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {

  final defaultBorder = const OutlineInputBorder(
    borderSide: BorderSide(color: AppColors.purple),
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      child: TextFormField(
        validator: widget.validator,
        style: AppTextStyles.smalltext.copyWith(color: AppColors.purpleligth),
        inputFormatters: widget.inputFormatters,
        obscureText: widget.obscureText ?? false,
        textInputAction: widget.textInputAction,
        maxLength: widget.maxLength,
        keyboardType: widget.keyboardType,
        textCapitalization: widget.textCapitalization ?? TextCapitalization.none,
        controller: widget.controller,
        decoration: InputDecoration(
          suffixIcon: widget.suffixIcon,
          hintText: widget.hintText,
          hintStyle: AppTextStyles.smalltext.copyWith(color: AppColors.purpleligth),
          floatingLabelBehavior: FloatingLabelBehavior.always,
          labelText: widget.labelText?.toUpperCase(),
          labelStyle: AppTextStyles.inputLabelText.copyWith(color: AppColors.inputcolor),
          focusedBorder: defaultBorder,
          errorBorder: defaultBorder.copyWith(borderSide: const BorderSide(color: Colors.red)),
          focusedErrorBorder: defaultBorder.copyWith(borderSide: const BorderSide(color: Colors.red)),
          enabledBorder: defaultBorder,
          disabledBorder: defaultBorder,
        ),
      ),
    );
  }
}