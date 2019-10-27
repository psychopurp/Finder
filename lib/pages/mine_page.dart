import 'package:finder/config/api_client.dart';
import 'package:finder/config/global.dart';
import 'package:finder/models/user_model.dart';
import 'package:finder/plugin/my_appbar.dart';
import 'package:finder/public.dart';
import 'package:finder/routers/application.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:finder/provider/user_provider.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:provider/provider.dart';
import 'package:finder/pages/mine_page/mine_page_top.dart';
import 'package:finder/pages/mine_page/mine_page_bottom.dart';

class MinePage extends StatefulWidget {
  @override
  _MinePageState createState() => _MinePageState();
}

class _MinePageState extends State<MinePage> {
  Color backGroundColor = Colors.grey;
  double topPartHeight = 150;
  var cards;

  @override
  void initState() {
    cards = {
      'topic': {'name': '话题'},
      'activity': {'name': '活动'},
      'toHeSay': {'name': '表白Ta'},
      'message': {'name': '私信Ta'}
    };
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<UserProvider>(builder: (context, user, child) {
        var avatar = GestureDetector(
          onTap: () {
            BotToast.showText(
                text: 'elyar', duration: Duration(milliseconds: 500));
          },
          child: Hero(
            tag: 'profile',
            child: Container(
              // margin: EdgeInsets.only(top: ScreenUtil().setHeight(0)),
              height: 90,
              width: 90,
              decoration: BoxDecoration(
                  // shape: CircleBorder(),
                  border: Border.all(color: Colors.white, width: 3),
                  borderRadius: BorderRadius.all(Radius.circular(50)),
                  image: DecorationImage(
                      image: CachedNetworkImageProvider(user.userInfo.avatar))),
            ),
          ),
        );
        print(user.collection);
        return SafeArea(
          top: false,
          child: Container(
            child: MyAppBar(
              appbar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
              child: Stack(
                alignment: Alignment.topCenter,
                fit: StackFit.expand,
                children: <Widget>[
                  ListView(
                      padding: EdgeInsets.all(0),
                      children: buildBackground(user.userInfo)),
                  Positioned(
                      left: 0,
                      right: 0,
                      top: topPartHeight * 0.5,
                      child: userCard(user.userInfo)),
                  Positioned(
                    // left: ScreenUtil().setWidth(0),
                    // right: 0,
                    top: topPartHeight * 0.5 - 40,
                    child: avatar,
                  )
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  buildBackground(UserModel user) {
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

    Widget topPart = Container(
      height: topPartHeight,
      decoration: BoxDecoration(color: Theme.of(context).primaryColor),
    );

    content.add(topPart);
    content.add(Container(
      alignment: Alignment.center,
      padding: EdgeInsets.only(top: cardWidth + 10),
      child: Wrap(
        spacing: 12,
        runSpacing: 14,
        children: <Widget>[
          getCard(cards['topic']),
          getCard(cards['activity']),
          // getCard(cards['toHeSay']),
          // getCard(cards['message'])
        ],
      ),
    ));

    return content;
  }

  Widget buildUserBackground(UserModel user, BuildContext context) {
    return Container(
      height: ScreenUtil().setHeight(650),
      decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30))),
      child: DefaultTextStyle(
        style: TextStyle(fontSize: ScreenUtil().setSp(40)),
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: kToolbarHeight),
              child: userCard(user),
            ),
            Padding(
              padding: EdgeInsets.only(left: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(top: 6.0),
                    child: Text(user.nickname),
                  ),
                  IconButton(
                    splashColor: Colors.white,
                    onPressed: () {
                      print("asfasf");
                    },
                    icon: Icon(
                      IconData(0xe845, fontFamily: 'myIcon'),
                      size: ScreenUtil().setSp(50),
                      color: Color(0xffDDDDDD),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              user?.school?.name ?? "家里蹲大学",
              style: TextStyle(fontSize: 16),
            ),
            Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: Text(
                user.introduction,
                style: TextStyle(color: Colors.black38),
              ),
            ),
            Row(
                // children: <Widget>[Text(user)],
                )
            // Text(user.)
          ],
        ),
      ),
    );
  }

  Widget userCard(UserModel user) {
    return Card(
        margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(100)),
        color: Colors.white,
        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Container(
          padding: EdgeInsets.only(bottom: 50, top: 50),
          width: ScreenUtil().setWidth(750),
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
                  Text(user.school.name),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 5),
                    height: 14,
                    width: 1,
                    color: Theme.of(context).primaryColor,
                  ),
                  Text((user.major != null) ? user.major : "")
                ],
              ),

              ///关注
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  MaterialButton(
                    onPressed: () {
                      Application.router.navigateTo(context,
                          "${Routes.fansFollowPage}?userId=${user.id.toString()}&isFollow=true");
                    },
                    shape: RoundedRectangleBorder(),
                    child: Column(
                      children: <Widget>[Text('关注')],
                    ),
                  ),
                  MaterialButton(
                    onPressed: () {
                      Application.router.navigateTo(context,
                          "${Routes.fansFollowPage}?userId=${user.id.toString()}&isFollow=false");
                    },
                    shape: RoundedRectangleBorder(),
                    child: Column(
                      children: <Widget>[Text('粉丝')],
                    ),
                  )
                ],
              )
            ],
          ),
        ));
  }
}
