import 'package:flutter/material.dart';
import 'package:finder/public.dart';
import 'package:finder/model/activity_model.dart';

class HomePageActivities extends StatelessWidget {
  final ActivityModel activities;
  HomePageActivities(this.activities);
  @override
  Widget build(BuildContext context) {
    return Container(
      height: ScreenUtil().setHeight(400),
      width: ScreenUtil().setWidth(750),
      color: Colors.yellow,
      child: Text(activities.data[0].startTime),
    );
  }
}
