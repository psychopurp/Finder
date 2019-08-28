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
      child: Column(
        children: <Widget>[_title(), _topicsPart()],
      ),
    );
  }

  Widget _title() {
    return Container(
      height: ScreenUtil().setHeight(80),
      width: ScreenUtil().setWidth(750),
      color: Colors.white,
      child: Row(
        children: <Widget>[
          Container(
            width: ScreenUtil().setWidth(500),
            height: ScreenUtil().setHeight(80),
            // color: Colors.yellow,
            child: Padding(
              padding: EdgeInsets.only(
                  top: ScreenUtil().setHeight(10),
                  left: ScreenUtil().setWidth(20)),
              child: Text(
                '与·话题',
                style: TextStyle(fontSize: ScreenUtil().setSp(50)),
              ),
            ),
          ),
          Material(
            // color: Colors.green,
            child: InkWell(
              onTap: () {},
              child: Container(
                width: ScreenUtil().setWidth(250),
                height: ScreenUtil().setHeight(80),
                child: Padding(
                    padding: EdgeInsets.only(
                        // top: ScreenUtil().setHeight(15),
                        left: ScreenUtil().setWidth(20)),
                    child: Icon(Icons.more_horiz)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _topicsPart() {
    return Container(
      height: ScreenUtil().setHeight(320),
      width: ScreenUtil().setWidth(750),
      color: Colors.white,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: this.topics.data.length,
        itemBuilder: (context, index) {
          return _singleItem(context, this.topics.data[index], index);
        },
      ),
    );
  }

  _singleItem(BuildContext context, TopicModelData item, int index) {
    bool isLastItem = (index == this.topics.data.length - 1);

    return CachedNetworkImage(
      imageUrl: item.image,
      imageBuilder: (context, imageProvider) => InkWell(
        onTap: () {
          print(item.title);
        },
        child: Container(
          height: ScreenUtil().setHeight(320),
          width: ScreenUtil().setWidth(550),
          margin: isLastItem
              ? EdgeInsets.only(
                  left: ScreenUtil().setWidth(20),
                  right: ScreenUtil().setWidth(20),
                )
              : EdgeInsets.only(
                  left: ScreenUtil().setWidth(20),
                ),
          decoration: BoxDecoration(
            // color: Colors.green,
            borderRadius: BorderRadius.all(Radius.circular(3)),
            // border: Border.all(color: Colors.black, width: 2),
            image: DecorationImage(
              image: imageProvider,
              fit: BoxFit.fill,
            ),
          ),
        ),
      ),
      errorWidget: (context, url, error) => Icon(Icons.error),
    );
  }
}
