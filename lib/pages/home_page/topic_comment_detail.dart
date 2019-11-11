import 'dart:convert';

import 'package:finder/config/api_client.dart';
import 'package:finder/models/follower_model.dart';
import 'package:finder/models/topic_comments_model.dart';
import 'package:finder/pages/home_page/comment_page.dart';
import 'package:finder/pages/serve_page/he_says_page.dart';
import 'package:finder/plugin/avatar.dart';
import 'package:finder/plugin/pics_swiper.dart';
import 'package:finder/provider/user_provider.dart';
import 'package:finder/public.dart';
import 'package:finder/routers/application.dart';
import 'package:finder/routers/routes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_easyrefresh/material_footer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class TopicCommentDetailPage extends StatefulWidget {
  @override
  _TopicCommentDetailPageState createState() => _TopicCommentDetailPageState();
}

class _TopicCommentDetailPageState extends State<TopicCommentDetailPage>
    with TickerProviderStateMixin {
  TopicCommentsModelData topicComment;
  // int topicId;
  // String topicTitle;
  UserProvider userProvider;
  TabController tabController;
  List<FollowerModelData> liker = [];
  var bottomBar;

  @override
  void initState() {
    bottomBar = {
      "collect": {"name": "收藏", "handler": handleCollect},
      "report": {"name": "举报", "handler": () {}},
      "delete": {"name": "删除", "handler": handleDelete},
    };
    tabController = TabController(vsync: this, length: 2);
    super.initState();
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    userProvider = Provider.of<UserProvider>(context);
    topicComment = ModalRoute.of(context).settings.arguments;

    return Scaffold(
      appBar: AppBar(
        title: Text(topicComment.topicTitle),
        elevation: 1,
        textTheme: TextTheme(
            title: Theme.of(context)
                .appBarTheme
                .textTheme
                .title
                .copyWith(color: Colors.black)),
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: 10.0),
            child: IconButton(
                onPressed: () {
                  List<Widget> button = [];

                  bottomBar.forEach((item, object) {
                    button.add(ListTile(
                        title: Text(object['name']), onTap: object['handler']));
                  });

                  ///如果是自己的话题 有删除栏
                  if (this.topicComment.sender.id != userProvider.userInfo.id) {
                    button.removeLast();
                  }
                  showModalBottomSheet(
                      context: context,
                      builder: (_) {
                        return Container(
                          height: 200,
                          // color: Theme.of(context).dividerColor,
                          child: Column(
                            children: button,
                          ),
                        );
                      });
                },
                icon: Icon(Icons.more_vert, color: Colors.black87)),
          )
        ],
        // centerTitle: true,
      ),
      body: body,
    );
  }

  Widget get body {
    String comment = (this.topicComment.replyCount == 0)
        ? "评论"
        : '评论 ' + this.topicComment.replyCount.toString();
    String like = (this.topicComment.likes == 0)
        ? ""
        : this.topicComment.likes.toString();
    Widget child;
    child = CustomScrollView(
      slivers: <Widget>[
        SliverToBoxAdapter(child: buildTopContent()),
        SliverPersistentHeader(
          pinned: true,
          delegate: StickyTabBarDelegate(
            child: TabBar(
              isScrollable: true,
              labelColor: Theme.of(context).primaryColor,
              indicatorColor: Theme.of(context).primaryColor,
              indicatorWeight: 1,
              indicatorSize: TabBarIndicatorSize.label,
              // labelPadding: EdgeInsets.symmetric(horizontal: 25, vertical: 0),
              unselectedLabelColor: Color(0xff333333),
              controller: this.tabController,
              tabs: <Widget>[
                Container(
                    width: ScreenUtil().setWidth(375),
                    // margin: EdgeInsets.only(left: 50, right: 50),
                    child: Tab(text: comment)),
                Container(
                    width: ScreenUtil().setWidth(375),
                    // alignment: Alignment.centerRight,
                    // margin: EdgeInsets.only(left: 50, right: 50),
                    child: (topicComment.isLike)
                        ? Tab(
                            // text: ' ' + this.topicComment.likes.toString(),
                            icon: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(Icons.favorite,
                                    color: Theme.of(context).primaryColor),
                                Text("    " + like)
                              ],
                            ),
                          )
                        : Tab(text: '点赞 ' + like)),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          // 剩余补充内容TabBarView
          child: Container(
            height:
                ScreenUtil.screenHeightDp - kToolbarHeight - kTextTabBarHeight,
            // color: Colors.amber,
            child: TabBarView(
              controller: this.tabController,
              children: <Widget>[
                CommentPage(
                    topicId: this.topicComment.topicId,
                    topicCommentId: this.topicComment.id,
                    onDelete: (isDelete) {
                      if (isDelete) {
                        topicComment.replyCount--;
                        setState(() {});
                      }
                    },
                    onComment: (isComment) {
                      if (isComment) {
                        setState(() {
                          topicComment.replyCount++;
                        });
                      }
                    }),
                Padding(
                  padding: EdgeInsets.only(top: 20.0),
                  child: UserLikeWidget(
                    topicCommentId: this.topicComment.id,
                    isLike: () async {
                      var data = await apiClient.likeTopicComment(
                          topicCommentId: topicComment.id);
                      if (data['status']) {
                        if (topicComment.isLike) {
                          topicComment.isLike = false;
                          topicComment.likes--;
                        } else {
                          topicComment.isLike = true;
                          topicComment.likes++;
                        }
                        setState(() {});
                      }
                    },
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );

    return child;
  }

  buildTopContent() {
    String getTimeString(DateTime time) {
      DateTime now = DateTime.now();

      if (now.month == now.month) {
        if (now.difference(time).inMinutes < 60) {
          if (now.difference(time).inMinutes == 0) {
            return "刚刚";
          } else {
            return now.difference(time).inMinutes.toString() + '分钟前';
          }
        }
        if ((now.difference(time).inHours) < 24) {
          return (now.difference(time).inHours).toString() + '小时前';
        } else {
          if ((now.difference(time).inDays) > 3) {
            return time.month.toString() + '月' + time.day.toString() + '日';
          }
          return (now.difference(time).inDays).toString() + '天前';
        }
      }
      return time.month.toString() + '月' + time.day.toString() + '日';
    }

    Widget child = Container(
        color: Colors.white,
        padding: EdgeInsets.only(
            bottom: 20,
            left: ScreenUtil().setWidth(35),
            right: ScreenUtil().setWidth(35),
            top: ScreenUtil().setWidth(20)),
        // color: Colors.amber,
        // margin: EdgeInsets.only(bottom: 10),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ///头部
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        InkWell(
                          onTap: () {
                            Application.router.navigateTo(context,
                                "${Routes.userProfile}?senderId=${topicComment.sender.id}&heroTag=${topicComment.id.toString() + topicComment.sender.id.toString() + 'topic'}");
                          },
                          child: Hero(
                            tag: topicComment.sender.id.toString() +
                                topicComment.sender.id.toString() +
                                'topic detail',
                            child: Avatar(
                              url: topicComment.sender.avatar,
                              avatarHeight: ScreenUtil().setHeight(90),
                            ),
                          ),
                        ),
                        Padding(
                          padding:
                              EdgeInsets.only(left: ScreenUtil().setWidth(20)),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                topicComment.sender.nickname,
                                style: TextStyle(
                                    fontFamily: 'normal',
                                    fontWeight: FontWeight.w600,
                                    fontSize: ScreenUtil().setSp(30)),
                              ),
                              SizedBox(height: 4),
                              Text(
                                getTimeString(topicComment.time),
                                style: TextStyle(
                                    color: Colors.grey,
                                    fontFamily: 'normal',
                                    fontWeight: FontWeight.w200,
                                    fontSize: ScreenUtil().setSp(25)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ]),
              SizedBox(
                height: 15,
              ),
              contentPart(),
            ]));

    return child;
  }

  handleCollect() async {
    Navigator.pop(context);
    String showText = "";
    if (userProvider.isLogIn) {
      if (topicComment.isCollected == true) {
        showText = "已收藏";
      } else {
        var data = await apiClient.deleteCollection(
            modelId: topicComment.id, type: ApiClient.COMMENT);
        if (data['status'] == true) {
          showText = '收藏成功';
          topicComment.isCollected = true;
          // showText = '取消收藏失败';
        } else {
          showText = "收藏失败,请重试";
        }
      }
      Future.delayed(Duration(milliseconds: 500), () {
        BotToast.showText(
            text: showText,
            align: Alignment(0, 0.5),
            duration: Duration(milliseconds: 500));
      });

      setState(() {});
    }
  }

  handleDelete() async {
    if (userProvider.userInfo.id == topicComment.sender.id) {
      Navigator.pop(context);
      showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: Text("提示"),
            content: Text("确认要删除此此话题评论吗? "),
            actions: <Widget>[
              FlatButton(
                child: Text("取消"),
                onPressed: () => Navigator.of(context).pop(), // 关闭对话框
              ),
              FlatButton(
                  child: Text("删除"),
                  onPressed: () async {
                    // FinderDialog.showLoading();
                    var data = await apiClient.deleteTopicComment(
                        commentId: topicComment.id);
                    if (data['status']) {
                      Future.delayed(Duration(milliseconds: 500), () {
                        BotToast.showText(
                            text: "删除成功",
                            align: Alignment(0, 0.5),
                            duration: Duration(milliseconds: 500));
                        Navigator.pop(context);
                      });
                    }

                    Navigator.pop(context);
                  }),
            ],
          );
        },
      );
    }
  }

  buildLikeUserList() {
    Future getData() async {
      var data = await apiClient.getTopicCommentLikeUsers(
          topicCommentId: topicComment.id);
      FollowerModel likerModel = FollowerModel.fromJson(data, true);
      setState(() {
        this.liker.addAll(likerModel.data);
      });

      // print(jsonEncode(data));
      List<Sender> liker = [];
    }

    getData();

    List<Widget> widgets = [];

    this.liker.map((item) {
      Widget child = Container(
          padding: EdgeInsets.only(top: 10.0, left: 15.0, bottom: 5),
          child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ///头像
                GestureDetector(
                  onTap: () {
                    // Application.router.navigateTo(context,
                    //     "${Routes.userProfile}?senderId=${item.id.toString()}&heroTag=${item.id.toString() + widget.isFan.toString() + 'follower'}");
                  },
                  child: Hero(
                    tag: item.id.toString() + 'liker',
                    child: Avatar(
                      url: item.avatar,
                      avatarHeight: 40,
                    ),
                  ),
                )
              ]));

      widgets.add(child);
    });

    return ListView(children: widgets);
  }

  ///话题评论--内容部分
  Widget contentPart() {
    String content = topicComment.content;
    double picWidth = ScreenUtil().setWidth(220);
    bool isSinglePic = false;
    var json = jsonDecode(content);
    List imagesJson = json['images'];
    List<String> images = [];
    String text = json['text'];
    imagesJson.forEach((i) {
      images.add(Avatar.getImageUrl(i));
    });

    Widget child = Container(
      // color: Colors.amber,
      // height: ScreenUtil().setHeight(400),
      width: ScreenUtil().setWidth(750),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            text,
            // maxLines: 5,
            // overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontWeight: FontWeight.w500,
                fontFamily: 'normal',
                fontSize: ScreenUtil().setSp(30)),
          ),
          SizedBox(
            height: (text == "" || text == null) ? 0 : 10,
          ),
          Container(
            width: ScreenUtil().setWidth(680),
            // alignment: Alignment.center,
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
                    child: (isSinglePic)
                        ? _singlePic
                        : Container(
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

    return child;
  }
}

class StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar child;
  StickyTabBarDelegate({@required this.child});
  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(color: Colors.white, child: this.child);
  }

  @override
  double get maxExtent => this.child.preferredSize.height;
  @override
  double get minExtent => this.child.preferredSize.height;
  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}

