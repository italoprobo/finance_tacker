import 'package:finance_tracker_front/common/constants/app_colors.dart';
import 'package:finance_tracker_front/common/extensions/page_controller_ext.dart';
import 'package:finance_tracker_front/common/widgets/custom_bottom_app_bar.dart';
import 'package:finance_tracker_front/features/home/application/home_controller.dart';
import 'package:finance_tracker_front/features/home/application/home_cubit.dart';
import 'package:finance_tracker_front/features/home/home_dashboard.dart';
import 'package:finance_tracker_front/features/profile/profile_page.dart';
import 'package:finance_tracker_front/features/reports/reports_page.dart';
import 'package:finance_tracker_front/features/wallet/wallet_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final homeCubit = context.watch<HomeCubit>();

    return Scaffold(
      body: PageView(
        controller: HomeController.instance.pageController,
        onPageChanged: homeCubit.changePage,
        children: const [
          HomeDashboard(),
          ReportsPage(),
          WalletPage(),
          ProfilePage(),
        ], 
      ),
      floatingActionButton: SizedBox(
        width: 70,
        height: 70,
        child: FloatingActionButton(onPressed: () {} ,
        backgroundColor: AppColors.purple,
        shape: const CircleBorder(),
        
        child: const Icon(Icons.add, color: AppColors.white, size: 27,),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: CustomBottomAppBar(
        controller: HomeController.instance.pageController,
        selectedItemColor: AppColors.purple,
        children: [
          CustomBottomAppBarItem(
            label: BottomAppBarItem.home.name,
            primaryIcon: Icons.home,
            secondaryIcon: Icons.home_outlined,
            onPressed: () => homeCubit.changePage(0),
          ),
          CustomBottomAppBarItem(
            label: BottomAppBarItem.stats.name,
            primaryIcon: Icons.analytics,
            secondaryIcon: Icons.analytics_outlined,
            onPressed: () => homeCubit.changePage(1),
          ),
          CustomBottomAppBarItem.empty(),
          CustomBottomAppBarItem(
            label: BottomAppBarItem.wallet.name,
            primaryIcon: Icons.account_balance_wallet,
            secondaryIcon: Icons.account_balance_wallet_outlined,
            onPressed: () => homeCubit.changePage(2),
          ),
          CustomBottomAppBarItem(
            label: BottomAppBarItem.profile.name,
            primaryIcon: Icons.person,
            secondaryIcon: Icons.person_outline,
            onPressed: () => homeCubit.changePage(3),
          ),
        ],
      ),
    );
  }
}
