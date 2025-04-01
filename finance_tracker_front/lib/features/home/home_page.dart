import 'package:finance_tracker_front/common/constants/app_colors.dart';
import 'package:finance_tracker_front/common/widgets/custom_bottom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

enum BottomAppBarItem {
  home,
  stats,
  wallet,
  profile,
}

class HomePage extends StatelessWidget {
  final Widget? child;
  
  const HomePage({
    super.key,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      body: child,
      floatingActionButton: SizedBox(
        width: 70,
        height: 70,
        child: FloatingActionButton(
          heroTag: "add_transaction",
          onPressed: () {
            context.push('/add-transaction');
          },
          backgroundColor: AppColors.purple,
          shape: const CircleBorder(),
          child: const Icon(Icons.add, color: AppColors.white, size: 27,),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: CustomBottomAppBar(
        selectedItemColor: AppColors.purple,
        children: [
          CustomBottomAppBarItem(
            key: const ValueKey('home'),
            label: BottomAppBarItem.home.name,
            primaryIcon: Icons.home,
            secondaryIcon: Icons.home_outlined,
            onPressed: () {
              context.goNamed('home');
            },
          ),
          CustomBottomAppBarItem(
            key: const ValueKey('reports'),
            label: BottomAppBarItem.stats.name,
            primaryIcon: Icons.analytics,
            secondaryIcon: Icons.analytics_outlined,
            onPressed: () {
              context.goNamed('reports');
            },
          ),
          CustomBottomAppBarItem.empty(),
          CustomBottomAppBarItem(
            key: const ValueKey('wallet'),
            label: BottomAppBarItem.wallet.name,
            primaryIcon: Icons.account_balance_wallet,
            secondaryIcon: Icons.account_balance_wallet_outlined,
            onPressed: () {
              context.goNamed('wallet');
            },
          ),
          CustomBottomAppBarItem(
            key: const ValueKey('profile'),
            label: BottomAppBarItem.profile.name,
            primaryIcon: Icons.person,
            secondaryIcon: Icons.person_outline,
            onPressed: () {
              context.goNamed('profile');
            },
          ),
        ],
      ),
    );
  }
}
