import 'package:flutter/material.dart';
import 'package:finder/public.dart';
import 'package:finder/model/activity_model.dart';

class HomePageActivities extends StatelessWidget {
  final ActivityModel activities;
  HomePageActivities(this.activities);
  @override
  Widget build(BuildContext context) {
    return Container(
      height: ScreenUtil().setHeight(500),
      width: ScreenUtil().setWidth(710),
      margin: EdgeInsets.only(bottom: ScreenUtil().setHeight(20)),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
              bottomLeft: Radius.circular(10),
              bottomRight: Radius.circular(10))),
      child: Column(
        children: <Widget>[_title(), _activityPart()],
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
            child: Text('知·活动',
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
