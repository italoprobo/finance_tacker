import 'package:flutter/material.dart';
import 'package:finance_tracker_front/common/constants/app_colors.dart';
import 'package:finance_tracker_front/common/extensions/sizes.dart';
import 'package:finance_tracker_front/common/constants/app_text_styles.dart';

class ReportsPageSkeleton extends StatelessWidget {
  const ReportsPageSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    Sizes.init(context);
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 1),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Área do gráfico
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.antiFlashWhite.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: CustomPaint(
                painter: ChartSkeletonPainter(),
                size: Size.infinite,
              ),
            ),
          ),
          
          // Eixo X com legendas
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              return Container(
                width: 30.w,
                height: 12.h,
                decoration: BoxDecoration(
                  color: AppColors.antiFlashWhite,
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class ChartSkeletonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.purple.withOpacity(0.3)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    
    final dotPaint = Paint()
      ..color = AppColors.purple.withOpacity(0.5)
      ..style = PaintingStyle.fill;
    
    final path = Path();
    
    // Gerar pontos para o gráfico skeleton
    final points = List.generate(7, (index) {
      return Offset(
        index * size.width / 6,
        size.height / 2 + (index % 2 == 0 ? -20 : 20),
      );
    });
    
    // Desenhar a linha curva
    path.moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      final p0 = points[i - 1];
      final p1 = points[i];
      
      path.cubicTo(
        p0.dx + (p1.dx - p0.dx) / 2, p0.dy,
        p0.dx + (p1.dx - p0.dx) / 2, p1.dy,
        p1.dx, p1.dy,
      );
    }
    
    // Desenhar a área abaixo do gráfico
    final fillPath = Path.from(path);
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();
    
    canvas.drawPath(fillPath, Paint()
      ..color = AppColors.purple.withOpacity(0.1)
      ..style = PaintingStyle.fill);
    
    // Desenhar a linha
    canvas.drawPath(path, paint);
    
    // Desenhar os pontos
    for (var point in points) {
      canvas.drawCircle(point, 4, dotPaint);
      canvas.drawCircle(point, 6, Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2);
    }
    
    // Desenhar linha horizontal do zero
    final zeroPaint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      zeroPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
