import 'package:flutter/material.dart';
import 'package:finance_tracker_front/common/constants/app_colors.dart';
import 'package:finance_tracker_front/common/extensions/sizes.dart';

class TransactionFormSkeleton extends StatelessWidget {
  const TransactionFormSkeleton({super.key});

  Widget _buildShimmer({
    required double width,
    required double height,
    BorderRadius? borderRadius,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.antiFlashWhite,
        borderRadius: borderRadius ?? BorderRadius.circular(8),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tab Bar Skeleton
        Row(
          children: [
            Expanded(
              child: _buildShimmer(
                width: double.infinity,
                height: 40.h,
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: _buildShimmer(
                width: double.infinity,
                height: 40.h,
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),

        // Valor Skeleton
        _buildShimmer(
          width: double.infinity,
          height: 56.h,
        ),
        SizedBox(height: 12.h),

        // Descrição Skeleton
        _buildShimmer(
          width: double.infinity,
          height: 56.h,
        ),
        SizedBox(height: 12.h),

        // Categoria Skeleton
        _buildShimmer(
          width: double.infinity,
          height: 56.h,
        ),
        SizedBox(height: 12.h),

        // Cliente Skeleton
        _buildShimmer(
          width: double.infinity,
          height: 56.h,
        ),
        SizedBox(height: 12.h),

        // Data e Hora Skeleton
        _buildShimmer(
          width: double.infinity,
          height: 56.h,
        ),
        SizedBox(height: 12.h),

        // Checkbox Skeleton
        Row(
          children: [
            _buildShimmer(
              width: 24.w,
              height: 24.h,
              borderRadius: BorderRadius.circular(4),
            ),
            SizedBox(width: 8.w),
            _buildShimmer(
              width: 150.w,
              height: 24.h,
            ),
          ],
        ),
        SizedBox(height: 12.h),

        // Forma de Pagamento Skeleton
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildShimmer(
              width: 120.w,
              height: 16.h,
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                Expanded(
                  child: _buildShimmer(
                    width: double.infinity,
                    height: 64.h,
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: _buildShimmer(
                    width: double.infinity,
                    height: 64.h,
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: _buildShimmer(
                    width: double.infinity,
                    height: 64.h,
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 12.h),

        // Cartão Skeleton
        _buildShimmer(
          width: double.infinity,
          height: 56.h,
        ),
        SizedBox(height: 26.h),

        // Botão Skeleton
        _buildShimmer(
          width: double.infinity,
          height: 48.h,
          borderRadius: BorderRadius.circular(24),
        ),
      ],
    );
  }
}