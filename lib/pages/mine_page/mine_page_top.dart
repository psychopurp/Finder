import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:finder/model/user_model.dart';

class MinePageTop extends StatelessWidget {
  final UserModel user;
  MinePageTop(this.user);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: ScreenUtil().setHeight(400),
      width: ScreenUtil().setWidth(750),
      // color: Colors.white,
      child: Column(
        children: <Widget>[
          userAvatar(),
        ],
      ),
    );
  }

  Widget userAvatar() {
    return Container(
        margin: EdgeInsets.symmetric(vertical: 20.0),
        // color: Colors.cyan,
        child: InkWell(
          onTap: () {
            print(user.nickname);
          },
          child: CircleAvatar(
            radius: 50.0,
            backgroundImage: NetworkImage(this.user.avatar),
          ),
        ));
  }
}
