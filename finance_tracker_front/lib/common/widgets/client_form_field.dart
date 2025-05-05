// lib/common/widgets/client_form_field.dart
import 'package:flutter/material.dart';
import 'package:finance_tracker_front/common/constants/app_colors.dart';
import 'package:finance_tracker_front/common/constants/app_text_styles.dart';
import 'package:finance_tracker_front/models/client.dart';

class ClientFormField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final String? Function(String?)? validator;
  final List<Client> clients;
  final Function(Client?) onClientSelected;
  final EdgeInsetsGeometry? padding;
  final MouseCursor? cursor;

  const ClientFormField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.hintText,
    this.validator,
    required this.clients,
    required this.onClientSelected,
    this.padding,
    this.cursor,
  });

  @override
  State<ClientFormField> createState() => _ClientFormFieldState();
}

class _ClientFormFieldState extends State<ClientFormField> {
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
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Selecione um cliente',
                  style: AppTextStyles.mediumText16w500,
                  textAlign: TextAlign.center,
                ),
              ),
              const Divider(),
              TextButton(
                onPressed: () {
                  widget.controller.clear();
                  widget.onClientSelected(null);
                  Navigator.pop(context);
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  alignment: Alignment.centerLeft,
                ),
                child: Text(
                  'Nenhum',
                  style: AppTextStyles.mediumText16w500.copyWith(
                    color: AppColors.darkGrey,
                  ),
                ),
              ),
              ...widget.clients.map(
                (client) => TextButton(
                  onPressed: () {
                    widget.controller.text = client.name;
                    widget.onClientSelected(client);
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
                        client.name,
                        style: AppTextStyles.mediumText16w500.copyWith(
                          color: AppColors.darkGrey,
                        ),
                      ),
                      if (client.company != null)
                        Text(
                          client.company!,
                          style: AppTextStyles.smalltext.copyWith(
                            color: AppColors.darkGrey,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
        mouseCursor: widget.cursor ?? SystemMouseCursors.text,
      ),
    );
  }
}