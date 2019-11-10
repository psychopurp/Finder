import 'dart:convert';

import 'package:finder/config/api_client.dart';
import 'package:finder/models/activity_model.dart';
import 'package:finder/models/engage_topic_comment_model.dart';
import 'package:finder/models/topic_comments_model.dart';
import 'package:finder/models/topic_model.dart';
import 'package:finder/plugin/avatar.dart';
import 'package:finder/plugin/pics_swiper.dart';
import 'package:finder/provider/user_provider.dart';
import 'package:finder/public.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_easyrefresh/material_footer.dart';
import 'package:flutter_easyrefresh/material_header.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class UserActivityPage extends StatefulWidget {
  final int userId;
  UserActivityPage({this.userId});
  @override
  _UserActivityPageState createState() => _UserActivityPageState();
}

class _UserActivityPageState extends State<UserActivityPage> {
  List<ActivityModelData> activities = [];
  bool isLoading = true;
  bool hasMore = true;
  EasyRefreshController _refreshController;
  int pageCount = 1;
  ScrollController controller;
  bool isUserItSelf;

  @override
  void initState() {
    getData(pageCount: 1);
    _refreshController = EasyRefreshController();
    controller = ScrollController();
    super.initState();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context);
    this.isUserItSelf = (user.userInfo.id == widget.userId);
    return Container(
      // color: Theme.of(context).dividerColor,
      child: body,
    );
  }

  Widget get body {
    Widget child;
    if (this.isLoading) {
      child = Container(
          alignment: Alignment.center,
          height: double.infinity,
          child: CupertinoActivityIndicator());
    } else {
      child = EasyRefresh(
        enableControlFinishLoad: true,
        // primary: true,
        footer: MaterialFooter(),
        header: MaterialHeader(),
        controller: _refreshController,
        topBouncing: false,
        bottomBouncing: false,
        child: ListView.builder(
          controller: controller,
          // primary: true,
          // physics: AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.only(top: 10, bottom: 40),
          itemCount: this.activities.length,
          itemBuilder: (context, index) {
            return buildContent(this.activities[index]);
          },
        ),
        // onRefresh: () async {
        //   this.topicComments = [];
        //   await getData(pageCount: 3);
        //   _refreshController.resetLoadState();
        // },
        onLoad: () async {
          await Future.delayed(Duration(milliseconds: 500), () {
            getData(pageCount: this.pageCount);
          });
          _refreshController.finishLoad(success: true, noMore: (!this.hasMore));
        },
      );
    }

    return AnimatedSwitcher(
        duration: Duration(milliseconds: 200),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
              child: child,
              opacity:
                  CurvedAnimation(curve: Curves.easeInOut, parent: animation));
        },
        child: child);
  }

  buildContent(ActivityModelData item) {
    String heroTag = item.id.toString() + 'myActivity';
    DateTime start = item.startTime;
    DateTime end = item.endTime;
    String startTime = start.year.toString() +
        '-' +
        start.month.toString() +
        '-' +
        start.day.toString();
    String endTime = end.year.toString() +
        '-' +
        end.month.toString() +
        '-' +
        end.day.toString();

    Widget child;
    child = Container(
        padding: EdgeInsets.only(left: 20, right: 20, top: 50, bottom: 20),
        margin: EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10), color: Colors.white),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            ///活动海报
            Hero(
              tag: heroTag,
              child: Container(
                height: ScreenUtil().setHeight(320),
                width: ScreenUtil().setWidth(250),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(3)),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black12,
                          offset: Offset(-1.0, 2.0),
                          blurRadius: 2.0,
                          spreadRadius: 2.0),
                    ],
                    image: DecorationImage(
                        image: CachedNetworkImageProvider(item.poster),
                        fit: BoxFit.cover)),
              ),
            ),

            ///活动信息
            Expanded(
              child: Container(
                padding: EdgeInsets.only(left: 10),
                // color: Colors.amber,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    ///活动标题
                    Container(
                      // color: Colors.cyan,
                      padding: EdgeInsets.symmetric(vertical: 0),
                      child: Text(
                        '#' + item.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: ScreenUtil().setSp(30),
                            fontWeight: FontWeight.lerp(
                                FontWeight.w400, FontWeight.w800, 0.8)),
                      ),
                    ),

                    ///主办方
                    Container(
                      padding: EdgeInsets.only(top: 10),
                      child: Text(
                        '主办方：' + item.sponsor,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: ScreenUtil().setSp(25),
                            fontWeight: FontWeight.w500),
                      ),
                    ),

                    ///活动时间
                    Container(
                      // color: Colors.amber,
                      padding: EdgeInsets.only(bottom: 10, top: 5),
                      child: Text(
                        '开始时间：' + startTime + '\n' + '结束时间：' + endTime,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: ScreenUtil().setSp(25),
                            fontWeight: FontWeight.w500),
                      ),
                    ),

                    ///活动地点
                    Container(
                      // color: Colors.amber,
                      padding: EdgeInsets.symmetric(vertical: 0),
                      child: Text(
                        '活动地点：' + item.place,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: ScreenUtil().setSp(25),
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ));

    child = GestureDetector(
      onTap: () {
        var formData = {'item': item, 'heroTag': heroTag};
        Navigator.pushNamed(context, Routes.activityDetail,
            arguments: formData);
      },
      child: child,
    );
    if (isUserItSelf) {
      child = Stack(children: <Widget>[
        child,
        Positioned(
          right: 0,
          top: 5,
          child: MaterialButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) {
                  return AlertDialog(
                    title: Text("提示"),
                    content: Text("确认要删除此活动吗? "),
                    actions: <Widget>[
                      FlatButton(
                        child: Text("取消"),
                        onPressed: () => Navigator.of(context).pop(), // 关闭对话框
                      ),
                      FlatButton(
                          child: Text("删除"),
                          onPressed: () async {
                            FinderDialog.showLoading();
                            var data = await apiClient.deleteTopicComment(
                                commentId: item.id);
                            if (data['status']) {
                              // this.topicComments.remove(item);
                              setState(() {});
                            }
                            Navigator.pop(context);
                          }),
                    ],
                  );
                },
              );
            },
            shape: CircleBorder(),
            child: Icon(Icons.delete_outline),
          ),
        )
      ]);
    }

    return child;
  }

  Future getData({int pageCount}) async {
    List<ActivityModelData> temp = [];
    bool hasMore;
    if (this.activities.length == 0) {
      for (int i = 1; i <= pageCount; i++) {
        var data =
            await apiClient.getUserActivities(page: i, userId: widget.userId);
        ActivityModel activities = ActivityModel.fromJson(data);
        hasMore = activities.hasMore;
        temp.addAll(activities.data);
        // print('data====$data');
      }

      this.pageCount = pageCount;
    } else {
      var data = await apiClient.getUserActivities(
          page: pageCount, userId: widget.userId);
      ActivityModel activities = ActivityModel.fromJson(data);
      hasMore = activities.hasMore;
      temp.addAll(activities.data);
    }
    if (!mounted) return;

    setState(() {
      this.isLoading = false;
      this.activities.addAll(temp);
      this.hasMore = hasMore;
      this.pageCount++;
    });
  }
}
