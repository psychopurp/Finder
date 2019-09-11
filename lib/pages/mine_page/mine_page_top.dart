import 'package:flutter/material.dart';
import 'package:finder/models/user_model.dart';
import 'package:finder/public.dart';

class MinePageTop extends StatelessWidget {
  final UserModel user;
  final bool isLogIn;
  MinePageTop(this.user, {this.isLogIn = false});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: ScreenUtil().setHeight(400),
      width: ScreenUtil().setWidth(750),
      // color: Colors.pink,
      child: Column(
        children: <Widget>[
          userAvatar(),
          fanFollowerArea(),
        ],
      ),
    );
  }

  //头像
  Widget userAvatar() {
    return Container(
        margin: EdgeInsets.symmetric(vertical: ScreenUtil().setHeight(40)),
        // color: Colors.cyan,
        height: ScreenUtil().setHeight(200),
        child: InkWell(
          onTap: () {
            print(user.nickname);
          },
          child: CircleAvatar(
            radius: 50.0,
            backgroundImage: CachedNetworkImageProvider(
              this.user.avatar,
            ),
          ),
        ));
  }

  //关注-粉丝 区域
  Widget fanFollowerArea() {
    return Container(
      height: ScreenUtil().setHeight(120),
      width: ScreenUtil().setWidth(750),
      color: Colors.amber,
    );
  }
}
