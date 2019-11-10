import 'package:finder/plugin/callback.dart';
import 'package:finder/routers/application.dart';
import 'package:flutter/material.dart';
import 'package:finder/public.dart';
import 'package:finder/models/activity_model.dart';

class HomePageActivities extends StatelessWidget {
  final ActivityModel activities;
  final double mainHeight = ScreenUtil().setHeight(510);
  final double titleHeight = ScreenUtil().setHeight(80);
  final PushCallback push;

  HomePageActivities(this.activities, this.push);

  @override
  Widget build(BuildContext context) {
    return Container(
      // height: mainHeight,
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 20),
      // color: Colors.blue,
      child: Column(
        children: <Widget>[_title(context), _activityPart()],
      ),
    );
  }

  Widget _title(BuildContext context) {
    return Container(
      height: titleHeight,
      width: ScreenUtil().setWidth(750),
      // color: Colors.yellow,
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
                  height: titleHeight / 4,
//                  decoration: BoxDecoration(
//                    // color: Colors.amber,
//                    gradient: LinearGradient(colors: [
//                      Colors.white,
//                      Theme.of(context).primaryColor.withOpacity(0.5),
//                      Theme.of(context).primaryColor
//                    ]),
//                  ),
                ),
                Text('  知·活动',
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
              push(() async {
                Application.router.navigateTo(context, '/home/moreActivities');
              });
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

  Widget _activityPart() {
    return Container(
      height: mainHeight - 20,
      width: ScreenUtil().setWidth(750),
      padding: EdgeInsets.only(left: ScreenUtil().setWidth(20)),
      // color: Colors.green,
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
    // bool isLastItem = (index == this.activities.data.length - 1);
    double picWidth = ScreenUtil().setWidth(230);

    ///宽高比 1/1.4
    double picHeight = picWidth * 1.4;

    return CachedNetworkImage(
      imageUrl: item.poster,
      imageBuilder: (context, imageProvider) => GestureDetector(
        onTap: () {
          push(() async {
            var formData = {'item': item, 'heroTag': item.id.toString()};
            Navigator.pushNamed(context, Routes.activityDetail,
                arguments: formData);
          });
        },
        child: Align(
          child: Container(
            width: picWidth,
            // height: picWidth * 1.9,
            // color: Colors.yellow,
            margin: EdgeInsets.only(
              right: ScreenUtil().setWidth(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Hero(
                  tag: item.id.toString() + "activityDetail",
                  child: Container(
                    height: picHeight,
                    width: picWidth,
                    decoration: BoxDecoration(
                      // color: Colors.green,
                      borderRadius: BorderRadius.circular(10),
                      // border: Border.all(color: Colors.black, width: 2),
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(5),
                ),
                Container(
                  width: picWidth,
                  padding: EdgeInsets.only(left: ScreenUtil().setWidth(5)),
                  // color: Colors.yellow,
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
