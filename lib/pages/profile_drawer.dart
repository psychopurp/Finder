import 'package:finder/models/user_model.dart';
import 'package:finder/plugin/avatar.dart';
import 'package:finder/provider/user_provider.dart';
import 'package:finder/public.dart';
import 'package:finder/routers/application.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:extended_image/extended_image.dart';

class ProfileDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: Consumer<UserProvider>(builder: (context, user, child) {
      return ListView(
        padding: EdgeInsets.all(0),
        children: <Widget>[
          topAvatar(user.userInfo, context),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('设置'),
          )
        ],
      );
    }));
  }

  topAvatar(UserModel user, context) {
    return Container(
      height: 200,
      color: Theme.of(context).primaryColor,
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 30,
          ),
          InkWell(
            onTap: () {
              Navigator.pop(context);
              Application.router.navigateTo(context, Routes.minePage);
            },
            child: Hero(
              tag: 'profile',
              child: Container(
                child: Avatar(
                  url: user.avatar,
                  avatarHeight: 100,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
