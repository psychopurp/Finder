import 'package:finder/config/api_client.dart';
import 'package:finder/models/activity_model.dart';
import 'package:finder/plugin/pics_swiper.dart';
import 'package:finder/provider/user_provider.dart';
import 'package:finder/public.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ActivityDetailPage extends StatefulWidget {
  final int activityId;
  ActivityDetailPage({this.activityId});
  @override
  _ActivityDetailPageState createState() => _ActivityDetailPageState();
}

class _ActivityDetailPageState extends State<ActivityDetailPage> {
  ActivityModelData activity;

  var collect;

  @override
  void initState() {
    getInitialData();
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

    return Scaffold(
        appBar: AppBar(),
        body: (this.activity != null)
            ? Stack(
                children: <Widget>[
                  Container(
                    color: Colors.white,
                    child: ListView(
                      padding: EdgeInsets.all(0),
                      children: <Widget>[
                        top(picHeight: picHeight, picWidth: picWidth),
                        Divider(
                          height: 10,
                          indent: ScreenUtil().setWidth(50),
                          endIndent: ScreenUtil().setWidth(50),
                          thickness: 1,
                        ),
                        description(),
                        SizedBox(
                          height: ScreenUtil().setHeight(200),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    left: 0,
                    right: 0,
                    child: bottomBar(user),
                  )
                ],
              )
            : Container(
                height: 400,
                child: FinderDialog.showLoading(),
              ));
  }

  top({double picWidth, double picHeight}) => Align(
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
                  // print(activity.poster);
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
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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

  description() => Align(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(50)),
          child: DefaultTextStyle(
            style: Theme.of(context).textTheme.body1,
            child: Text(activity.description),
          ),
        ),
      );

  collectHandle(UserProvider user, ActivityModelData item) async {
    String showText = "";
    if (user.isLogIn) {
      if (item.isCollected == true) {
        var data = await apiClient.deleteCollection(
            modelId: item.id, type: ApiClient.ACTIVITY);
        if (data['status'] == true) {
          showText = '取消收藏成功';
          item.isCollected = false;
        } else {
          showText = '取消收藏失败';
        }
      } else {
        var data = await apiClient.addCollection(
            type: ApiClient.ACTIVITY, id: item.id);
        if (data['status'] == true) {
          showText = '收藏成功';
          item.isCollected = true;
        } else {
          showText = '收藏失败';
        }
      }
      Future.delayed(Duration(milliseconds: 300), () {
        BotToast.showText(
            text: showText,
            align: Alignment(0, 0.5),
            duration: Duration(milliseconds: 400));
      });

      setState(() {});
    } else {
      //TODO 添加未登录的状态
    }
  }

  Widget bottomBar(UserProvider user) {
    print(activity.isCollected);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(230)),
      child: MaterialButton(
        onPressed: () {
          collectHandle(user, activity);
        },
        shape: StadiumBorder(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            AnimatedSwitcher(
              duration: Duration(milliseconds: 400),
              transitionBuilder: (child, anim) {
                return ScaleTransition(child: child, scale: anim);
              },
              child: Icon(collect[activity.isCollected],
                  key: ValueKey(activity.isCollected),
                  color: Theme.of(context).primaryColor),
            ),
            Text(
              "关注活动",
              style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: ScreenUtil().setSp(35)),
            )
          ],
        ),
        color: Colors.white,
        splashColor: Colors.white,
        minWidth: ScreenUtil().setWidth(226),
        height: 35,
      ),
    );
  }

  Future getInitialData() async {
    var data = await apiClient.getActivities(activityId: widget.activityId);
    ActivityModel activityModel = ActivityModel.fromJson(data);

    setState(() {
      this.activity = activityModel.data.first;
    });
  }
}
