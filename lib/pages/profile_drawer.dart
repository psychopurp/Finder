import 'package:finder/models/user_model.dart';
import 'package:finder/plugin/avatar.dart';
import 'package:finder/provider/user_provider.dart';
import 'package:finder/public.dart';
import 'package:finder/routers/application.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:extended_image/extended_image.dart';

class ProfileDrawer extends StatelessWidget {
  final listOption = {
    'settings': {
      'icon': Icon(
        Icons.settings,
        color: Colors.black54,
      ),
    },
    'collection': {
      'icon': Icon(
        IconData(0xe6e0, fontFamily: 'myIcon'),
        color: Colors.black54,
      ),
    },
  };

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: Consumer<UserProvider>(builder: (context, user, child) {
      return ListView(
        padding: EdgeInsets.all(0),
        children: <Widget>[
          topAvatar(user.userInfo, context),
          ListTile(
            leading: listOption['collection']['icon'],
            title: Text('收藏'),
            onTap: () {
              Application.router.navigateTo(context, Routes.collectionPage);
            },
          ),
          ListTile(
            leading: listOption['settings']['icon'],
            title: Text('设置'),
            onTap: () {
              Application.router.navigateTo(context, Routes.settings);
            },
          ),
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
