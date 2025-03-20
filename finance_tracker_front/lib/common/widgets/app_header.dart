import 'package:finance_tracker_front/common/constants/app_colors.dart';
import 'package:finance_tracker_front/common/constants/app_text_styles.dart';
import 'package:finance_tracker_front/common/extensions/sizes.dart';
import 'package:finance_tracker_front/common/widgets/greetings.dart';
import 'package:finance_tracker_front/common/widgets/notification_widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppHeader extends StatefulWidget {
  final String? title;
  final bool hasOptions;

  const AppHeader({super.key, this.title, this.hasOptions = false});

  @override
  State<AppHeader> createState() => _AppHeaderState();
}

class _AppHeaderState extends State<AppHeader> {
  double get iconSize => MediaQuery.of(context).size.width < 360 ? 16.0 : 24.0;
  Widget get _innerHeader => widget.title != null ? 
        Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () => context.pop(),
              child: const Icon(
                Icons.arrow_back_ios,
                size: 16.0,
                color: AppColors.white,
              ),
            ),
            Text(
              widget.title!,
              style: AppTextStyles.mediumText18.apply(color: AppColors.white),
            ),
            widget.hasOptions ? const Icon(
              Icons.more_horiz,
              color: AppColors.white,
            ) : const SizedBox.shrink(),
          ],
        ) : 
        const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GreetingsWidget(),
              NotificationWidget()
                  ],
                );

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
              Positioned(
                left: 0,
                right: 0,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: AppColors.gradient,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.elliptical(500, 30),
                      bottomRight: Radius.elliptical(500, 30),
                    ),
                  ),
                  height: 287.h,
                ),
              ),
              Positioned(
                left: 24.0,
                right: 24.0,
                top: 62.h,
                child: _innerHeader,
              ),
      ],
    );
  }
}