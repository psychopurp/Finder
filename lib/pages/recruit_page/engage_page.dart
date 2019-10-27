import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:finder/config/api_client.dart';
import 'package:dio/dio.dart';

const Color ActionColor = Color(0xFFDB6B5C);
const Color ActionColorActive = Color(0xFFEC7C6D);
const Color PageBackgroundColor = Color.fromARGB(255, 233, 229, 228);

class EngageRecruitRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    int id = ModalRoute.of(context).settings.arguments;
    return EngageRecruitPage(id);
  }
}

class EngageRecruitPage extends StatefulWidget {
  EngageRecruitPage(this.id);

  final int id;

  @override
  _EngageRecruitPageState createState() => _EngageRecruitPageState();
}

class _EngageRecruitPageState extends State<EngageRecruitPage>
    with SingleTickerProviderStateMixin {
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

  Future<bool> postData() async {
    String content = inputController.text;
    if (content == null || content == "") {
      errorHint = "请输入内容";
      return false;
    }
    try {
      var response = await dio.post("go_recruit/",
          data: json.encode({
            "information": content,
            "recruit_id": widget.id
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
                  bool status = await postData();
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
            "报名",
            style: TextStyle(
              color: appBarColor,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true, // centerTitle: true,
        ),
        backgroundColor: Colors.white,
        body: body);
  }

  Widget get body {
    return SingleChildScrollView(
      physics: NeverScrollableScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.only(bottom: 23, left: 15, right: 15),
        child: TextField(
          key: ValueKey(2),
          decoration: InputDecoration(
            // border: UnderlineInputBorder(),
            fillColor: Colors.white,
            filled: true,
            hintText: '写下一段给发起者的自我介绍...',
            border: InputBorder.none,
          ),
          maxLines: 20,
          maxLengthEnforced: true,
          maxLength: 3000,
          autofocus: false,
          controller: inputController,
          cursorColor: ActionColor,
        ),
      ),
    );
  }
}
