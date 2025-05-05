import 'package:flutter/material.dart';
import 'package:finance_tracker_front/common/constants/app_colors.dart';
import 'package:finance_tracker_front/common/constants/app_text_styles.dart';
import 'package:finance_tracker_front/common/extensions/sizes.dart';

class CustomCheckboxField extends StatelessWidget {
  final String labelText;
  final bool value;
  final ValueChanged<bool?> onChanged;
  final EdgeInsetsGeometry? padding;

  const CustomCheckboxField({
    super.key,
    required this.labelText,
    required this.value,
    required this.onChanged,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.symmetric(horizontal: 28.w, vertical: 12.h),
      child: Container(
        height: 56.h,
        width: 358.w,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.purple),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => onChanged(!value),
            borderRadius: BorderRadius.circular(8.0),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 28.w),
              child: Row(
                children: [
                  SizedBox(
                    width: 18.w,
                    height: 18.h,
                    child: Checkbox(
                      value: value,
                      onChanged: onChanged,
                      activeColor: AppColors.purple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      side: const BorderSide(
                        color: AppColors.purple,
                        width: 1.5,
                      ),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      labelText,
                      style: AppTextStyles.smalltext.copyWith(
                        color: AppColors.purpleligth,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
