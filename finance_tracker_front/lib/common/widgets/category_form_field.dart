import 'package:flutter/material.dart';
import 'package:finance_tracker_front/common/constants/app_colors.dart';
import 'package:finance_tracker_front/common/constants/app_text_styles.dart';

class CategoryFormField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final String? Function(String?)? validator;
  final List<String> categories;
  final Function(String) onCategorySelected;
  final EdgeInsetsGeometry? padding;

  const CategoryFormField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.hintText,
    required this.validator,
    required this.categories,
    required this.onCategorySelected,
    this.padding,
  });

  @override
  State<CategoryFormField> createState() => _CategoryFormFieldState();
}

class _CategoryFormFieldState extends State<CategoryFormField> {
  final defaultBorder = const OutlineInputBorder(
    borderSide: BorderSide(color: AppColors.purple),
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      child: TextFormField(
        controller: widget.controller,
        readOnly: true,
        style: AppTextStyles.smalltext.copyWith(color: AppColors.purpleligth),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: AppTextStyles.smalltext.copyWith(color: AppColors.purpleligth),
          floatingLabelBehavior: FloatingLabelBehavior.always,
          labelText: widget.labelText,
          labelStyle: AppTextStyles.inputLabelText.copyWith(color: AppColors.inputcolor),
          suffixIcon: const Icon(Icons.arrow_drop_down, color: AppColors.purple),
          focusedBorder: defaultBorder,
          errorBorder: defaultBorder.copyWith(borderSide: const BorderSide(color: AppColors.error)),
          focusedErrorBorder: defaultBorder.copyWith(borderSide: const BorderSide(color: AppColors.error)),
          enabledBorder: defaultBorder,
          disabledBorder: defaultBorder,
        ),
        validator: widget.validator,
        onTap: () => showModalBottomSheet(
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          builder: (context) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Selecione uma categoria',
                  style: AppTextStyles.mediumText16w500,
                  textAlign: TextAlign.center,
                ),
              ),
              const Divider(),
              ...widget.categories.map(
                (category) => TextButton(
                  onPressed: () {
                    widget.controller.text = category;
                    widget.onCategorySelected(category);
                    Navigator.pop(context);
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                    alignment: Alignment.centerLeft,
                  ),
                  child: Text(
                    category,
                    style: AppTextStyles.mediumText16w500.copyWith(
                      color: AppColors.darkGrey,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
} 