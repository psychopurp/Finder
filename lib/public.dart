library public;

//util
export 'package:flutter_screenutil/flutter_screenutil.dart';
export 'package:cached_network_image/cached_network_image.dart';
export 'package:image_picker/image_picker.dart';

//日期转化成时间戳工具
String getTime({int year, int month, int day}) {
  double time = DateTime(year, month, day).millisecondsSinceEpoch.toDouble();
  time = time.toDouble() / 1000;
  var date = time.toInt().toString();
  return date;
}
