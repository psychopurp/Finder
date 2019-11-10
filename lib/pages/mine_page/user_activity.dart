import 'dart:convert';

import 'package:finder/config/api_client.dart';
import 'package:finder/models/activity_model.dart';
import 'package:finder/models/engage_topic_comment_model.dart';
import 'package:finder/models/topic_comments_model.dart';
import 'package:finder/models/topic_model.dart';
import 'package:finder/plugin/avatar.dart';
import 'package:finder/plugin/pics_swiper.dart';
import 'package:finder/public.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_easyrefresh/material_footer.dart';
import 'package:flutter_easyrefresh/material_header.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
          // padding: EdgeInsets.only(top: kToolbarHeight * 2 + 20),
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
    // String time =
    //     item.time.month.toString() + '月' + item.time.day.toString() + '日';
    Widget child;
    child = GestureDetector(
      onTap: () {
        // Navigator.pushNamed(context, Routes.topicDetail,
        //     arguments: {"item": item});
      },
      child: Container(
        // width: 100,
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white.withOpacity(0.5)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: ScreenUtil().setWidth(130),
              // color: Colors.amber,
              // child: Text(time),
            ),
            // Padding(
            //   padding: EdgeInsets.only(top: 0, left: 10),
            //   child: contentPart(item.content),
            // )
          ],
        ),
      ),
    );

    return child;
  }

  Widget contentPart(String content) {
    double picWidth = ScreenUtil().setWidth(160);
    bool isSinglePic = false;
    var json = jsonDecode(content);
    List imagesJson = json['images'];
    List<String> images = [];
    String text = json['text'];
    imagesJson.forEach((i) {
      images.add(Avatar.getImageUrl(i));
    });

    return Container(
      // color: Colors.amber,
      // height: ScreenUtil().setHeight(400),
      // width: ScreenUtil().setWidth(750),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            text,
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontWeight: FontWeight.w500,
                fontFamily: 'normal',
                fontSize: ScreenUtil().setSp(30)),
          ),
          SizedBox(
            height: (text == "" || text == null) ? 0 : 10,
          ),
          Container(
            width: ScreenUtil().setWidth(500),
            // color: Colors.green,
            child: Wrap(
              spacing: ScreenUtil().setWidth(10),
              runSpacing: 5,
              children: images.asMap().keys.map((index) {
                isSinglePic = (images.length == 1) ? true : false;
                var _singlePic = Container(
                  child: CachedNetworkImage(
                    imageUrl: images[index],
                    fit: BoxFit.cover,
                    placeholder: (context, _) {
                      return Center(
                        child: CupertinoActivityIndicator(),
                      );
                    },
                  ),
                  constraints: BoxConstraints(maxHeight: 400, minWidth: 400),
                );
                return CachedNetworkImage(
                  imageUrl: images[index],
                  errorWidget: (context, url, error) => Icon(Icons.error),
                  imageBuilder: (content, imageProvider) => InkWell(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          fullscreenDialog: false,
                          builder: (_) {
                            return PicSwiper(
                              index: index,
                              pics: images,
                            );
                          }));
                    },
                    child: Container(
                      height: picWidth,
                      width: picWidth,
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              image: imageProvider, fit: BoxFit.cover)),
                    ),
                  ),
                );
              }).toList(),
            ),
          )
        ],
      ),
    );
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
        print(data);
      }

      this.pageCount = pageCount;
    } else {
      var data =
          await apiClient.getUserTopics(page: pageCount, userId: widget.userId);
      ActivityModel activities = ActivityModel.fromJson(data);
      hasMore = activities.hasMore;
      temp.addAll(activities.data);
    }

    setState(() {
      this.isLoading = false;
      this.activities.addAll(temp);
      this.hasMore = hasMore;
      this.pageCount++;
    });
  }
}
