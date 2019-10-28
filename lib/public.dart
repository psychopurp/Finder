library public;

import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';

//util
export 'package:flutter_screenutil/flutter_screenutil.dart';
export 'package:cached_network_image/cached_network_image.dart';
export 'package:image_picker/image_picker.dart';
export 'package:fluttertoast/fluttertoast.dart';
export 'package:finder/routers/routes.dart';
export 'package:finder/plugin/avatar.dart';
export 'package:bot_toast/bot_toast.dart';
export 'package:finder/plugin/dialog.dart';

//日期转化成时间戳工具
String getTime({int year, int month, int day, DateTime dateTime}) {
  if (dateTime != null) {
    return (dateTime.millisecondsSinceEpoch.toDouble() ~/ 1000)
        .toInt()
        .toString();
  }
  double time = DateTime(year, month, day).millisecondsSinceEpoch.toDouble();
  time = time.toDouble() / 1000;
  var date = time.toInt().toString();
  return date;
}

///时间戳转换成日期
DateTime timestampToDateTime(num time) {
  num temp = time * 1000;
  DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(temp.toInt());
  // print(dateTime);
  return dateTime;
}

///content转换成html
String contentToJson({List<String> images, String text}) {
  var formData = {'images': images, 'text': text};
  return jsonEncode(formData);
}

Future<List<Color>> imageToColors(String imageUrl) async {
  PaletteGenerator paletteGenerator = await PaletteGenerator.fromImageProvider(
    CachedNetworkImageProvider(imageUrl),
  );
  return paletteGenerator.colors.toList();
}
