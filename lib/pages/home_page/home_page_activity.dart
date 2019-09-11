import 'package:finder/routers/application.dart';
import 'package:flutter/material.dart';
import 'package:finder/public.dart';
import 'package:finder/models/activity_model.dart';

class HomePageActivities extends StatelessWidget {
  final ActivityModel activities;
  final double mainHeight = 520;
  final double titleHeight = 100;
  HomePageActivities(this.activities);
  @override
  Widget build(BuildContext context) {
    return Container(
      height: ScreenUtil().setHeight(mainHeight),
      width: ScreenUtil().setWidth(710),
      margin: EdgeInsets.only(bottom: ScreenUtil().setHeight(20)),
      decoration: BoxDecoration(
        color: Colors.white,
        // borderRadius: BorderRadius.only(
        //     topLeft: Radius.circular(20),
        //     topRight: Radius.circular(20),
        //     bottomLeft: Radius.circular(10),
        //     bottomRight: Radius.circular(10))
      ),
      child: Column(
        children: <Widget>[_title(context), _activityPart()],
      ),
    );
  }

  Widget _title(BuildContext context) {
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
                Text('  知·活动',
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: ScreenUtil().setSp(35),
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          InkWell(
            onTap: () {
              Application.router.navigateTo(context, '/home/moreActivities');
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

  Widget _activityPart() {
    return Container(
      height: ScreenUtil().setHeight(420),
      width: ScreenUtil().setWidth(750),
      // color: Colors.yellow,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: this.activities.data.length,
        itemBuilder: (context, index) {
          return _singleItem(context, this.activities.data[index], index);
        },
      ),
    );
  }

  _singleItem(BuildContext context, ActivityModelData item, int index) {
    bool isLastItem = (index == this.activities.data.length - 1);

    return CachedNetworkImage(
      imageUrl: item.poster,
      imageBuilder: (context, imageProvider) => InkWell(
        onTap: () {
          print(item.title);
        },
        child: Align(
          alignment: Alignment.topCenter,
          child: Container(
            height: ScreenUtil().setHeight(390),
            width: ScreenUtil().setWidth(220),
            // color: Colors.blue,
            margin: isLastItem
                ? EdgeInsets.only(
                    left: ScreenUtil().setWidth(20),
                    right: ScreenUtil().setWidth(20),
                    top: ScreenUtil().setWidth(5),
                  )
                : EdgeInsets.only(
                    left: ScreenUtil().setWidth(20),
                    top: ScreenUtil().setWidth(5),
                  ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  height: ScreenUtil().setHeight(310),
                  width: ScreenUtil().setWidth(220),
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
                Container(
                  height: ScreenUtil().setHeight(80),
                  width: ScreenUtil().setWidth(220),
                  padding: EdgeInsets.only(left: ScreenUtil().setWidth(5)),
                  // color: Colors.amber,
                  child: Text(item.title,
                      maxLines: 2,
                      textAlign: TextAlign.start,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: ScreenUtil().setSp(25),
                          fontWeight: FontWeight.w600)),
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
