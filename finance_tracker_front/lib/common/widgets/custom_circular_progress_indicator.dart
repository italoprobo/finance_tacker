import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class CustomCircularProgressIndicator extends StatelessWidget {
  final Color? color;
  final double? size;
  
  const CustomCircularProgressIndicator({
    super.key,
    this.color, this.size=32.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Center(
        child: CircularProgressIndicator(
          color: color ?? AppColors.icewhite,
        ),
      ),
    );
  }
}