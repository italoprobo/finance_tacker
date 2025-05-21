import 'package:flutter/material.dart';
import 'package:finance_tracker_front/common/constants/app_colors.dart';
import 'package:go_router/go_router.dart';

class QuickActionsFAB extends StatefulWidget {
  const QuickActionsFAB({Key? key}) : super(key: key);

  @override
  State<QuickActionsFAB> createState() => _QuickActionsFABState();
}

class _QuickActionsFABState extends State<QuickActionsFAB> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        // Overlay escuro quando o menu está aberto
        if (_isOpen)
          GestureDetector(
            onTap: _toggleMenu,
            child: Container(
              color: Colors.black54,
            ),
          ),
        
        // Ações rápidas
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Nova Transação
            ScaleTransition(
              scale: CurvedAnimation(
                parent: _controller,
                curve: const Interval(0.0, 1.0, curve: Curves.easeOut),
              ),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: FloatingActionButton.extended(
                  heroTag: 'add_transaction',
                  onPressed: () {
                    _toggleMenu();
                    context.pushNamed('add-transaction');
                  },
                  backgroundColor: AppColors.income,
                  label: const Text('Nova Transação'),
                  icon: const Icon(Icons.add),
                ),
              ),
            ),
            
            // Novo Cartão
            ScaleTransition(
              scale: CurvedAnimation(
                parent: _controller,
                curve: const Interval(0.1, 1.0, curve: Curves.easeOut),
              ),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: FloatingActionButton.extended(
                  heroTag: 'add_card',
                  onPressed: () {
                    _toggleMenu();
                    context.pushNamed('add-card');
                  },
                  backgroundColor: AppColors.purple,
                  label: const Text('Novo Cartão'),
                  icon: const Icon(Icons.credit_card),
                ),
              ),
            ),
            
            // Novo Cliente
            ScaleTransition(
              scale: CurvedAnimation(
                parent: _controller,
                curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
              ),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: FloatingActionButton.extended(
                  heroTag: 'add_client',
                  onPressed: () {
                    _toggleMenu();
                    context.pushNamed('add-client');
                  },
                  backgroundColor: AppColors.darkGrey,
                  label: const Text('Novo Cliente'),
                  icon: const Icon(Icons.person_add),
                ),
              ),
            ),
            
            // Botão principal
            FloatingActionButton(
              onPressed: _toggleMenu,
              backgroundColor: AppColors.purple,
              child: AnimatedIcon(
                icon: AnimatedIcons.menu_close,
                progress: _controller,
              ),
            ),
          ],
        ),
      ],
    );
  }
}