import 'package:finder/models/activity_model.dart';
import 'package:finder/public.dart';
import 'package:flutter/material.dart';

class ActivityDetailPage extends StatefulWidget {
  final ActivityModelData activity;
  ActivityDetailPage({this.activity});
  @override
  _ActivityDetailPageState createState() => _ActivityDetailPageState(activity);
}

class _ActivityDetailPageState extends State<ActivityDetailPage> {
  ActivityModelData activity;
  IconData collectIcon = Icons.favorite_border;
  List<IconData> collectIcons = [Icons.favorite_border, Icons.favorite];
  _ActivityDetailPageState(this.activity);

  @override
  Widget build(BuildContext context) {
    var top = Align(
      child: Container(
        height: ScreenUtil().setHeight(460),
        width: ScreenUtil().setWidth(750),
        // color: Colors.amber,
        padding: EdgeInsets.only(left: ScreenUtil().setWidth(50)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              height: ScreenUtil().setHeight(310),
              width: ScreenUtil().setWidth(220),
              decoration: BoxDecoration(
                  // color: Colors.yellow,
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black38,
                        offset: Offset(5.0, 8.0),
                        blurRadius: 10.0,
                        spreadRadius: 1.0),
                  ],
                  image: DecorationImage(
                      image: CachedNetworkImageProvider(activity.poster),
                      fit: BoxFit.fill)),
            ),
            DefaultTextStyle(
              style: Theme.of(context).textTheme.title,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    // color: Colors.cyan,
                    width: ScreenUtil().setWidth(480),
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    child: Text(
                      activity.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: ScreenUtil().setSp(30),
                          fontWeight: FontWeight.lerp(
                              FontWeight.w400, FontWeight.w800, 0.8)),
                    ),
                  ),
                  Container(
                    // color: Colors.yellow,
                    width: ScreenUtil().setWidth(480),
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.people,
                          color: Theme.of(context).primaryColor,
                        ),
                        Container(
                          // color: Colors.blue,
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          width: ScreenUtil().setWidth(380),
                          child: Text(
                            activity.sponsor,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: ScreenUtil().setSp(30),
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    // color: Colors.yellow,
                    width: ScreenUtil().setWidth(480),
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.calendar_today,
                          color: Theme.of(context).primaryColor,
                        ),
                        Container(
                          // color: Colors.blue,
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          width: ScreenUtil().setWidth(380),
                          child: Text(
                            activity.startTime
                                    .split(" ")[0]
                                    .replaceAll('-', '.') +
                                "-" +
                                activity.endTime
                                    .split(' ')[0]
                                    .replaceAll('-', '.'),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: ScreenUtil().setSp(30),
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    // color: Colors.yellow,
                    width: ScreenUtil().setWidth(480),
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    // color: Colors.blue,
                    child: Row(
                      children: <Widget>[
                        Icon(
                          IconData(0xe608, fontFamily: "myIcon"),
                          color: Theme.of(context).primaryColor,
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          width: ScreenUtil().setWidth(380),
                          child: Text(
                            activity.place,
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: ScreenUtil().setSp(30),
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );

    var description = Align(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(50)),
        child: DefaultTextStyle(
          style: Theme.of(context).textTheme.body1,
          child: Text(activity.description),
        ),
      ),
    );

    var bottomBar = DefaultTextStyle(
        style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontSize: ScreenUtil().setSp(35)),
        child: Container(
          height: kToolbarHeight,
          // color: Colors.white,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                  color: Colors.black38,
                  offset: Offset(5.0, 8.0),
                  blurRadius: 10.0,
                  spreadRadius: 1.0),
            ],
          ),
          child: Row(
            children: <Widget>[
              InkWell(
                onTap: () {
                  setState(() {
                    if (collectIcon == collectIcons[0]) {
                      this.collectIcon = this.collectIcons[1];
                    } else {
                      this.collectIcon = collectIcons[0];
                    }
                  });
                },
                child: Container(
                  width: ScreenUtil().setWidth(200),
                  height: kToolbarHeight,
                  // color: Colors.blue,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      AnimatedSwitcher(
                          transitionBuilder: (child, anim) {
                            return ScaleTransition(child: child, scale: anim);
                          },
                          duration: Duration(milliseconds: 300),
                          child: Container(
                            key: ValueKey(this.collectIcon),
                            child: Icon(
                              this.collectIcon,
                              color: Theme.of(context).primaryColor,
                            ),
                          )),
                      Text("收藏")
                    ],
                  ),
                ),
              ),
              InkWell(
                onTap: () {},
                child: Container(
                  width: ScreenUtil().setWidth(200),
                  height: kToolbarHeight,
                  // color: Colors.blue,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Icon(
                        Icons.phone,
                        color: Theme.of(context).primaryColor,
                      ),
                      Text("联系")
                    ],
                  ),
                ),
              ),
              Container(
                width: ScreenUtil().setWidth(350),
                height: kToolbarHeight,
                // color: Colors.blue,
                alignment: Alignment.center,
                child: Container(
                  alignment: Alignment.center,
                  width: ScreenUtil().setWidth(300),
                  height: ScreenUtil().setHeight(80),
                  decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(20)),
                  child: Text(
                    "立即参加",
                    style: TextStyle(
                        color: Colors.white, fontSize: ScreenUtil().setSp(30)),
                  ),
                ),
              ),
            ],
          ),
        ));

    return Scaffold(
      appBar: AppBar(),
      body: Stack(
        children: <Widget>[
          Container(
            color: Colors.white,
            child: ListView(
              padding: EdgeInsets.all(0),
              children: <Widget>[
                top,
                Divider(
                  height: 10,
                  indent: ScreenUtil().setWidth(50),
                  endIndent: ScreenUtil().setWidth(50),
                  thickness: 1,
                ),
                description,
                SizedBox(
                  height: ScreenUtil().setHeight(200),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: bottomBar,
          )
        ],
      ),
    );
  }

  // Future
}
