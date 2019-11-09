import 'package:finder/config/global.dart';
import 'package:finder/plugin/callback.dart';
import 'package:finder/routers/application.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:finder/models/topic_model.dart';
import 'package:finder/public.dart';

class HomePageTopics extends StatelessWidget {
  final TopicModel topics;
  static double mainHeight = ScreenUtil().setHeight(480);
  static double titleHeight = ScreenUtil().setHeight(100);
  final PushCallback push;

  HomePageTopics(this.topics, this.push);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: mainHeight,
      // margin: EdgeInsets.only(bottom: ScreenUtil().setHeight(20)),
      color: Colors.white,
      child: Column(
        children: <Widget>[
          _title(context),
          TopicList(
            isSchoolTopics: true,
            topicsData: sortSchoolTopic(true),
            push: push,
          ),
          TopicList(
            isSchoolTopics: false,
            topicsData: sortSchoolTopic(false),
            push: push,
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
            height: titleHeight,
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
                  height: titleHeight / 5,
                ),
                Text('  与·话题',
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: ScreenUtil().setSp(35),
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(),
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              Application.router.navigateTo(context, '/home/moreTopics');
            },
            child: Chip(
              // padding: EdgeInsets.all(0),
              backgroundColor: Colors.white,
              label: Row(
                children: <Widget>[
                  Text(
                    '更多 ',
                    style: TextStyle(fontSize: ScreenUtil().setSp(26)),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: ScreenUtil().setSp(32),
                  )
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(3),
          )
        ],
      ),
    );
  }

  List<TopicModelData> sortSchoolTopic(bool isSchoolTopics) {
    List<TopicModelData> newTopics = [];
    if (isSchoolTopics) {
      this.topics.data.forEach((e) {
        if (e.school != null) {
          newTopics.add(e);
        }
      });
    } else {
      this.topics.data.forEach((e) {
        if (e.school == null) {
          newTopics.add(e);
        }
      });
    }

    return newTopics;
  }
}

class TopicList extends StatelessWidget {
  TopicList({this.topicsData, this.isSchoolTopics, this.push});

  final double topicListHeight =
      (HomePageTopics.mainHeight - HomePageTopics.titleHeight) / 2;

  final bool isSchoolTopics;
  final List<TopicModelData> topicsData;
  final PushCallback push;

  @override
  Widget build(BuildContext context) {
    int maxSize;
    if (Global.totalMemory == null) {
      maxSize = 7;
    } else if (Global.totalMemory < 3 * 1024) {
      maxSize = 5;
    } else if (Global.totalMemory < 4 * 1024) {
      maxSize = 7;
    } else if (Global.totalMemory < 6 * 1024) {
      maxSize = 8;
    } else {
      maxSize = 10;
    }
    return Container(
      height: topicListHeight,
      width: ScreenUtil().setWidth(750),
      // color: isSchoolTopics ? Colors.green : Colors.yellow,
      padding: EdgeInsets.only(left: ScreenUtil().setWidth(20)),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount:
            this.topicsData.length < maxSize ? topicsData.length : maxSize,
        itemBuilder: (context, index) {
          return _singleItem(
              context, this.topicsData[index], index, isSchoolTopics);
        },
      ),
    );
  }

  _singleItem(
      BuildContext context, TopicModelData item, int index, bool inSchool) {
    ///宽高比 1.6/1
    return CachedNetworkImage(
      key: ValueKey(item.image + item.title),
      imageUrl: item.image,
      imageBuilder: (context, imageProvider) => ImageItem(
          onTap: () {
            push(() async {
              await Application.router.navigateTo(context,
                  '/home/topicDetail?id=${item.id.toString()}&title=${Uri.encodeComponent(item.title)}&image=${Uri.encodeComponent(item.image)}');
            });
          },
          imageProvider: imageProvider,
          inSchool: inSchool,
          item: item,
          key: ValueKey(item.image)),
      errorWidget: (context, url, error) => Icon(Icons.error),
    );
  }
}

class ImageItem extends StatelessWidget {
  ImageItem({this.item, this.imageProvider, this.onTap, this.inSchool, Key key})
      : super(key: key);
  final TopicModelData item;
  final ImageProvider imageProvider;
  final VoidCallback onTap;
  final bool inSchool;
  static final double topicHeight =
      (HomePageTopics.mainHeight - HomePageTopics.titleHeight) / 2 - 10;
  static final double topicWidth = topicHeight * 1.6;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          height: topicHeight,
          width: topicWidth,
          margin: EdgeInsets.only(right: ScreenUtil().setWidth(20)),
          decoration: BoxDecoration(
            // color: Colors.green,
            borderRadius: BorderRadius.all(Radius.circular(10)),
            // border: Border.all(color: Colors.black, width: 2),
            image: DecorationImage(
              image: imageProvider,
              fit: BoxFit.cover,
            ),
          ),
          child: Stack(
            children: <Widget>[
              Opacity(
                opacity: 0.35,
                child: Container(
                  // width: ScreenUtil().setWidth(750),
                  decoration: BoxDecoration(
                      color: Color(0xff444444),
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                ),
              ),
              Positioned(
                  top: ScreenUtil().setHeight(13),
                  child: Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 7),
                    decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.8),
                        borderRadius: BorderRadius.only(
                            // topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                            // bottomLeft: Radius.circular(10),
                            bottomRight: Radius.circular(20))),
                    child: Text(
                      inSchool ? '校内' : '校际',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: ScreenUtil().setSp(22)),
                    ),
                  )),
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
    );
  }
}
