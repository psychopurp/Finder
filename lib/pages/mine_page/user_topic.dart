import 'dart:convert';

import 'package:finder/config/api_client.dart';
import 'package:finder/models/topic_model.dart';
import 'package:finder/plugin/avatar.dart';
import 'package:finder/plugin/pics_swiper.dart';
import 'package:finder/provider/user_provider.dart';
import 'package:finder/public.dart';
import 'package:finder/routers/application.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_easyrefresh/material_footer.dart';
import 'package:flutter_easyrefresh/material_header.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class UserTopicPage extends StatefulWidget {
  final int userId;
  UserTopicPage({this.userId});
  @override
  _UserTopicPageState createState() => _UserTopicPageState();
}

class _UserTopicPageState extends State<UserTopicPage> {
  List<TopicModelData> topics = [];
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
    controller.dispose();
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
          itemCount: this.topics.length,
          itemBuilder: (context, index) {
            return buildContent(this.topics[index]);
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

  buildContent(TopicModelData item) {
    final double topicHeight = 200;
    final double topicWidth = topicHeight * 1.6;
    String time =
        item.time.month.toString() + '月' + item.time.day.toString() + '日';
    Widget child;
    child = Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      margin: EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10), color: Colors.white),
      child: Column(
        children: <Widget>[
          Container(
            child: Text(
              time,
              style: TextStyle(fontSize: 16),
            ),
          ),
          Container(
            width: double.infinity,
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(bottom: 5),
            child: Text(
              '#' + item.title,
              style: TextStyle(
                  color: Theme.of(context).primaryColor, fontSize: 17),
            ),
          ),
          Container(
            height: topicHeight,
            width: topicWidth,
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: CachedNetworkImageProvider(item.image),
                    fit: BoxFit.cover),
                borderRadius: BorderRadius.circular(10)),
          )
        ],
      ),
    );

    child = GestureDetector(
      onTap: () {
        Application.router.navigateTo(context,
            "${Routes.topicDetail}?id=${item.id}&title=${Uri.encodeComponent(item.title)}");
      },
      child: child,
    );

    if (isUserItSelf) {
      child = Stack(children: <Widget>[
        child,
        Positioned(
          right: 0,
          top: 10,
          child: MaterialButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) {
                  return AlertDialog(
                    title: Text("提示"),
                    content: Text("确认要删除此条话题吗? "),
                    actions: <Widget>[
                      FlatButton(
                        child: Text("取消"),
                        onPressed: () => Navigator.of(context).pop(), // 关闭对话框
                      ),
                      FlatButton(
                          child: Text("删除"),
                          onPressed: () async {
                            FinderDialog.showLoading();
                            var data =
                                await apiClient.deleteTopic(topicId: item.id);
                            if (data['status']) {
                              this.topics.remove(item);
                              setState(() {});
                            }
                            String msg = data['status'] ? "删除成功" : "删除失败";
                            Future.delayed(Duration(milliseconds: 500), () {
                              BotToast.showText(
                                  text: msg,
                                  align: Alignment(0, 0.5),
                                  duration: Duration(milliseconds: 500));
                            });
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
    List<TopicModelData> temp = [];
    bool hasMore;
    if (this.topics.length == 0) {
      for (int i = 1; i <= pageCount; i++) {
        var data =
            await apiClient.getUserTopics(page: i, userId: widget.userId);
        TopicModel topics = TopicModel.fromJson(data);
        hasMore = topics.hasMore;
        temp.addAll(topics.data);
        // print(data);
      }

      this.pageCount = pageCount;
    } else {
      var data =
          await apiClient.getUserTopics(page: pageCount, userId: widget.userId);
      TopicModel topics = TopicModel.fromJson(data);
      hasMore = topics.hasMore;
      temp.addAll(topics.data);
    }

    if (!mounted) return;
    setState(() {
      this.isLoading = false;
      this.topics.addAll(temp);
      this.hasMore = hasMore;
      this.pageCount++;
    });
  }
}
