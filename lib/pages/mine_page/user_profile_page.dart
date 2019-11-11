import 'package:finder/config/api_client.dart';
import 'package:finder/models/message_model.dart';
import 'package:finder/models/user_model.dart';
import 'package:finder/pages/mine_page/user_content_tabview.dart';
import 'package:finder/plugin/gradient_generator.dart';
import 'package:finder/provider/user_provider.dart';
import 'package:finder/routers/application.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:finder/public.dart';
import 'package:finder/plugin/my_appbar.dart';
import 'package:provider/provider.dart';

///用户信息详情页
class UserProfilePage extends StatefulWidget {
  final int senderId;
  final String heroTag;

  UserProfilePage({this.senderId, this.heroTag});

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  UserModel user;
  double topPartHeight = 200;
  var cards;
  ScrollController _scrollController;
  int userItSelfId;
  UserProvider userProvider;
  double appBarOpacity = 0;

  @override
  void initState() {
    getUserProfile();
    _scrollController = ScrollController()
      ..addListener(() {
        double offset = _scrollController.offset;
        // print("offset==>$offset");
        if (offset > 108 && offset < 160) {
          setState(() {
            appBarOpacity = (offset / 100) % 1;
          });
        } else if (offset > 160) {
          setState(() {
            appBarOpacity = 1;
          });
        } else if (offset < 60) {
          setState(() {
            appBarOpacity = 0;
          });
        }
        // print(scrollController.offset);
      });
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    setState(() {
      userItSelfId = userProvider.userInfo.id;
    });
//    print(widget.heroTag);
    return Scaffold(
      body: SafeArea(
        top: false,
        child: Container(
          child: MyAppBar(
            appbar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
            child: body,
          ),
        ),
      ),
    );
  }

