import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:finder/provider/user_provider.dart';

class FindPage extends StatefulWidget {
  @override
  _FindPageState createState() => _FindPageState();
}

class _FindPageState extends State<FindPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('招募'),
          elevation: 0,
          centerTitle: true,
        ),
        backgroundColor: Color.fromRGBO(0, 0, 0, 0.03),
        body: Center(
          child: Consumer<UserProvider>(
            builder: (context, user, child) {
              if (user.isLogIn) {
                return Column(
                  children: <Widget>[
                    Text(user.token),
                    Text(user.userInfo.phone),
                    Text(user.userInfo.nickname)
                  ],
                );
              } else {
                return RaisedButton(
                  onPressed: () =>
                      user.login(phone: '15522005019', password: '3306'),
                );
              }
            },
          ),
        ));
  }
}
