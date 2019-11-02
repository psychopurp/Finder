import 'package:finder/config/api_client.dart';
import 'package:finder/models/follower_model.dart';
import 'package:finder/provider/user_provider.dart';
import 'package:finder/public.dart';
import 'package:finder/routers/application.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_easyrefresh/material_footer.dart';
import 'package:flutter_easyrefresh/material_header.dart';
import 'package:provider/provider.dart';

class FansFollowPage extends StatefulWidget {
  final int userId;
  final bool isFan;
  FansFollowPage({this.userId, this.isFan});

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
        vsync: this, initialIndex: widget.isFan ? 1 : 0, length: 2);
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
          indicatorWeight: 2,
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
            isFan: false,
          ),
          TabBody(
            userId: widget.userId,
            isFan: true,
          )
        ],
      ),
    );
  }
}

class TabBody extends StatefulWidget {
  final int userId;
  final bool isFan;
  TabBody({this.userId, this.isFan});
  @override
  _TabBodyState createState() => _TabBodyState();
}

class _TabBodyState extends State<TabBody> {
  FollowerModel follower;
  EasyRefreshController _refreshController;
  ScrollController _controller;
  UserProvider userProvider;
  List<FollowerModelData> followers = [];

  int userItSelfId;
  bool hasMore = true;
  bool isLoading = true;

  static const int FOLLOW = 0;
  static const int BOTHFOLLOW = 1;
  static const int FOLLOWED = 2;

  int pageCount = 1;

  @override
  void initState() {
    _controller = ScrollController();
    _refreshController = EasyRefreshController();
    getData(pageCount: pageCount);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    userProvider = Provider.of<UserProvider>(context);

    setState(() {
      userItSelfId = userProvider.userInfo.id;
    });
    return body();
  }

  Widget body() {
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
        header: MaterialHeader(),
        footer: MaterialFooter(),
        controller: _refreshController,
        slivers: <Widget>[
          SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
            // index = index % this.follower.data.length;
            return buildUserRow(this.followers[index]);
          }, childCount: this.followers.length)),
        ],
        onRefresh: () async {
          this.followers = [];
          await getData(pageCount: 1);
          _refreshController.resetLoadState();
        },
        onLoad: () async {
          await Future.delayed(Duration(milliseconds: 500), () {
            getData(pageCount: this.pageCount);
          });

          _refreshController.finishLoad(success: true, noMore: (!this.hasMore));
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
                  "${Routes.userProfile}?senderId=${item.id.toString()}&heroTag=${item.id.toString() + widget.isFan.toString() + 'follower'}");
            },
            child: Hero(
              tag: item.id.toString() + widget.isFan.toString() + 'follower',
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

          ///关注按钮
          Container(
              height: 40,
              // color: Colors.amber,
              alignment: Alignment.center,
              padding: EdgeInsets.only(right: 10),
              child: (item.id == userItSelfId) ? Container() : getButton(item))
        ],
      ),
    );

    return userRow;
  }

  getButton(FollowerModelData userInfo) {
    String buttonText = "";
    if (userInfo.status == FOLLOW) {
      buttonText = "关注";
    } else if (userInfo.status == FOLLOWED) {
      buttonText = "已关注";
    } else if (userInfo.status == BOTHFOLLOW) {
      buttonText = "相互关注";
    }

    return GestureDetector(
      onTap: () async {
        // handleFollow(user, userInfo);
        var data = await userProvider.addFollower(userId: userInfo.id);
        print(data);
        if (!widget.isFan) {
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
          if (userInfo.status == BOTHFOLLOW) {
            userInfo.status = FOLLOW;
          } else {
            userInfo.status = BOTHFOLLOW;
          }
        }
        setState(() {});
      },
      child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
              border: Border.all(
                  color: (userInfo.status == FOLLOW)
                      ? Theme.of(context).primaryColor
                      : Colors.black12),
              borderRadius: BorderRadius.circular(30)),
          height: 30,
          child: Text(
            buttonText,
            style: TextStyle(
                color: (userInfo.status == FOLLOW)
                    ? Theme.of(context).primaryColor
                    : Colors.black45),
          )),
    );
  }

  Future getData({int pageCount}) async {
    List<FollowerModelData> moreFollowers = [];
    bool hasMore = true;
    int nowPageAt;

    ///如果是初始化状态
    if (this.followers.length == 0) {
      for (int i = 1; i <= pageCount; i++) {
        var data = await apiClient.getFollowers(
            page: i, userId: widget.userId, isFan: widget.isFan);
        // print(data);
        FollowerModel followerModel =
            FollowerModel.fromJson(data, widget.isFan);
        hasMore = followerModel.hasMore;
        print(hasMore);
        moreFollowers.addAll(followerModel.data);
      }
      nowPageAt = pageCount + 1;
    } else {
      var data = await apiClient.getFollowers(
          page: pageCount, userId: widget.userId, isFan: widget.isFan);
      // print(data);
      FollowerModel followerModel = FollowerModel.fromJson(data, widget.isFan);
      hasMore = followerModel.hasMore;
      moreFollowers.addAll(followerModel.data);
      nowPageAt = this.pageCount + 1;
    }

    if (!mounted) return;
    setState(() {
      this.isLoading = false;
      this.hasMore = hasMore;
      this.followers.addAll(moreFollowers);
      this.pageCount = nowPageAt;
    });
  }
}
