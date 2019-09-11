import 'package:finder/routers/application.dart';
import 'package:flutter/material.dart';
import 'package:finder/models/topic_model.dart';
import 'package:finder/public.dart';

class HomePageTopics extends StatelessWidget {
  final TopicModel topics;
  final double mainHeight = 560;
  final double titleHeight = 100;
  HomePageTopics(this.topics);
  @override
  Widget build(BuildContext context) {
    // print(topics.data[0].toJson());
    return Container(
      height: ScreenUtil().setHeight(mainHeight),
      width: ScreenUtil().setWidth(710),
      // margin: EdgeInsets.only(bottom: ScreenUtil().setHeight(20)),
      decoration: BoxDecoration(
        color: Colors.white,
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
          _topicsInSchoolPart(),
          _topicsNotInSchoolPart()
        ],
      ),
    );
  }

  Widget _title(context) {
    return Container(
      height: ScreenUtil().setHeight(titleHeight),
      width: ScreenUtil().setWidth(750),
      // color: Colors.amber,
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

  Widget _topicsInSchoolPart() {
    return Container(
      height: ScreenUtil().setHeight(220),
      width: ScreenUtil().setWidth(750),
      // color: Colors.green,
      child: ListView.builder(
        padding: EdgeInsets.only(top: ScreenUtil().setHeight(0)),
        scrollDirection: Axis.horizontal,
        itemCount: this.topics.data.length,
        itemBuilder: (context, index) {
          return _singleItem(context, this.topics.data[index], index);
        },
      ),
    );
  }

  Widget _topicsNotInSchoolPart() {
    return Container(
      height: ScreenUtil().setHeight(240),
      width: ScreenUtil().setWidth(750),
      // color: Colors.blue,
      child: ListView.builder(
        padding: EdgeInsets.only(top: ScreenUtil().setHeight(15)),
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
          print(item.id);
        },
        child: Align(
          alignment: Alignment.topCenter,
          child: Container(
            height: ScreenUtil().setHeight(220),
            width: ScreenUtil().setWidth(320),
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
                        '校内话题',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: ScreenUtil().setSp(20)),
                      ),
                    )),
                Opacity(
                  opacity: 0.1,
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
                      fontSize: ScreenUtil().setSp(28),
                      fontWeight: FontWeight.bold,
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
