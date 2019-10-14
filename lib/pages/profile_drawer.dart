import 'package:finder/plugin/image_load_state.dart';
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
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: Center(
              child: InkWell(
                onTap: () {
                  Navigator.pop(context);
                  Application.router.navigateTo(context, '/userProfile');
                },
                child: Hero(
                  tag: 'profile',
                  child: Container(
                    // margin: EdgeInsets.only(top: ScreenUtil().setHeight(0)),
                    height: ScreenUtil().setHeight(200),
                    width: ScreenUtil().setWidth(200),
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.white, width: 1.5),
                        borderRadius: BorderRadius.circular(50),
                        image: DecorationImage(
                            image: ExtendedNetworkImageProvider(
                                user.userInfo.avatar,
                                cache: true))),
                  ),
                ),
              ),
            ),

            // ExtendedImage.network(
            //   user.userInfo.avatar,
            //   scale: 6,
            //   fit: BoxFit.fill,
            //   cache: true,
            //   border: Border.all(color: Colors.white, width: 1.0),
            //   shape: BoxShape.circle,
            //   borderRadius: BorderRadius.all(Radius.circular(20.0)),
            // loadStateChanged: imageLoadStateChange,
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('设置'),
          )
        ],
      );
    }));
  }
}
