import 'dart:convert';

import 'package:finder/config/api_client.dart';
import 'package:finder/models/topic_comments_model.dart';
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

class UserTopicCommentsPage extends StatefulWidget {
  final int userId;
  UserTopicCommentsPage({this.userId});
  @override
  _UserTopicCommentsPageState createState() => _UserTopicCommentsPageState();
}

class _UserTopicCommentsPageState extends State<UserTopicCommentsPage> {
  List<TopicCommentsModelData> topicComments = [];
  bool isLoading = true;
  bool hasMore = true;
  EasyRefreshController _refreshController;
  int pageCount = 1;
  ScrollController _scrollController;
  bool isUserItSelf;

  @override
  void initState() {
    getData(pageCount: 1);
    _refreshController = EasyRefreshController();
    _scrollController = ScrollController();
    super.initState();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _scrollController.dispose();
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
          controller: _scrollController,
          // primary: true,
          // physics: AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 40),
          itemCount: this.topicComments.length,
          itemBuilder: (context, index) {
            return buildContent(this.topicComments[index]);
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

  buildContent(TopicCommentsModelData item) {
    String time =
        item.time.month.toString() + '月' + item.time.day.toString() + '日';
    Widget child;
    child = GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, Routes.topicCommentDetail,
            arguments: item);
      },
      child: Container(
        // width: 100,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        margin: EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(boxShadow: [
          BoxShadow(blurRadius: 6, color: Colors.black12),
          BoxShadow(color: Colors.white)
        ], borderRadius: BorderRadius.circular(15), color: Colors.white),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
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
                child: InkWell(
                  onTap: () {
                    Application.router.navigateTo(context,
                        "${Routes.topicDetail}?id=${item.topicId}&title=${Uri.encodeComponent(item.topicTitle)}");
                  },
                  child: Text(
                    '#' + item.topicTitle,
                    style: TextStyle(
                        color: Theme.of(context).primaryColor, fontSize: 17),
                  ),
                )),
            Padding(
              padding: EdgeInsets.only(top: 20, left: 0),
              child: contentPart(item.content),
            )
          ],
        ),
      ),
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
                    content: Text("确认要删除此条话题评论吗? "),
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
                              this.topicComments.remove(item);
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

  Widget contentPart(String content) {
    double picWidth = ScreenUtil().setWidth(180);
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
            // width: ScreenUtil().setWidth(500),
            alignment: Alignment.topLeft,
            // color: Colors.green,
            child: Wrap(
              spacing: ScreenUtil().setWidth(15),
              runSpacing: ScreenUtil().setWidth(15),
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
                          borderRadius: BorderRadius.circular(2),
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
    List<TopicCommentsModelData> temp = [];
    bool hasMore;
    if (this.topicComments.length == 0) {
      for (int i = 1; i <= pageCount; i++) {
        var data = await apiClient.getUserTopicComments(
            page: i, userId: widget.userId);
        TopicCommentsModel topicComments = TopicCommentsModel.fromJson(data);
        hasMore = topicComments.hasMore;
        temp.addAll(topicComments.topicComments);
        // print(data);
      }

      this.pageCount = pageCount;
    } else {
      var data = await apiClient.getUserTopicComments(
          page: pageCount, userId: widget.userId);
      TopicCommentsModel topicComments = TopicCommentsModel.fromJson(data);
      hasMore = topicComments.hasMore;
      temp.addAll(topicComments.topicComments);
    }
    if (!mounted) return;

    setState(() {
      this.isLoading = false;
      this.topicComments.addAll(temp);
      this.hasMore = hasMore;
      this.pageCount++;
    });
  }
}
