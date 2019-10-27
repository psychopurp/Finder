import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:finder/config/api_client.dart';
import 'package:flutter/material.dart';

const Color ActionColor = Color(0xFFDB6B5C);
const Color ActionColorActive = Color(0xFFEC7C6D);
const Color PageBackgroundColor = Color.fromARGB(255, 233, 229, 228);

class SayToHeRoute extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    int id = ModalRoute.of(context).settings.arguments;
    return SayToHePage(id);
  }
}

class SayToHePage extends StatefulWidget {
  SayToHePage(this.id);
  final int id;
  @override
  _SayToHePageState createState() => _SayToHePageState();
}

class _SayToHePageState extends State<SayToHePage>
    with SingleTickerProviderStateMixin {
  bool nameLess = false;
  TextEditingController inputController;
  String errorHint = "";
  Dio dio;

  @override
  void dispose() {
    inputController.dispose();
    super.dispose();
  }

  void initState() {
    super.initState();
    inputController = TextEditingController();
    dio = ApiClient.dio;
  }

  Future<bool> sayToHePost() async {

    String content = inputController.text;
    if (content == null || content == "") {
      errorHint = "请输入内容";
      return false;
    }
    try {
      var response = await dio.post("send_say_to_he_by_id/",
          data: json.encode({
            "content": content,
            "is_show_name": !nameLess,
            "id": widget.id,
          }));
      var data = response.data;
      if (!data["status"]) {
        errorHint = data["error"];
        return false;
      } else {
        return true;
      }
    } on DioError catch (e) {
      print(e);
      errorHint = "网络连接失败, 请稍后再试";
      return false;
    }
  }

  void handleSuccess() {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) {
        return Scaffold(
          body: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              color: Colors.white,
              height: double.infinity,
              width: double.infinity,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "发布成功！",
                          style: TextStyle(color: ActionColor, fontSize: 30),
                        ),
                        Icon(
                          Icons.check_circle_outline,
                          color: ActionColor,
                          size: 45,
                        )
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.all(25),
                    ),
                    Text(
                      "点击屏幕返回",
                      style: TextStyle(
                        color: Color.fromARGB(255, 235, 173, 146),
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  void handleError() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("提示"),
            content: Text(errorHint),
            actions: <Widget>[
              FlatButton(
                child: Text("确认"),
                onPressed: () => Navigator.of(context).pop(), //关闭对话框
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    var appBarColor = Color.fromARGB(255, 95, 95, 95);
    var appBarIconColor = Color.fromARGB(255, 155, 155, 155);
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(vertical: 14, horizontal: 7),
            child: MaterialButton(
              minWidth: 30,
              padding: EdgeInsets.symmetric(horizontal: 18),
              color: ActionColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              onPressed: () async {
                showDialog(
                  context: context,
                  barrierDismissible: false, //点击遮罩不关闭对话框
                  builder: (context) {
                    return AlertDialog(
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          CircularProgressIndicator(),
                          Padding(
                            padding: const EdgeInsets.only(top: 26.0),
                            child: Text("正在发布，请稍后..."),
                          )
                        ],
                      ),
                    );
                  },
                );
                bool status = await sayToHePost();
                Navigator.pop(context);
                if (!status) {
                  handleError();
                } else {
                  handleSuccess();
                }
              },
              child: Text(
                '发布',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          )
        ],
        backgroundColor: Colors.white,
        leading: MaterialButton(
          child: Icon(
            Icons.arrow_back_ios,
            color: appBarIconColor,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        // title: Text('Finders'),
        brightness: Brightness.light,
        elevation: 0,
        title: Text(
          "对Ta说",
          style: TextStyle(
            color: appBarColor,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        // centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: sayToHe()
    );
  }

  Widget getTextField(int key) => Padding(
        padding: EdgeInsets.symmetric(vertical: 23, horizontal: 15),
        child: TextField(
          key: ValueKey(key),
          decoration: InputDecoration(
            // border: UnderlineInputBorder(),
            fillColor: Colors.white,
            filled: true,
            hintText: '写下想说的...',
            border: InputBorder.none,
          ),
          expands: true,
          maxLines: null,
          maxLengthEnforced: true,
          maxLength: 1000,
          autofocus: false,
          cursorColor: ActionColor,
          controller: inputController,
        ),
      );

  Widget getShowNameSwitch() => Padding(
        padding: EdgeInsets.symmetric(horizontal: 15),
        child: Container(
          decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.black12),
              )),
          child: ListTile(
            leading: Text('启用匿名'),
            trailing: Switch(
              value: nameLess,
              onChanged: (val) {
                setState(() {
                  nameLess = val;
                });
              },
              activeColor: Colors.white,
              activeTrackColor: ActionColor,
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: Colors.grey,
              key: ValueKey(1),
            ),
          ),
        ),
      );

  Widget sayToHe() {
    return Column(
      children: <Widget>[
        Expanded(
          flex: 1,
          child: getTextField(3),
        ),
        getShowNameSwitch()
      ],
    );
  }
}