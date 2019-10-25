import 'package:finder/config/api_client.dart';
import 'package:finder/models/user_model.dart';
import 'package:finder/plugin/my_appbar.dart';
import 'package:finder/public.dart';
import 'package:flutter/material.dart';

import 'package:finder/provider/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:finder/pages/mine_page/mine_page_top.dart';
import 'package:finder/pages/mine_page/mine_page_bottom.dart';

class MinePage extends StatefulWidget {
  @override
  _MinePageState createState() => _MinePageState();
}

class _MinePageState extends State<MinePage> {
  @override
  Widget build(BuildContext context) {
    apiClient.getFollowUsers();
    apiClient.getCollections(page: 1);
    apiClient.getFanUsers();
    return Scaffold(
      body: Consumer<UserProvider>(builder: (context, user, child) {
        print(user.collection);
        return SafeArea(
          top: false,
          child: Container(
            child: MyAppBar(
              appbar: AppBar(
                title: Text('mine page'),
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
              child: ListView(
                padding: EdgeInsets.all(0),
                children: <Widget>[
                  buildUserBackground(user.userInfo, context),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        _singleButtonItem(
                            Icon(
                              IconData(0xe6e0, fontFamily: 'myIcon'),
                              color: Colors.black,
                            ),
                            '收藏',
                            '收藏'),
                        // VerticalDivider(),
                        _singleButtonItem(
                            Icon(
                              IconData(0xe879, fontFamily: 'myIcon'),
                              color: Colors.black,
                            ),
                            '小F',
                            '收藏'),
                        _singleButtonItem(
                            Icon(
                              IconData(0xe654, fontFamily: 'myIcon'),
                              color: Colors.black,
                            ),
                            '设置',
                            '评论'),
                        _singleButtonItem(
                            Icon(
                              IconData(0xe879, fontFamily: 'myIcon'),
                              color: Colors.black,
                            ),
                            '消息',
                            '点赞'),
                      ],
                    ),
                  ),
                  // buildUserBackground(user.userInfo, context),
                  // buildUserBackground(user.userInfo, context),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  _singleButtonItem(Icon icon, String count, item) {
    // Color myColor = Colors.white;
    // switch (item) {
    //   case '收藏':
    //     myColor = Colors.amber;
    //     print('sho');
    //     break;
    //   case '评论':
    //     myColor = Colors.cyan;
    //     print('ping');
    //     break;
    //   case '点赞':
    //     myColor = Colors.deepPurple;
    //     break;
    //   default:
    //     myColor = Colors.blue;
    // }

    return Material(
      color: Colors.white,
      child: InkWell(
        // hoverColor: Colors.black,
        // focusColor: Colors.amber,
        // highlightColor: Colors.blue,
        // splashColor: Colors.amber,
        onTap: () {
          print('object');
        },
        child: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(vertical: ScreenUtil().setHeight(30)),
          // color: myColor,
          width: ScreenUtil().setWidth(187.5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              icon,
              Text(count),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildUserBackground(UserModel user, BuildContext context) {
    return Container(
      height: ScreenUtil().setHeight(650),
      width: ScreenUtil().setWidth(750),
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
              child: _userAvatar(user),
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
                      color: Colors.black38,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              user.school.name,
              style: TextStyle(fontSize: ScreenUtil().setSp(35)),
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

  Widget _userAvatar(UserModel user) {
    return Align(
        alignment: Alignment.topCenter,
        child: Hero(
          tag: 'profile',
          child: Container(
            // margin: EdgeInsets.only(top: ScreenUtil().setHeight(0)),
            height: ScreenUtil().setHeight(200),
            width: ScreenUtil().setWidth(200),
            decoration: BoxDecoration(
                // shape: CircleBorder(),
                border: Border.all(color: Colors.white, width: 3),
                borderRadius: BorderRadius.all(Radius.circular(50)),
                image: DecorationImage(
                    image: CachedNetworkImageProvider(user.avatar))),
          ),
        ));
  }
}
