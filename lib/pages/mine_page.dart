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
    return Scaffold(
        appBar: AppBar(
          title: Consumer<UserProvider>(
            builder: (context, user, child) {
              return Text(user.userInfo.nickname);
            },
          ),
          elevation: 0,
          centerTitle: true,
        ),
        backgroundColor: Color.fromRGBO(0, 0, 0, 0.03),
        body: ListView(
          children: <Widget>[
            topPart,
            MinePageBottom(),
            // topPart,
            // MinePageBottom(),
            // topPart,
            // MinePageBottom()
          ],
        ));
  }

  var topPart = Consumer<UserProvider>(builder: (context, user, child) {
    return MinePageTop(
      user.userInfo,
      isLogIn: user.isLogIn,
    );
  });
}