class UserLikeWidget extends StatefulWidget {
  final int topicCommentId;
  final VoidCallback isLike;
  UserLikeWidget({this.topicCommentId, this.isLike});
  @override
  _UserLikeWidgetState createState() => _UserLikeWidgetState();
}

class _UserLikeWidgetState extends State<UserLikeWidget> {
  EasyRefreshController _refreshController;
  // ScrollController _controller;
  UserProvider userProvider;
  List<FollowerModelData> likers = [];
  bool isLoading = true;

  bool hasMore = true;

  int pageCount = 1;

  @override
  void initState() {
    // _controller = ScrollController();
    _refreshController = EasyRefreshController();
    getData(pageCount: pageCount);
    super.initState();
  }

  @override
  void dispose() {
    // _controller.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    userProvider = Provider.of<UserProvider>(context);

    return body;
  }

  Widget get body {
    Widget child;
    if (this.isLoading) {
      child = Container(
          alignment: Alignment.center,
          height: double.infinity,
          child: CupertinoActivityIndicator());
    } else {
      child = EasyRefresh.custom(
        enableControlFinishLoad: true,
        primary: true,
        footer: MaterialFooter(),
        controller: _refreshController,
        slivers: <Widget>[
          SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
            // index = index % this.follower.data.length;
            return buildUserRow(this.likers[index]);
          }, childCount: this.likers.length)),
        ],
        onLoad: () async {
          await Future.delayed(Duration(milliseconds: 500), () {
            getData(pageCount: this.pageCount);
          });
          _refreshController.finishLoad(success: true, noMore: (!this.hasMore));
        },
      );
      child = Stack(children: <Widget>[
        child,
        Positioned(
          bottom: 30,
          right: 20,
          child: MaterialButton(
              onPressed: () async {
                BotToast.showWidget(toastBuilder: (canl) {
                  Future.delayed(Duration(milliseconds: 700), () {
                    canl();
                  });
                  return Center(
                    child: Container(
                      child: Icon(
                        Icons.favorite,
                        size: 100,
                      ),
                    ),
                  );
                });
                this.widget.isLike();
              },
              shape: CircleBorder(),
              child: Icon(
                Icons.favorite,
                size: 40,
                color: Theme.of(context).primaryColor,
              )),
        )
      ]);
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

  buildUserRow(FollowerModelData item) {
    // print(item.nickname);
    Widget userRow = Container(
      padding: EdgeInsets.only(top: 10.0, left: 15.0, bottom: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ///头像
          GestureDetector(
            onTap: () {
              Application.router.navigateTo(context,
                  "${Routes.userProfile}?senderId=${item.id}&heroTag=${item.id.toString() + 'liker'}");
            },
            child: Hero(
              tag: item.id.toString() + 'liker',
              child: Avatar(
                url: item.avatar,
                avatarHeight: 40,
              ),
            ),
          ),

          ///名字/简介
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(left: 10.0),
                  child: Text(
                    item.nickname,
                    style: Theme.of(context)
                        .textTheme
                        .body1
                        .copyWith(fontSize: 15),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10.0, top: 5.0),
                  child: Text(
                    item.introduction != null ? item.introduction : "",
                    style: Theme.of(context).textTheme.body2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return userRow;
  }

  Future getData({int pageCount}) async {
    List<FollowerModelData> moreLikers = [];
    bool hasMore = true;
    int nowPageAt;

    ///如果是初始化状态
    if (this.likers.length == 0) {
      for (int i = 1; i <= pageCount; i++) {
        var data = await apiClient.getTopicCommentLikeUsers(
            topicCommentId: widget.topicCommentId, page: pageCount);
        // print(data);
        FollowerModel followerModel = FollowerModel.fromJson(data, true);
        hasMore = followerModel.hasMore;
        // print(hasMore);
        moreLikers.addAll(followerModel.data);
      }
      nowPageAt = pageCount + 1;
    } else {
      var data = await apiClient.getTopicCommentLikeUsers(
          topicCommentId: widget.topicCommentId, page: pageCount);
      // print(data);
      FollowerModel followerModel = FollowerModel.fromJson(data, true);
      hasMore = followerModel.hasMore;
      moreLikers.addAll(followerModel.data);
      nowPageAt = this.pageCount + 1;
    }

    if (!mounted) return;
    setState(() {
      this.isLoading = false;
      this.hasMore = hasMore;
      this.likers.addAll(moreLikers);
      this.pageCount = nowPageAt;
    });
  }
}
