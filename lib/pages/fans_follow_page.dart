import 'dart:convert';

import 'package:finder/config/api_client.dart';
import 'package:finder/models/follower_model.dart';
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
    _tabController = TabController(
        vsync: this, initialIndex: widget.isFollow ? 0 : 1, length: 2);
    super.initState();
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
          labelColor: Colors.black,
          indicatorWeight: 1,
          indicatorColor: Theme.of(context).primaryColor,
          controller: _tabController,
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
  EasyRefreshController _refreshController;
  FollowerModel follower;

  static const int FOLLOW = 0;
  static const int BOTHFOLLOW = 1;
  static const int FOLLOWED = 2;

  var followButton;

  @override
  void initState() {
    followButton = {};

    getInitialData();
    _refreshController = EasyRefreshController();
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
    return EasyRefresh(
      enableControlFinishLoad: true,
      header: MaterialHeader(),
      footer: MaterialFooter(),
      controller: _refreshController,
      onRefresh: () async {
        await getInitialData();
        _refreshController.resetLoadState();
      },
      // onLoad: () async {
      //   var data = await getMore(this.pageCount);
      //   print("data===$data");
      //   _refreshController.finishLoad(
      //       success: true, noMore: (data.length == 0));
      // },
      child: (this.follower != null)
          ? ListView(
              // controller: _controller,
              padding: EdgeInsets.only(bottom: 20),
              children: buildUserList(user))
          : Container(
              height: 400,
              child: CupertinoActivityIndicator(),
            ),
    );
  }

  handleFollow(UserProvider user, FollowerModelData userInfo) async {
    if (user.isLogIn) {
      /// 关注页
      if (widget.isFollow) {
        // if(userInfo.isBothFollowed)

      }
      var data = await apiClient.addFollowUser(userId: userInfo.id);
      print(data);
    } else {
      //TODO 处理未登录
    }
  }

  buildUserList(UserProvider user) {
    List<Widget> content = [];
    this.follower.data.forEach((item) {
      Widget userRow = Container(
        padding: EdgeInsets.only(top: 10.0, left: 15.0, bottom: 5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            GestureDetector(
              onTap: () {
                Application.router.navigateTo(context,
                    "${Routes.userProfile}?senderId=${item.id.toString()}");
              },
              child: Avatar(
                url: item.avatar,
                avatarHeight: 40,
              ),
            ),
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
            Container(
                height: 40,
                // color: Colors.amber,
                alignment: Alignment.center,
                padding: EdgeInsets.only(right: 10),
                child: getButton(item.status, user, item))
          ],
        ),
      );

      content.add(userRow);
    });

    return content;
  }

  getButton(int typeId, UserProvider user, FollowerModelData userInfo) {
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
    print(data);
    print(!widget.isFollow);
    print(widget.userId);
    FollowerModel followerModel = FollowerModel.fromJson(data, widget.isFollow);

    if (!mounted) return;
    setState(() {
      this.follower = followerModel;
    });
  }
}
