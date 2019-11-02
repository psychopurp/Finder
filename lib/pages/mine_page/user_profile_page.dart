import 'package:finder/config/api_client.dart';
import 'package:finder/models/message_model.dart';
import 'package:finder/models/user_model.dart';
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

  @override
  void initState() {
    getUserProfile();
    _scrollController = ScrollController();
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
      floatingActionButton: userItSelfId == user?.id
          ? null
          : FloatingActionButton(
              child: Text("私信"),
              elevation: 1,
              onPressed: () {
                Navigator.of(context).pushNamed(Routes.chat,
                    arguments: UserProfile.fromJson(user.toJson()));
              },
              backgroundColor: Theme.of(context).primaryColor,
            ),
      body: SafeArea(
        top: false,
        child: Container(
          child: MyAppBar(
            appbar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
            child: body(userProvider),
          ),
        ),
      ),
    );
  }

  Widget body(UserProvider userProvider) {
    Widget child;
    if (this.user == null) {
      child = Container(
          alignment: Alignment.center,
          height: double.infinity,
          child: CupertinoActivityIndicator());
    } else {
      child = Stack(
        alignment: Alignment.topCenter,
        fit: StackFit.expand,
        children: <Widget>[
          buildBackground(),
          Positioned(
              left: 0,
              right: 0,
              top: topPartHeight * 1.2,
              child: userCard(user, userProvider)),
          Positioned(
            // left: ScreenUtil().setWidth(0),
            right: ScreenUtil.screenWidthDp / 2 - 45,
            top: topPartHeight * 1.2 - 40,
            child: avatar(),
          ),
          // Positioned(
          //   left: ScreenUtil.screenWidthDp / 2 + 50,
          //   top: topPartHeight * 0.5,
          //   child: followButton(),
          // )
        ],
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
      );

  followButton(UserProvider userProvider) {
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

    Widget backGround = Container(
      height: ScreenUtil.screenHeightDp,
      decoration: BoxDecoration(
          gradient: GradientGenerator.linear(user.backGround.first,
              begin: Alignment.bottomLeft, end: Alignment.topRight)),
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

  Widget userCard(UserModel user, UserProvider userProvider) {
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
                  child: Text("简介：" + user.introduction ?? "")),

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
              (user.id == userItSelfId)
                  ? Container()
                  : followButton(userProvider),
            ],
          ),
        ));
  }

  getUserProfile() async {
    var data = await apiClient.getOtherProfile(userId: widget.senderId);
    // print(data);
    UserModel userModel = UserModel.fromJson(data['data']);

    userModel.backGround = await imageToColors(userModel.avatar);
    if (!mounted) return;
    setState(() {
      this.user = userModel;
    });
  }
}
