import 'dart:developer';

import 'package:finance_tracker_front/common/constants/app_colors.dart';
import 'package:finance_tracker_front/common/constants/app_text_styles.dart';
import 'package:finance_tracker_front/common/extensions/sizes.dart';
import 'package:flutter/material.dart';

class HomeDashboard extends StatefulWidget {
  const HomeDashboard({super.key});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  double get textScaleFactor => MediaQuery.of(context).size.width < 360 ? 0.7 : 1.0;
  double get iconSize => MediaQuery.of(context).size.width < 360 ? 16.0 : 24.0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
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
              height: 300.h,
            ),
          ),
          Positioned(
            left: 24.0,
            right: 24.0,
            top: 60.h,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Boa noite,',
                      // ignore: deprecated_member_use
                      textScaleFactor: textScaleFactor,
                      style: AppTextStyles.smalltext.copyWith(
                        color: AppColors.white,),
                      ),
                      Text(
                        'Ítalo Probo',
                        // ignore: deprecated_member_use
                        textScaleFactor: textScaleFactor,
                        style: AppTextStyles.mediumText20.copyWith(
                          color: AppColors.white,
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    vertical: 8.h,
                    horizontal: 8.h,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: 
                      const BorderRadius.all(Radius.circular(4.0)),
                    // ignore: deprecated_member_use
                    color: AppColors.white.withOpacity(0.06)
                  ),
                  child: Stack(
                    alignment: const AlignmentDirectional(0.5, -0.5),
                    children: [
                      const Icon(
                        Icons.notifications_none_outlined,
                        color: AppColors.white,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.notification,
                          borderRadius: BorderRadius.circular(
                            4.0
                          )
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
          Positioned(
            left: 24.w,
            right: 24.w,
            top: 140.h,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 23.w,
                vertical: 32.h
              ),
              decoration: const BoxDecoration(
                color: AppColors.purple,
                borderRadius: BorderRadius.all(
                  Radius.circular(16.0)
                )
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Saldo Total',
                              textScaleFactor: textScaleFactor,
                              style: AppTextStyles.mediumText.apply(color: AppColors.white),
                            ),
                            Text(
                              'R\$ 1,500.00',
                              textScaleFactor: textScaleFactor,
                              style: AppTextStyles.mediumText30.apply(color: AppColors.white),
                            )
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => log('options'),
                        child: PopupMenuButton(
                          padding: EdgeInsets.zero,
                          child: const Icon(
                            Icons.more_horiz,
                            color: AppColors.white,
                          ),
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              height: 24.0,
                              child: Text("Item 1"),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 36.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4.0),
                            decoration: BoxDecoration(
                              color: AppColors.white.withOpacity(0.06),
                              borderRadius: const BorderRadius.all(
                                Radius.circular(16.0)
                              )
                            ),
                            child: Icon(
                              Icons.arrow_downward,
                              color: AppColors.white,
                              size: iconSize,
                            ),
                          ),
                          const SizedBox(width: 4.0),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Entradas",
                                textScaleFactor: textScaleFactor,
                                style: AppTextStyles.mediumText16w500.apply(color: AppColors.incomesndexpenses),
                              ),
                              Text(
                                "R\$ 1,840.00",
                                textScaleFactor: textScaleFactor,
                                style: AppTextStyles.mediumText20.apply(color: AppColors.white),
                              )
                            ],
                          )
                        ],
                      ),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4.0),
                            decoration: BoxDecoration(
                              color: AppColors.white.withOpacity(0.06),
                              borderRadius: const BorderRadius.all(
                                Radius.circular(16.0)
                              )
                            ),
                            child: Icon(
                              Icons.arrow_upward,
                              color: AppColors.white,
                              size: iconSize,
                            ),
                          ),
                          const SizedBox(width: 4.0),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Saidas",
                                textScaleFactor: textScaleFactor,
                                style: AppTextStyles.mediumText16w500.apply(color: AppColors.incomesndexpenses),
                              ),
                              Text(
                                "R\$ 240.00",
                                textScaleFactor: textScaleFactor,
                                style: AppTextStyles.mediumText20.apply(color: AppColors.white),
                              )
                            ],
                          )
                        ],
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
          Positioned(
            top: 420.h,
            left: 0,
            right: 0,
            bottom: 0,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Histórico de Transações",
                        style: AppTextStyles.buttontext.apply(color: AppColors.black),
                      ),
                      Text(
                        "Ver todas",
                        style: AppTextStyles.smalltextw400.apply(color: AppColors.inputcolor),
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.zero,
                    itemCount: 4,
                    itemBuilder: (context, index) {
                      final color = 
                        index % 2 == 0 ? AppColors.income : AppColors.expense;
                      final value =
                        index % 2 == 0 ? "+ \$ 100.00" : "- \$ 100.0";
                        return ListTile(
                          contentPadding: 
                              const EdgeInsets.symmetric(horizontal: 8.0),
                          leading: Container(
                            decoration: const BoxDecoration(
                              color: AppColors.antiFlashWhite,
                              borderRadius: 
                                  BorderRadius.all(Radius.circular(8.0)),
                            ),
                            padding: const EdgeInsets.all(8.0),
                            child: const Icon(
                              Icons.monetization_on_outlined
                            ),
                          ),
                          title: const Text(
                            "UpWork",
                            style: AppTextStyles.mediumText16w500,
                          ),
                          subtitle: const Text(
                            '2003-07-12',
                            style: AppTextStyles.smalltext13,
                          ),
                          trailing: Text(
                            value,
                            style: AppTextStyles.buttontext.apply(color: color),
                          ),
                        );
                    },
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}