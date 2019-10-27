import 'package:finder/config/api_client.dart';
import 'package:finder/models/topic_comments_model.dart';
import 'package:finder/models/user_model.dart';
import 'package:finder/plugin/avatar.dart';
import 'package:flutter/material.dart';
import 'package:finder/public.dart';
import 'package:provider/provider.dart';
import 'package:finder/provider/user_provider.dart';
import 'package:finder/plugin/my_appbar.dart';

///用户信息详情页
class UserProfilePage extends StatefulWidget {
  final int senderId;
  UserProfilePage({this.senderId});
  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  UserModel user;

  @override
  void initState() {
    getProfile();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    getProfile();
    return Scaffold(
        body: (this.user != null)
            ? SafeArea(
                top: false,
                child: Container(
                  color: Colors.amber,
                  child: MyAppBar(
                    appbar: AppBar(
                      // title: Text(widget.sender.nickname),
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                    ),
                    child: ListView(
                      padding: EdgeInsets.all(0),
                      children: <Widget>[
                        // buildUserBackground(this.widget.sender, context),
                        Align(
                          child: Container(
                            child: Avatar(
                              url: user.avatar,
                              avatarHeight: 200,
                            ),
                          ),
                        ),
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
                ))
            : FinderDialog.showLoading());
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

  Future getProfile() async {
    var data = await apiClient.getOtherProfile(userId: widget.senderId);
    UserModel user = UserModel.fromJson(data['data']);

    if (!mounted) return;
    setState(() {
      this.user = user;
    });
  }
}
