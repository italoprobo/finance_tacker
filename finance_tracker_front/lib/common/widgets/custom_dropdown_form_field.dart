import 'package:flutter/material.dart';
import 'package:finance_tracker_front/common/constants/app_colors.dart';
import 'package:finance_tracker_front/common/constants/app_text_styles.dart';
import 'package:finance_tracker_front/common/extensions/sizes.dart';

class CustomDropdownFormField<T> extends StatelessWidget {
  final String labelText;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?)? onChanged;
  final String? Function(T?)? validator;
  final EdgeInsetsGeometry? padding;
  final String? hintText;
  final bool? readOnly;
  final MouseCursor? cursor;

  const CustomDropdownFormField({
    super.key,
    required this.labelText,
    required this.value,
    required this.items,
    required this.onChanged,
    this.validator,
    this.padding,
    this.hintText,
    this.readOnly,
    this.cursor,
  });

  @override
  Widget build(BuildContext context) {
    const defaultBorder = OutlineInputBorder(
      borderSide: BorderSide(color: AppColors.purple),
    );

    return Padding(
      padding: padding ?? EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
      child: DropdownButtonFormField<T>(
        value: value,
        items: items,
        onChanged: readOnly == true ? null : onChanged,
        validator: validator,
        style: AppTextStyles.smalltext.copyWith(color: AppColors.purpleligth),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: AppTextStyles.smalltext.copyWith(color: AppColors.purpleligth),
          floatingLabelBehavior: FloatingLabelBehavior.always,
          labelText: labelText.toUpperCase(),
          labelStyle: AppTextStyles.inputLabelText.copyWith(color: AppColors.inputcolor),
          suffixIcon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.purple),
          focusedBorder: defaultBorder,
          errorBorder: defaultBorder.copyWith(borderSide: const BorderSide(color: AppColors.error)),
          focusedErrorBorder: defaultBorder.copyWith(borderSide: const BorderSide(color: AppColors.error)),
          enabledBorder: defaultBorder,
          disabledBorder: defaultBorder,
        ),
        dropdownColor: AppColors.white,
        icon: const SizedBox.shrink(),
        isExpanded: true,
        menuMaxHeight: 300.h,
      ),
    );
  }
}
