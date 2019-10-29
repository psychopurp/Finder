import 'dart:convert';

import 'package:finder/config/api_client.dart';
import 'package:finder/models/follower_model.dart';
import 'package:finder/models/user_model.dart';
import 'package:finder/provider/user_provider.dart';
import 'package:finder/public.dart';
import 'package:finder/routers/application.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_easyrefresh/material_footer.dart';
import 'package:flutter_easyrefresh/material_header.dart';
import 'package:provider/provider.dart';

class FansFollowPage extends StatefulWidget {
  final int userId;
  final bool isFollow;
  FansFollowPage({this.userId, this.isFollow});

  @override
  _FansFollowPageState createState() => _FansFollowPageState();
}

class _FansFollowPageState extends State<FansFollowPage>
    with SingleTickerProviderStateMixin {
  TabController _tabController;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(
        vsync: this, initialIndex: widget.isFollow ? 0 : 1, length: 2);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("圈子"),
        textTheme: TextTheme(
            title: Theme.of(context)
                .appBarTheme
                .textTheme
                .title
                .copyWith(color: Colors.black)),
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        centerTitle: true,
        bottom: TabBar(
          isScrollable: true,
          labelColor: Colors.black,
          indicatorWeight: 3,
          indicatorColor: Theme.of(context).primaryColor,
          controller: _tabController,
          labelPadding: EdgeInsets.symmetric(horizontal: 30),
          labelStyle: TextStyle(fontSize: 16),
          tabs: <Widget>[
            Tab(
              text: "关注",
            ),
            Tab(
              text: "粉丝",
            )
          ],
        ),
      ),
      body: TabBarView(
        physics: PageScrollPhysics(),
        controller: _tabController,
        children: <Widget>[
          TabBody(
            userId: widget.userId,
            isFollow: true,
          ),
          TabBody(
            userId: widget.userId,
            isFollow: false,
          )
        ],
      ),
    );
  }
}

class TabBody extends StatefulWidget {
  final int userId;
  final bool isFollow;
  TabBody({this.userId, this.isFollow});
  @override
  _TabBodyState createState() => _TabBodyState();
}

class _TabBodyState extends State<TabBody> {
  FollowerModel follower;
  EasyRefreshController _refreshController;
  ScrollController _controller;

  static const int FOLLOW = 0;
  static const int BOTHFOLLOW = 1;
  static const int FOLLOWED = 2;

  int pageCount = 2;
  int userItSelfId;

  @override
  void initState() {
    _controller = ScrollController();
    _refreshController = EasyRefreshController();
    getInitialData();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    _refreshController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context);
    setState(() {
      userItSelfId = user.userInfo.id;
    });
    return body;
  }

  Widget get body {
    Widget child;
    if (this.follower == null) {
      child = Container(
          alignment: Alignment.center,
          height: double.infinity,
          child: CupertinoActivityIndicator());
    } else {
      child = EasyRefresh(
        enableControlFinishLoad: true,
        header: MaterialHeader(),
        footer: MaterialFooter(),
        key: ValueKey(child),
        controller: _refreshController,
        child: ListView(children: buildUserList()),
        onRefresh: () async {
          await getInitialData();
          _refreshController.resetLoadState();
        },
        onLoad: () async {
          var data = await getMore(pageCount: this.pageCount);
          await Future.delayed(Duration(seconds: 2), () {});
          print("data===$data");
          _refreshController.finishLoad(
              success: true, noMore: (data.length == 0));
        },
      );
    }

    return AnimatedSwitcher(
        duration: Duration(milliseconds: 1000),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
              child: child,
              opacity:
                  CurvedAnimation(curve: Curves.easeInOut, parent: animation));
        },
        child: child);
  }

  buildUserList() {
    List<Widget> content = [];
    this.follower.data.forEach((item) {
      Widget userRow = Container(
        padding: EdgeInsets.only(top: 10.0, left: 15.0, bottom: 5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ///头像
            GestureDetector(
              onTap: () {
                Application.router.navigateTo(context,
                    "${Routes.userProfile}?senderId=${item.id.toString()}&heroTag=${item.id.toString() + widget.isFollow.toString() + 'follower'}");
              },
              child: Hero(
                tag: item.id.toString() +
                    widget.isFollow.toString() +
                    'follower',
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
                      item.introduction,
                      style: Theme.of(context).textTheme.body2,
                    ),
                  ),
                ],
              ),
            ),

            ///关注按钮
            Container(
                height: 40,
                // color: Colors.amber,
                alignment: Alignment.center,
                padding: EdgeInsets.only(right: 10),
                child: (item.id == userItSelfId)
                    ? Container()
                    : getButton(item.status, item))
          ],
        ),
      );

      content.add(userRow);
    });

    return content;
  }

  getButton(int typeId, FollowerModelData userInfo) {
    String buttonText = "";
    if (typeId == FOLLOW) {
      buttonText = "关注";
    } else if (typeId == FOLLOWED) {
      buttonText = "已关注";
    } else if (typeId == BOTHFOLLOW) {
      buttonText = "相互关注";
    }

    return GestureDetector(
      onTap: () async {
        // handleFollow(user, userInfo);
        var data = await apiClient.addFollowUser(userId: userInfo.id);
        print(data);
        if (widget.isFollow) {
          //本来是相互关注
          if (userInfo.isBothFollowed) {
            if (userInfo.status == BOTHFOLLOW) {
              userInfo.status = FOLLOW;
            } else {
              userInfo.status = BOTHFOLLOW;
            }
          } else {
            //本来不是相互关注
            if (userInfo.status == FOLLOWED) {
              userInfo.status = FOLLOW;
            } else {
              userInfo.status = FOLLOWED;
            }
          }
        } else {
          //本来是相互关注
          if (userInfo.isBothFollowed) {
            if (userInfo.status == BOTHFOLLOW) {
              userInfo.status = FOLLOW;
            } else {
              userInfo.status = BOTHFOLLOW;
            }
          } else {
            //本来不是相互关注
            if (userInfo.status == FOLLOW) {
              userInfo.status = BOTHFOLLOW;
            } else {
              userInfo.status = FOLLOWED;
            }
          }
        }
        setState(() {});
      },
      child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
              border: Border.all(
                  color: (typeId == FOLLOW)
                      ? Theme.of(context).primaryColor
                      : Colors.black12),
              borderRadius: BorderRadius.circular(30)),
          height: 30,
          child: Text(
            buttonText,
            style: TextStyle(
                color: (typeId == FOLLOW)
                    ? Theme.of(context).primaryColor
                    : Colors.black45),
          )),
    );
  }

  Future getInitialData() async {
    var data = await apiClient.getFollowers(
        userId: widget.userId, isFan: !widget.isFollow);

    FollowerModel followerModel = FollowerModel.fromJson(data, widget.isFollow);

    if (!mounted) return;
    setState(() {
      this.follower = followerModel;
      this.pageCount = 2;
    });
  }

  Future getMore({int pageCount}) async {
    var data = await apiClient.getFollowers(
        page: pageCount, userId: widget.userId, isFan: !widget.isFollow);

    FollowerModel followerModel = FollowerModel.fromJson(data, widget.isFollow);

    setState(() {
      this.follower.data.addAll(followerModel.data);
      this.pageCount++;
    });
    return followerModel.data;
  }
}
