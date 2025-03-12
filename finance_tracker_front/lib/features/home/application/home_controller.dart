import 'package:flutter/material.dart';

class HomeController {
  static final HomeController instance = HomeController._internal();
  factory HomeController() => instance;

  HomeController._internal();

  final PageController pageController = PageController(initialPage: 0);
}
