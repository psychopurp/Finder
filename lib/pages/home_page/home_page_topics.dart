import 'package:finder/routers/application.dart';
import 'package:flutter/material.dart';
import 'package:finder/models/topic_model.dart';
import 'package:finder/public.dart';

class HomePageTopics extends StatelessWidget {
  final double mainHeight = 270;
  final double titleHeight = 40;
  final TopicModel topics;

  HomePageTopics(this.topics);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: mainHeight,
      // margin: EdgeInsets.only(bottom: ScreenUtil().setHeight(20)),
      decoration: BoxDecoration(
          // color: Colors.amber,
          // borderRadius: BorderRadius.only(
          //     topLeft: Radius.circular(20),
          //     topRight: Radius.circular(20),
          //     bottomLeft: Radius.circular(10),
          //     bottomRight: Radius.circular(10))
          ),
      // color: Colors.white,
      child: Column(
        children: <Widget>[
          _title(context),
          TopicList(isSchoolTopics: true, topicsData: sortSchoolTopic(true)),
          TopicList(
            isSchoolTopics: false,
            topicsData: sortSchoolTopic(false),
          )
        ],
      ),
    );
  }

  Widget _title(context) {
    return Container(
      height: titleHeight,
      // color: Colors.blue,
      child: Row(
        children: <Widget>[
          Container(
            width: ScreenUtil().setWidth(500),
            height: ScreenUtil().setHeight(80),
            // color: Colors.yellow,
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(
                // top: ScreenUtil().setHeight(20),
                left: ScreenUtil().setWidth(20)),
            child: Stack(
              alignment: AlignmentDirectional(-1, 0.6),
              children: <Widget>[
                Container(
                  width: ScreenUtil().setWidth(150),
                  height: ScreenUtil().setHeight(20),
                  decoration: BoxDecoration(
                    // color: Colors.amber,
                    gradient: LinearGradient(colors: [
                      Colors.white,
                      Theme.of(context).primaryColor.withOpacity(0.5),
                      Theme.of(context).primaryColor
                    ]),
                  ),
                ),
                Text('  与·话题',
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: ScreenUtil().setSp(35),
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          InkWell(
            onTap: () {
              Application.router.navigateTo(context, '/home/moreTopics');
            },
            child: Transform(
              alignment: AlignmentDirectional(
                  ScreenUtil().setWidth(14), ScreenUtil().setHeight(0)),
              transform: Matrix4.identity()..scale(0.9),
              child: Chip(
                // padding: EdgeInsets.all(0),
                backgroundColor: Colors.black.withOpacity(0.04),
                label: Row(
                  children: <Widget>[
                    Text(
                      '更多 ',
                      style: TextStyle(fontSize: ScreenUtil().setSp(25)),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: ScreenUtil().setSp(25),
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  List<TopicModelData> sortSchoolTopic(bool isSchoolTopics) {
    List<TopicModelData> topics = [];
    if (isSchoolTopics) {
      for (var i = 0; i < this.topics.data.length; i++) {
        if (this.topics.data[i].school != null) {
          topics.add(this.topics.data[i]);
        }
      }
      // this.topics.data.removeWhere((item) => item.school == null);
    } else {
      topics.addAll(this.topics.data);
    }
    return topics;
  }
}

class TopicList extends StatelessWidget {
  final double topicHeight = 100;
  final double topicWidth = 160;

  final bool isSchoolTopics;
  final List<TopicModelData> topicsData;
  TopicList({this.topicsData, this.isSchoolTopics});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: isSchoolTopics
          ? ScreenUtil().setHeight(220)
          : ScreenUtil().setHeight(240),
      width: ScreenUtil().setWidth(750),
      // color: Colors.green,
      child: ListView.builder(
        padding: EdgeInsets.only(
            top: isSchoolTopics
                ? ScreenUtil().setHeight(0)
                : ScreenUtil().setHeight(15)),
        scrollDirection: Axis.horizontal,
        itemCount: this.topicsData.length,
        itemBuilder: (context, index) {
          return _singleItem(
              context, this.topicsData[index], index, isSchoolTopics);
        },
      ),
    );
  }

  _singleItem(
      BuildContext context, TopicModelData item, int index, bool inSchool) {
    bool isLastItem = (index == this.topicsData.length - 1);

    return CachedNetworkImage(
      imageUrl: item.image,
      imageBuilder: (context, imageProvider) => InkWell(
        onTap: () {
          Application.router.navigateTo(context,
              '/home/topicDetail?id=${item.id.toString()}&title=${Uri.encodeComponent(item.title)}&image=${Uri.encodeComponent(item.image)}');
        },
        child: Align(
          alignment: Alignment.topCenter,
          child: Container(
            height: topicHeight,
            width: topicWidth,
            margin: isLastItem
                ? EdgeInsets.only(
                    left: ScreenUtil().setWidth(20),
                    right: ScreenUtil().setWidth(20),
                  )
                : EdgeInsets.only(left: ScreenUtil().setWidth(20)),
            decoration: BoxDecoration(
              // color: Colors.green,
              borderRadius: BorderRadius.all(Radius.circular(3)),
              // border: Border.all(color: Colors.black, width: 2),
              image: DecorationImage(
                image: imageProvider,
                fit: BoxFit.fill,
              ),
            ),
            child: Stack(
              children: <Widget>[
                Positioned(
                    top: ScreenUtil().setHeight(10),
                    child: Container(
                      padding: EdgeInsets.all(3),
                      decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.only(
                              // topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                              // bottomLeft: Radius.circular(10),
                              bottomRight: Radius.circular(20))),
                      child: Text(
                        inSchool ? '校内话题' : '校际话题',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: ScreenUtil().setSp(20)),
                      ),
                    )),
                Opacity(
                  opacity: 0.35,
                  child: Container(
                    // width: ScreenUtil().setWidth(750),
                    decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.all(Radius.circular(3))),
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  // color: Colors.blue,
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Montserrat',
                      fontSize: ScreenUtil().setSp(28),
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
      errorWidget: (context, url, error) => Icon(Icons.error),
    );
  }
}
