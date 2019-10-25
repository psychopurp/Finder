library public;

import 'dart:convert';

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
String getTime({int year, int month, int day}) {
  double time = DateTime(year, month, day).millisecondsSinceEpoch.toDouble();
  time = time.toDouble() / 1000;
  var date = time.toInt().toString();
  return date;
}

///时间戳转换成日期
String timestampToDateTime(num time) {
  num temp = time * 1000;
  DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(temp.toInt());
  // print(dateTime);
  return dateTime.toString();
}

///content转换成html
String contentToJson({List<String> images, String text}) {
  var formData = {'images': images, 'text': text};
  return jsonEncode(formData);
}
