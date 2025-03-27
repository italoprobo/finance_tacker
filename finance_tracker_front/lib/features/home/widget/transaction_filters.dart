import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finance_tracker_front/common/constants/app_colors.dart';
import 'package:finance_tracker_front/common/constants/app_text_styles.dart';
import 'package:finance_tracker_front/common/extensions/sizes.dart';
import 'package:finance_tracker_front/features/categories/application/categories_cubit.dart';
import 'package:finance_tracker_front/models/category.dart';
import 'package:intl/intl.dart';

class TransactionFilters extends StatefulWidget {
  final Function(String?) onCategoryChanged;
  final Function(DateTime?) onDateChanged;
  final String? selectedCategory;
  final DateTime? selectedDate;

  const TransactionFilters({
    super.key,
    required this.onCategoryChanged,
    required this.onDateChanged,
    this.selectedCategory,
    this.selectedDate,
  });

  @override
  State<TransactionFilters> createState() => _TransactionFiltersState();
}

class _TransactionFiltersState extends State<TransactionFilters> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          Expanded(
            child: BlocBuilder<CategoriesCubit, CategoriesState>(
              builder: (context, state) {
                if (state is CategoriesLoading) {
                  return Container(
                    height: 40.h,
                    decoration: BoxDecoration(
                      color: AppColors.antiFlashWhite,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  );
                }

                if (state is CategoriesSuccess) {
                  return DropdownButtonFormField<String>(
                    value: widget.selectedCategory,
                    decoration: InputDecoration(
                      hintText: 'Categoria',
                      hintStyle: AppTextStyles.smalltextw400.copyWith(
                        color: AppColors.inputcolor,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: AppColors.antiFlashWhite,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
                      ),
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('Todas'),
                      ),
                      ...state.categories.map((category) {
                        return DropdownMenuItem(
                          value: category.id,
                          child: Text(category.name),
                        );
                      }).toList(),
                    ],
                    onChanged: widget.onCategoryChanged,
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
          SizedBox(width: 8.w),
          GestureDetector(
            onTap: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: widget.selectedDate ?? DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                widget.onDateChanged(picked);
              }
            },
            child: Container(
              height: 40.h,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                color: AppColors.antiFlashWhite,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.selectedDate != null
                        ? DateFormat('dd/MM/yyyy').format(widget.selectedDate!)
                        : 'Data',
                    style: AppTextStyles.smalltextw400.copyWith(
                      color: widget.selectedDate != null
                          ? AppColors.black
                          : AppColors.inputcolor,
                    ),
                  ),
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: AppColors.inputcolor,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
} 