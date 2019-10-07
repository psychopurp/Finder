import 'package:finder/config/api_client.dart';
import 'package:finder/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:finder/public.dart';
import 'package:provider/provider.dart';
import 'package:finder/provider/user_provider.dart';
import 'package:finder/plugin/my_appbar.dart';

class UserProfilePage extends StatefulWidget {
  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  @override
  Widget build(BuildContext context) {
    apiClient.getFollowUsers();
    apiClient.getCollections(page: 1, query: "");
    apiClient.getFanUsers();
    return Scaffold(
      body: Consumer<UserProvider>(builder: (context, user, child) {
        return SafeArea(
          top: false,
          child: Container(
            child: MyAppBar(
              appbar: AppBar(
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

  Container buildUserBackground(UserModel user, BuildContext context) {
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

  _backGround(UserModel user) {
    return Container(
      height: ScreenUtil().setHeight(800),
      color: Colors.cyan,
      child: Stack(
        alignment: Alignment.topCenter,
        children: <Widget>[
          ClipPath(
            clipBehavior: Clip.hardEdge,
            clipper: BackGroundClipper(),
            child: Container(
              color: Theme.of(context).primaryColor,
              height: ScreenUtil().setHeight(700),
              width: ScreenUtil().setWidth(750),
            ),
          ),
          Container(
              // margin: EdgeInsets.only(top: 100),
              child: CircleAvatar(
            radius: 50,
            backgroundImage: CachedNetworkImageProvider(user.avatar),
          )),
        ],
      ),
    );
  }

  Widget _userAvatar(UserModel user) {
    return Align(
      alignment: Alignment.topCenter,
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
    );
  }
}

class BackGroundClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    print(size);
    var path = Path();
    path.lineTo(0.0, size.height);
    path.lineTo(size.width, 3 * size.height / 4);
    path.lineTo(size.width, 0.0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
