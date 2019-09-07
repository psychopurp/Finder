import 'package:flutter/material.dart';
import 'package:finder/public.dart';

class Style {
  static final baseTextStyle = const TextStyle(fontFamily: 'Poppins');
  static final smallTextStyle = commonTextStyle.copyWith(
    fontSize: ScreenUtil().setSp(30),
  );
  static final commonTextStyle = baseTextStyle.copyWith(
      color: Colors.black,
      fontSize: ScreenUtil().setSp(15),
      fontWeight: FontWeight.w400);

  static final titleTextStyle = baseTextStyle.copyWith(
      color: Colors.white,
      fontSize: ScreenUtil().setSp(15),
      fontWeight: FontWeight.w600);

  static final headerTextStyle = baseTextStyle.copyWith(
      color: Colors.white,
      fontSize: ScreenUtil().setSp(15),
      fontWeight: FontWeight.w400);
}
