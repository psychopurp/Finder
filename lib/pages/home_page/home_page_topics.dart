import 'package:flutter/material.dart';
import 'package:finder/model/topic_model.dart';
import 'package:finder/public.dart';

class HomePageTopics extends StatelessWidget {
  final TopicModel topics;
  HomePageTopics(this.topics);
  @override
  Widget build(BuildContext context) {
    return Container(
      height: ScreenUtil().setHeight(400),
      width: ScreenUtil().setWidth(750),
      color: Colors.cyan,
      child: Image.network(topics.data[0].image),
    );
  }
}
