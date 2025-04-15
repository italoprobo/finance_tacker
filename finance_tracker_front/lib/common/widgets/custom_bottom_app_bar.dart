import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../constants/app_colors.dart';

class CustomBottomAppBar extends StatelessWidget {
  final Color? selectedItemColor;
  final List<CustomBottomAppBarItem> children;
  final bool hasNotch;
  
  const CustomBottomAppBar({
    super.key,
    this.selectedItemColor,
    required this.children,
    this.hasNotch = false,
  }) : assert(children.length >= 4, 'children.length must be at least 4');

  @override
  Widget build(BuildContext context) {
    final currentRoute = GoRouterState.of(context).uri.path;
    final routeName = currentRoute.startsWith('/') ? currentRoute.substring(1) : currentRoute;
    
    return BottomAppBar(
      shape: hasNotch ? const CircularNotchedRectangle() : null,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: children.map(
          (item) {
            bool currentItem = false;
            
            if (item.label != null) {
              if (routeName == item.label!.toLowerCase()) {
                currentItem = true;
              }
            }

            return Builder(
              builder: (context) {
                return Expanded(
                  key: item.key,
                  child: InkWell(
                    onTap: item.onPressed,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Icon(
                        size: 30,
                        currentItem ? item.primaryIcon : item.secondaryIcon,
                        color: currentItem
                            ? AppColors.purple
                            : AppColors.selectedicon,
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ).toList(),
      ),
    );
  }
}

class CustomBottomAppBarItem {
  final Key? key;
  final String? label;
  final IconData? primaryIcon;
  final IconData? secondaryIcon;
  final VoidCallback? onPressed;

  CustomBottomAppBarItem({
    this.key,
    this.label,
    this.primaryIcon,
    this.secondaryIcon,
    this.onPressed,
  });

  CustomBottomAppBarItem.empty({
    this.key,
    this.label,
    this.primaryIcon,
    this.secondaryIcon,
    this.onPressed,
  });
}