  Widget get body {
    Widget child;
    if (this.user == null) {
      child = Container(
          alignment: Alignment.center,
          height: double.infinity,
          child: CupertinoActivityIndicator());
    } else {
      Widget userInfoCard = Container(
          alignment: Alignment.center,
          padding: EdgeInsets.only(bottom: 100, top: 80),
          child: Stack(
            fit: StackFit.loose,
            alignment: Alignment.topCenter,
            children: <Widget>[
              Container(padding: EdgeInsets.only(top: 50), child: userCard()),
              Positioned(
                top: 0,
                // left: 0,
                // top: topPartHeight * 1.5 - 40,
                child: avatar(),
              )
            ],
          ));

      child = CustomScrollView(
        controller: _scrollController,
        slivers: <Widget>[
          SliverPersistentHeader(
              floating: true,
              pinned: true,
              delegate: AppbarDelegate(
                  child: UserAppBar(
                title: Padding(
                  padding: EdgeInsets.only(top: 18.0),
                  child: Text(user.nickname,
                      style: TextStyle(
                          fontSize: 20,
                          color: Colors.black.withOpacity(appBarOpacity))),
                ),
                color: Colors.white.withOpacity(appBarOpacity),
              ))),
          SliverToBoxAdapter(
            child: userInfoCard,
          ),
          SliverPersistentHeader(
              pinned: true,
              // floating: true,
              delegate: StickyTabBarDelegate(
                  child: PreferredSize(
                preferredSize: Size.fromHeight(ScreenUtil.screenHeightDp),
                child: Stack(
                  children: <Widget>[
                    TabView(userId: user.id),
                    Listener(
                      onPointerDown: (detail) {
                        setState(() {});
                      },
                      onPointerMove: (detail) {},
                      onPointerUp: (detail) {},
                      behavior: HitTestBehavior.translucent,
                      child: Container(
                        height: ScreenUtil.screenHeightDp,
                        width: ScreenUtil.screenWidthDp,
                      ),
                    )
                  ],
                ),
              )))
        ],
      );

      child = Stack(
        alignment: Alignment.topCenter,
        fit: StackFit.expand,
        children: <Widget>[buildBackground(), child],
      );
    }

    return AnimatedSwitcher(
        duration: Duration(milliseconds: 600),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
              child: child,
              opacity:
                  CurvedAnimation(curve: Curves.easeInOut, parent: animation));
        },
        child: child);
  }

  avatar() => Hero(
        tag: widget.heroTag,
        child: Container(
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      fullscreenDialog: true,
                      builder: (_) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            constraints: BoxConstraints.expand(height: 500),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                CachedNetworkImage(imageUrl: this.user.avatar),
                              ],
                            ),
                          ),
                        );
                      }));
            },
            child: Container(
              // margin: EdgeInsets.only(top: ScreenUtil().setHeight(0)),
              height: 90,
              width: 90,
              decoration: BoxDecoration(
                  // shape: CircleBorder(),
                  border: Border.all(color: Colors.white, width: 3),
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  image: DecorationImage(
                      image: CachedNetworkImageProvider(user.avatar))),
            ),
          ),
        ),
      );

  followButton() {
    Widget child = Text(user.isFollowed ? '已关注' : '关注',
        style:
            TextStyle(color: user.isFollowed ? Colors.black38 : Colors.white));

    child = MaterialButton(
      key: ValueKey(user.isFollowed),
      onPressed: () async {
        user.isFollowed = !user.isFollowed;
        user.fanCount = user.isFollowed ? user.fanCount + 1 : user.fanCount - 1;
        var data = await userProvider.addFollower(userId: user.id);
        // print(data);
        setState(() {});
      },
      elevation: user.isFollowed ? 0 : 2,
      shape: user.isFollowed
          ? StadiumBorder(side: BorderSide(color: Colors.white10))
          : StadiumBorder(),
      color: user.isFollowed ? Colors.white24 : Theme.of(context).primaryColor,
      child: child,
    );
    child = AnimatedSwitcher(
      switchInCurve: Curves.easeIn,
      switchOutCurve: Curves.easeOut,
      duration: Duration(milliseconds: 200),
      child: child,
    );

    return child;
  }

  buildBackground() {
    double cardWidth = 130;

    Widget getCard(item) => Card(
          color: Colors.white,
          elevation: 5,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Container(
            alignment: Alignment.center,
            height: cardWidth,
            width: cardWidth * 2,
            child: Text(item['name']),
          ),
        );

    List<Widget> content = [];
    List<Color> backGroundColor = this.user.backGround != null
        ? this.user.backGround
        : [Theme.of(context).primaryColor];

    Widget backGround = Container(
      key: ValueKey((this.user.backGround == null)),
      height: ScreenUtil.screenHeightDp,
      decoration: BoxDecoration(
          gradient: GradientGenerator.linear(backGroundColor.first,
              begin: Alignment.bottomLeft, end: Alignment.topRight)),
    );
    backGround = AnimatedSwitcher(
      switchInCurve: Curves.easeIn,
      switchOutCurve: Curves.easeOut,
      duration: Duration(milliseconds: 3000),
      child: backGround,
    );

    backGround = Opacity(
      child: backGround,
      opacity: 1,
    );

    // user.backGround.forEach((item) {
    //   content.add(Container(
    //     color: item,
    //     height: 20,
    //   ));
    // });

    // content.add(backGround);
    // content.add(Container(
    //   alignment: Alignment.center,
    //   padding: EdgeInsets.only(top: cardWidth + 10),
    //   child: Wrap(
    //     spacing: 12,
    //     runSpacing: 14,
    //     children: <Widget>[
    //       // getCard(cards['topic']),
    //       // getCard(cards['activity']),
    //       // getCard(cards['toHeSay']),
    //       // getCard(cards['message'])
    //     ],
    //   ),
    // ));

    return Stack(
      children: <Widget>[
        backGround,
        ListView(
          padding: EdgeInsets.all(0),
          children: content,
        )
      ],
    );
  }

  Widget userCard() {
    return Card(
        margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(100)),
        color: Colors.white,
        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: EdgeInsets.only(bottom: 15, top: 50),
          width: ScreenUtil().setWidth(750),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient:
                  GradientGenerator.linear(Theme.of(context).primaryColor)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              ///昵称
              Text(
                user.nickname,
                style: TextStyle(color: Colors.black, fontSize: 20),
              ),

              ///学校专业
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text((user.school != null) ? user.school.name : "家里蹲大学"),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 5),
                    height: 14,
                    width: 1,
                    color: Theme.of(context).primaryColor,
                  ),
                  Text((user.major != null) ? user.major : ""),
                ],
              ),

              Container(
                  padding: EdgeInsets.symmetric(vertical: 5),
                  child: Text((user.introduction != null)
                      ? "简介：" + user.introduction
                      : "简介：")),

              ///关注
              Container(
                // color: Colors.amber,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    MaterialButton(
                      onPressed: () {
                        Application.router.navigateTo(context,
                            "${Routes.fansFollowPage}?userId=${user.id.toString()}&isFollow=true");
                      },
                      shape: RoundedRectangleBorder(),
                      child: Column(
                        children: <Widget>[
                          Text(user.followCount.toString()),
                          Text('关注')
                        ],
                      ),
                    ),
                    MaterialButton(
                      onPressed: () {
                        Application.router.navigateTo(context,
                            "${Routes.fansFollowPage}?userId=${user.id.toString()}&isFollow=false");
                      },
                      shape: RoundedRectangleBorder(),
                      child: Column(
                        children: <Widget>[
                          Text(user.fanCount.toString()),
                          Text('粉丝')
                        ],
                      ),
                    )
                  ],
                ),
              ),

              ///私信 和关注 按钮
              (user.id == userItSelfId)
                  ? Container()
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                          followButton(),
                          MaterialButton(
                            onPressed: () {
                              Navigator.of(context).pushNamed(Routes.chat,
                                  arguments:
                                      UserProfile.fromJson(user.toJson()));
                            },
                            elevation: 1,
                            shape: StadiumBorder(),
                            color: Theme.of(context).primaryColor,
                            child: Text("私信TA",
                                style: TextStyle(color: Colors.black)),
                          )
                        ])
            ],
          ),
        ));
  }

  getUserProfile() async {
    var data = await apiClient.getOtherProfile(userId: widget.senderId);
    // print(data);
    UserModel userModel = UserModel.fromJson(data['data']);
    if (!mounted) return;

    this.user = userModel;

    imageToColors(userModel.avatar).then((val) {
      setState(() {
        this.user.backGround = val;
      });
    });

    setState(() {});
  }
}

class StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final PreferredSizeWidget child;
  final Color color;
  StickyTabBarDelegate({@required this.child, this.color});
  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    var border = BorderSide(color: Colors.black12, width: 0.5);
    return Container(
      height: this.child.preferredSize.height,
      // alignment: Alignment.center,
      child: this.child,
      // margin: EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: border, bottom: border),
      ),
    );
    // return child;
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

class AppbarDelegate extends SliverPersistentHeaderDelegate {
  final PreferredSizeWidget child;
  AppbarDelegate({@required this.child});
  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(color: Colors.transparent, child: this.child);
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

class UserAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget title;
  final Color color;
  UserAppBar({this.title, this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      alignment: Alignment.center,
      height: kToolbarHeight + ScreenUtil.statusBarHeight - 10,
      child: title,
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + ScreenUtil.statusBarHeight - 10);
}
