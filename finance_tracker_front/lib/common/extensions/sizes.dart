import 'package:flutter/material.dart';

class Sizes {
  Sizes._();

  double _width = 0;
  double _height = 0;

  static const Size _designSize = Size(414.0, 896.0);
  static final Sizes _instance = Sizes._();

  factory Sizes() => _instance;

  double get width {
    assert(_width > 0, "Sizes.init() precisa ser chamado antes de acessar width");
    return _width;
  }

  double get height {
    assert(_height > 0, "Sizes.init() precisa ser chamado antes de acessar height");
    return _height;
  }

  static void init(BuildContext context, {Size designSize = _designSize}) {
    final deviceData = MediaQuery.maybeOf(context);
    final deviceSize = deviceData?.size ?? _designSize;

    _instance._width = deviceSize.width;
    _instance._height = deviceSize.height;
  }
}

extension SizeExt on num {
  double get w => (this * Sizes().width) / Sizes._designSize.width;
  double get h => (this * Sizes().height) / Sizes._designSize.height;
}
