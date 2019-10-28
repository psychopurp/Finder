import 'package:finder/config/api_client.dart';
import 'package:finder/config/global.dart';
import 'package:finder/models/message_model.dart';
import 'package:finder/models/user_model.dart';
import 'package:finder/provider/user_provider.dart';
import 'package:finder/public.dart';
import 'package:finder/routers/application.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login_page.dart';

class ProfileDrawer extends StatelessWidget {
  final listOption = {
    'settings': {
      'icon': Icon(
        Icons.settings,
        color: Colors.black54,
      ),
    },
    'exit': {
      'icon': Icon(
        Icons.exit_to_app,
        color: Colors.black54,
      ),
    },
    'collection': {
      'icon': Icon(
        IconData(0xe6e0, fontFamily: 'myIcon'),
        color: Colors.black54,
      ),
    },
    'modify': {
      'icon': Icon(
        Icons.mode_edit,
        color: Colors.black54,
      ),
    },
  };

  Widget generateListTile(List list, int index) {
    return ListTile(
      title: Text(
        "${list[index][0]}:         ${list[index][1]}",
        style: TextStyle(fontSize: 14),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Consumer<UserProvider>(
        builder: (context, user, child) {
          List list = [
            [
              "昵称",
              user.userInfo.nickname == null || user.userInfo.nickname == ""
                  ? "无名氏"
                  : user.userInfo.nickname
            ],
            [
              "姓名",
              user.userInfo.realName == null || user.userInfo.realName == ""
                  ? "无名氏"
                  : user.userInfo.realName
            ],
            ["学号", user.userInfo.studentId ?? "没有学号的人"],
            ["学校", user.userInfo.school?.name ?? "家里蹲大学"],
            ["专业", user.userInfo.major ?? "专业"],
          ];
          List<Widget> children = <Widget>[
            topUserInfo(user.userInfo, context),
            ListTile()
          ];
          children.addAll(List<Widget>.generate(
              list.length, (index) => generateListTile(list, index)));
          children.add(ListTile());
          children.add(
            ListTile(
              leading: listOption['modify']['icon'],
              title: Text('编辑信息'),
              onTap: () async {
                Navigator.of(context).pushNamed(Routes.modifyInfoPage);
              },
            ),
          );
          children.add(
            ListTile(
              leading: listOption['exit']['icon'],
              title: Text('退出登录'),
              onTap: () async {
                Global.isLogin = false;
                Global.token = "";
                await MessageModel().cancelTimer();
                await MessageModel().reset();
                ApiClient.dio.options.headers['token'] = "";
                var prefs = await SharedPreferences.getInstance();
                prefs.clear();
                MessageModel.instance = null;
                Provider.of<UserProvider>(context).userInfo = null;
                Navigator.of(context).pushAndRemoveUntil(
                    new MaterialPageRoute(builder: (context) => LoginPage()),
                    (route) => route == null);
              },
            ),
          );
          return ListView(
            padding: EdgeInsets.all(0),
            children: children,
          );
        },
      ),
    );
  }

  topUserInfo(UserModel user, context) {
    double borderRadius = 10;

    Widget avatar = Container(
        height: 100,
        width: 100,
        child: Avatar(
          url: user.avatar,
          avatarHeight: 100,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 3),
          borderRadius: BorderRadius.all(Radius.circular(50)),
        ));

    return Card(
      margin: EdgeInsets.all(0),
      elevation: 4,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              bottomRight: Radius.circular(borderRadius),
              bottomLeft: Radius.circular(borderRadius))),
      child: Container(
        padding: EdgeInsets.only(bottom: 50, top: kToolbarHeight / 2),
        // color: Theme.of(context).primaryColor,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(borderRadius),
                bottomLeft: Radius.circular(borderRadius)),
            gradient: LinearGradient(colors: [
              Theme.of(context).primaryColor.withOpacity(0.6),
              Theme.of(context).primaryColor.withOpacity(0.7),
              Theme.of(context).primaryColor.withOpacity(0.8),
              Theme.of(context).primaryColor.withOpacity(0.9)
            ], begin: Alignment.topLeft, end: Alignment.bottomRight)),
        child: Column(
          children: <Widget>[
            InkWell(
              onTap: () {
                Navigator.pop(context);
                Application.router.navigateTo(context, Routes.minePage);
              },
              child: Hero(
                tag: 'profile',
                child: avatar,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
