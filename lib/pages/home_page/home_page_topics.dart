import 'package:flutter/material.dart';
import 'package:finder/model/topic_model.dart';
import 'package:finder/public.dart';

class HomePageTopics extends StatelessWidget {
  final TopicModel topics;
  HomePageTopics(this.topics);
  @override
  Widget build(BuildContext context) {
    return Container(
      height: ScreenUtil().setHeight(360),
      width: ScreenUtil().setWidth(710),
      margin: EdgeInsets.only(bottom: ScreenUtil().setHeight(20)),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
              bottomLeft: Radius.circular(10),
              bottomRight: Radius.circular(10))),
      // color: Colors.white,
      child: Column(
        children: <Widget>[_title(), _topicsPart()],
      ),
    );
  }

  Widget _title() {
    return Container(
      height: ScreenUtil().setHeight(80),
      width: ScreenUtil().setWidth(750),
      // color: Colors.amber,
      child: Row(
        children: <Widget>[
          Container(
            width: ScreenUtil().setWidth(500),
            height: ScreenUtil().setHeight(80),
            // color: Colors.yellow,
            padding: EdgeInsets.only(
                top: ScreenUtil().setHeight(20),
                left: ScreenUtil().setWidth(20)),
            child: Text('与·话题',
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: ScreenUtil().setSp(35),
                    fontWeight: FontWeight.w600)),
          ),
          Material(
            color: Colors.white,
            child: Padding(
                padding: EdgeInsets.only(
                    // top: ScreenUtil().setHeight(15),
                    left: ScreenUtil().setWidth(60)),
                child: IconButton(
                  icon: Icon(
                    Icons.more_horiz,
                    color: Colors.black,
                    size: ScreenUtil().setSp(50),
                  ),
                  onPressed: () {},
                )),
          ),
        ],
      ),
    );
  }

  Widget _topicsPart() {
    return Container(
      height: ScreenUtil().setHeight(260),
      width: ScreenUtil().setWidth(750),
      // color: Colors.yellow,
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
        child: Align(
          child: Container(
            height: ScreenUtil().setHeight(250),
            width: ScreenUtil().setWidth(450),
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
            child: Stack(
              children: <Widget>[
                Opacity(
                  opacity: 0.5,
                  child: Container(
                    // width: ScreenUtil().setWidth(750),
                    decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.all(Radius.circular(3))),
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  child: Text(
                    item.title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: ScreenUtil().setSp(60),
                      fontWeight: FontWeight.bold,
                    ),
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
