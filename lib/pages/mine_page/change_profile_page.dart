import 'package:finder/models/user_model.dart';
import 'package:finder/plugin/avatar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChangeProfilePage extends StatefulWidget {
  final UserModel user;
  ChangeProfilePage({this.user});
  @override
  _ChangeProfilePageState createState() => _ChangeProfilePageState();
}

class _ChangeProfilePageState extends State<ChangeProfilePage> {
  Map listItem;
  TextEditingController _controller;

  @override
  void initState() {
    _controller = TextEditingController();
    listItem = {
      'avatar': {'name': '头像', 'data': widget.user.avatar},
      'introduction': {'name': '简介', 'data': widget.user.introduction},
      'nickName': {'name': '昵称', 'data': widget.user.nickname},
      'realName': {'name': '真实姓名', 'data': widget.user.realName},
      'school': {'name': '学校', 'data': widget.user.school.name},
      'major': {'name': '专业', 'data': widget.user.major},
      'phone': {'name': '手机', 'data': widget.user.phone},
      'birthday': {'name': '生日', 'data': widget.user.birthday},
    };
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('个人信息'),
      ),
      body: body,
    );
  }

  Widget get body {
    List<Widget> widgets = [];
    listItem.keys.forEach((item) {
      widgets.add(builListTile(listItem[item]));
    });
    widgets = ListTile.divideTiles(context: context, tiles: widgets).toList();

    return ListView(
      children: widgets,
    );
  }

  builListTile(Map item) {
    Widget child;
    if (item['data'] == null) {
      child = Text('');
    } else if (item['data'].toString().startsWith('http')) {
      child = Card(
        // color: Colors.yellow,
        shape: CircleBorder(),
        margin: EdgeInsets.all(0),
        elevation: 4,
        child: Avatar(
          url: item['data'],
          avatarHeight: 40,
        ),
      );
    } else {
      child = Text(item['data'].toString());
    }

    return ListTile(
      title: Text(item['name']),
      trailing: child,
      onTap: () {
        _controller.text = item['data'];
        handleIntroduction(item['name']);
      },
    );
  }

  handleIntroduction(String title) {
    Navigator.push(
        context,
        CupertinoPageRoute(
            title: title,
            builder: (_) {
              return Scaffold(
                appBar: AppBar(
                  title: Text(title),
                  actions: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top: 15, bottom: 15, right: 10),
                      child: MaterialButton(
                        onPressed: () {},
                        shape: StadiumBorder(),
                        color: Colors.white,
                        child: Text('保存'),
                        minWidth: 30,
                      ),
                    )
                  ],
                ),
                body: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    controller: _controller,
                    autofocus: true,
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.only(left: 10, top: 0),
                        suffix: IconButton(
                          onPressed: () {
                            _controller.clear();
                          },
                          icon: Icon(Icons.clear),
                          color: Colors.black38,
                        ),
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.black38)),
                        enabledBorder: InputBorder.none),
                  ),
                ),
              );
            }));
  }
}
