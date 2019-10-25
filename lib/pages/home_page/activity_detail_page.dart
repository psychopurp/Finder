import 'package:finder/config/api_client.dart';
import 'package:finder/models/activity_model.dart';
import 'package:finder/plugin/pics_swiper.dart';
import 'package:finder/provider/user_provider.dart';
import 'package:finder/public.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ActivityDetailPage extends StatefulWidget {
  final ActivityModelData activity;
  ActivityDetailPage({this.activity});
  @override
  _ActivityDetailPageState createState() => _ActivityDetailPageState(activity);
}

class _ActivityDetailPageState extends State<ActivityDetailPage> {
  ActivityModelData activity;
  _ActivityDetailPageState(this.activity);

  var collect;

  @override
  void initState() {
    collect = {
      true: Icons.favorite,
      false: Icons.favorite_border,
    };
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double picWidth = ScreenUtil().setWidth(220);
    double picHeight = picWidth * 1.4;
    final user = Provider.of<UserProvider>(context);

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
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    fullscreenDialog: false,
                    builder: (_) {
                      return PicSwiper(
                        index: 0,
                        pics: [activity.poster],
                      );
                    }));
              },
              child: Container(
                height: picHeight,
                width: picWidth,
                decoration: BoxDecoration(
                    // color: Colors.yellow,
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black38,
                          offset: Offset(-1.0, 2.0),
                          blurRadius: 2.0,
                          spreadRadius: 1.0),
                    ],
                    image: DecorationImage(
                        image: CachedNetworkImageProvider(activity.poster),
                        fit: BoxFit.fill)),
              ),
            ),
            DefaultTextStyle(
              style: Theme.of(context).textTheme.body1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  ///title
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

                  ///主办方
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
                        Tooltip(
                          message: activity.sponsor,
                          child: Container(
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
                        ),
                      ],
                    ),
                  ),

                  ///时间
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

                  ///地点
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
                        Tooltip(
                          message: activity.place,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            width: ScreenUtil().setWidth(380),
                            child: Text(
                              activity.place,
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: ScreenUtil().setSp(25),
                                  fontWeight: FontWeight.w500),
                            ),
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
            child: bottomBar(user),
          )
        ],
      ),
    );
  }

  // Future

  Widget bottomBar(UserProvider user) {
    return Builder(builder: (context) {
      return DefaultTextStyle(
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
                  onTap: () async {
                    if (user.isLogIn) {
                      if (user.collection['activity'].contains(activity.id)) {
                        // apiClient.deleteCollection()
                        user.collection['activity'].remove(activity.id);
                      } else {
                        var data = await apiClient.addCollection(
                            type: ApiClient.ACTIVITY, id: this.activity.id);
                        user.collection['activity'].add(activity.id);
                        Future.delayed(Duration(milliseconds: 500), () {
                          Scaffold.of(context).showSnackBar(new SnackBar(
                            duration: Duration(milliseconds: 200),
                            content: new Text("${data}"),
                            action: new SnackBarAction(
                              label: "取消",
                              onPressed: () {},
                            ),
                          ));
                        });
                      }
                      setState(() {});
                    } else {
                      //TODO 添加未登录的状态
                    }
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
                              key: ValueKey<bool>(user.collection['activity']
                                  .contains(activity.id)),
                              child: Icon(
                                  collect[user.collection['activity']
                                      .contains(activity.id)],
                                  color: Theme.of(context).primaryColor),
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
                          color: Colors.white,
                          fontSize: ScreenUtil().setSp(30)),
                    ),
                  ),
                ),
              ],
            ),
          ));
    });
  }
}
