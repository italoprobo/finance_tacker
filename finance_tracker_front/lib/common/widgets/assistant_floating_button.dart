import 'package:flutter/material.dart';
import 'package:finance_tracker_front/common/extensions/sizes.dart';
import 'package:finance_tracker_front/common/constants/app_colors.dart';
import 'package:finance_tracker_front/features/assistant/presentation/assistant_page.dart';

class AssistantFloatingButton extends StatefulWidget {
  const AssistantFloatingButton({Key? key}) : super(key: key);

  @override
  State<AssistantFloatingButton> createState() => _AssistantFloatingButtonState();
}

class _AssistantFloatingButtonState extends State<AssistantFloatingButton> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.7, 0), // Ajustado para mostrar apenas a seta
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    if (_isExpanded) {
      // Navega para a página do assistente
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AssistantPage()),
      );
      // Recolhe o botão após navegar
      setState(() {
        _isExpanded = false;
        _controller.reverse();
      });
    } else {
      setState(() {
        _isExpanded = true;
        _controller.forward();
      });
    }
  }

  Widget _buildSuggestionButton(String text) {
    return InkWell(
      onTap: () {
        // Aqui implementaremos a lógica de cada sugestão
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(8.w),
          border: Border.all(color: AppColors.purple.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 20.w,
              color: AppColors.purple,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 14.w,
                  color: AppColors.purple,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final showButton = ModalRoute.of(context)?.settings.name != '/home' && 
                      ModalRoute.of(context)?.settings.name != '/';

    if (!showButton) {
      return const SizedBox.shrink();
    }

    return Positioned(
      right: -10.w,
      bottom: 150.h,
      child: GestureDetector(
        onTap: _toggleExpand,
        child: SlideTransition(
          position: _slideAnimation,
          child: Container(
            height: 45.h,
            width: 150.w,
            decoration: BoxDecoration(
              color: AppColors.purple,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25.w),
                bottomLeft: Radius.circular(25.w),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withOpacity(0.2),
                  spreadRadius: 2.w,
                  blurRadius: 6.w,
                  offset: Offset(0, 2.h),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Ícone do assistente e texto
                Flexible(
                  child: Padding(
                    padding: EdgeInsets.only(left: 12.w),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.assistant,
                          size: 20.w,
                          color: AppColors.white,
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          'Assistente',
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 14.w,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Seta
                Container(
                  width: 35.w,
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(
                        color: AppColors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      _isExpanded 
                          ? Icons.chevron_right 
                          : Icons.chevron_left,
                      color: AppColors.white,
                      size: 20.w,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}