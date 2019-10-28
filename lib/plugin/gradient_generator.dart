import 'package:flutter/material.dart';

class GradientGenerator {
  ///gradient是颜色梯度
  static Gradient linear(Color color,
      {int gradient = 20,
      List<Color> colors,
      AlignmentGeometry begin = Alignment.topLeft,
      AlignmentGeometry end = Alignment.bottomRight}) {
    List<Color> tempColors = [];
    assert(gradient < 101);
    if (colors == null) {
      for (var i = 0; i <= 100; i = i + gradient) {
        tempColors.add(color.withOpacity(i / 100));
      }
    } else {
      tempColors = colors;
    }

    return LinearGradient(colors: tempColors, begin: begin, end: end);
  }
}
