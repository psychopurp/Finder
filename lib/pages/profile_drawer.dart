import 'package:finder/config/api_client.dart';
import 'package:finder/config/global.dart';
import 'package:finder/models/message_model.dart';
import 'package:finder/models/user_model.dart';
import 'package:finder/plugin/avatar.dart';
import 'package:finder/plugin/gradient_generator.dart';
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
          ListTile(
            leading: listOption['exit']['icon'],
            title: Text('注销'),
            onTap: () {
              Global.isLogin = false;
              Global.token = "";
              MessageModel().reset();
              MessageModel().getDataInterval(duration: Duration(minutes: 10));
              ApiClient.dio.options.headers['token'] = "";
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed(Routes.login);
            },
          ),
        ],
      );
    }));
  }

  topAvatar(UserModel user, context) {
    double borderRadius = 10;
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
                child: Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.white, width: 3),
                        borderRadius: BorderRadius.all(Radius.circular(50)),
                        image: DecorationImage(
                            image: CachedNetworkImageProvider(user.avatar)))),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
