import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:finder/config/api_client.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

// import 'package:flutter_screenutil/flutter_screenutil.dart';
const Color ActionColor = Color(0xFFDB6B5C);
const Color ActionColorActive = Color(0xFFEC7C6D);
const Color PageBackgroundColor = Color.fromARGB(255, 233, 229, 228);

class PublishPage extends StatefulWidget {
  @override
  _PublishPageState createState() => _PublishPageState();
}

class _PublishPageState extends State<PublishPage>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  File _image;
  bool nameLess = false;
  TextEditingController inputController;
  TextEditingController titleInputController;
  TextEditingController schoolInputController;
  TextEditingController idInputController;
  List<Map<String, dynamic>> tabBarItem;
  String errorHint = "";
  Dio dio;

  @override
  void dispose() {
    _tabController.dispose();
    inputController.dispose();
    titleInputController.dispose();
    schoolInputController.dispose();
    idInputController.dispose();
    super.dispose();
  }

  void initState() {
    super.initState();
    _tabController = new TabController(vsync: this, length: 3, initialIndex: 1);
    inputController = TextEditingController();
    titleInputController = TextEditingController();
    schoolInputController = TextEditingController();
    idInputController = TextEditingController();
    dio = ApiClient.dio;
    tabBarItem = [
      {
        "name": '头号说',
        "page": leadSay,
        "post": leadSayPost,
      },
      {
        "name": "心动说",
        "page": normalSay,
        "post": normalSayPost,
      },
      {
        "name": "对Ta说",
        "page": sayToHe,
        "post": sayToHePost,
      }
    ];
  }

  Future<bool> leadSayPost() async {
    if (_image == null) {
      errorHint = "请上传图片";
      return false;
    }
    String title = titleInputController.text;
    if (title == "" || title == null) {
      errorHint = "请输入标题";
      return false;
    }
    String content = inputController.text;
    if (content == null || content == "") {
      errorHint = "请输入内容";
      return false;
    }
    String image = await apiClient.uploadImage(_image);
    if (image == null) {
      errorHint = "图片上传失败, 请重试";
      return false;
    }
    try {
      var response = await dio.post("add_lead_he_she_say/",
          data: json.encode({
            "title": title,
            "content": content,
            "is_show_name": !nameLess,
            "image": image,
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

  Future<bool> normalSayPost() async {
    String content = inputController.text;
    if (content == null || content == "") {
      errorHint = "请输入内容";
      return false;
    }
    try {
      var response = await dio.post("add_he_she_say/",
          data: json.encode({
            "content": content,
            "is_show_name": !nameLess,
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

  Future<bool> sayToHePost() async {
    String id = idInputController.text;
    if (id == "" || id == null) {
      errorHint = "请输入学号";
      return false;
    }
    int numId = int.tryParse(id);
    if (numId == null) {
      errorHint = "学号非法";
      return false;
    }
    String content = inputController.text;
    if (content == null || content == "") {
      errorHint = "请输入内容";
      return false;
    }
    try {
      var response = await dio.post("send_say_to_he/",
          data: json.encode({
            "content": content,
            "is_show_name": !nameLess,
            "id": id,
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
                bool status = await tabBarItem[_tabController.index]["post"]();
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
          "他 · 她说",
          style: TextStyle(
            color: appBarColor,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        // centerTitle: true,
        bottom: TabBarWithBorder(
          child: TabBar(
            isScrollable: true,
            labelColor: ActionColor,
            indicatorColor: ActionColorActive,
            indicatorWeight: 3,
            indicatorSize: TabBarIndicatorSize.label,
            labelPadding: EdgeInsets.symmetric(horizontal: 25, vertical: 0),
            unselectedLabelColor: Color(0xff333333),
            tabs: List<Widget>.generate(tabBarItem.length, (index) {
              return Tab(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text(tabBarItem[index]["name"]),
                ),
              );
            }),
            controller: _tabController,
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: new TabBarView(
        controller: _tabController,
        children: List<Widget>.generate(
            tabBarItem.length, (index) => tabBarItem[index]["page"]()),
      ),
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
              inactiveTrackColor: ActionColor,
              key: ValueKey(1),
            ),
          ),
        ),
      );

  Widget normalSay() {
    return Column(
      children: <Widget>[
        Expanded(
          flex: 1,
          child: getTextField(1),
        ),
        getShowNameSwitch()
      ],
    );
  }

  Widget selectImageWidget() {
    var uploadColor = Color.fromARGB(255, 235, 173, 146);
    double height = 250;
    if (_image == null)
      return Padding(
        padding: EdgeInsets.only(top: 20, left: 15, right: 15),
        child: Container(
          height: height,
          decoration: BoxDecoration(
              border: Border.all(style: BorderStyle.solid, color: uploadColor)),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Icon(
                  Icons.add,
                  color: uploadColor,
                  size: 50,
                ),
                Text(
                  "上传封面图",
                  style: TextStyle(
                    color: uploadColor,
                    fontSize: 16,
                  ),
                )
              ],
            ),
          ),
        ),
      );
    else
      return Padding(
        padding: EdgeInsets.only(top: 20, left: 15, right: 15),
        child: Container(
          height: height,
          width: double.infinity,
          child: Image.file(
            _image,
            fit: BoxFit.cover,
          ),
        ),
      );
  }

  Widget leadSay() {
    return ListView(
      children: <Widget>[
        InkWell(
          child: selectImageWidget(),
          onTap: () async {
            var image =
                await ImagePicker.pickImage(source: ImageSource.gallery);
            // var photo = await ImagePicker.pickImage(source: ImageSource.camera);
            // ImagePicker.pickVideo(source: ImageSource.camera);
            setState(() {
              _image = image;
            });
          },
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
          child: TextField(
            maxLines: 1,
            maxLength: 20,
            minLines: 1,
            cursorColor: ActionColor,
            controller: titleInputController,
            decoration: InputDecoration(
              labelText: '标题',
              filled: true,
              hintText: '请输入标题',
              fillColor: Color.fromARGB(255, 245, 241, 241),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: 23, left: 15, right: 15),
          child: TextField(
            key: ValueKey(2),
            decoration: InputDecoration(
              // border: UnderlineInputBorder(),
              fillColor: Colors.white,
              filled: true,
              hintText: '写下想说的...',
              border: InputBorder.none,
            ),
            maxLines: 14,
            maxLengthEnforced: true,
            maxLength: 1000,
            autofocus: false,
            controller: inputController,
            cursorColor: ActionColor,
          ),
        ),
        getShowNameSwitch(),
      ],
    );
  }

  Widget sayToHe() {
    return Column(
      children: <Widget>[
        Expanded(
          flex: 1,
          child: getTextField(3),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
          child: TextField(
            maxLines: 1,
            maxLength: 10,
            minLines: 1,
            cursorColor: ActionColor,
            controller: idInputController,
            decoration: InputDecoration(
              labelText: '学号',
              filled: true,
              hintText: '请输入Ta的学号',
              fillColor: Color.fromARGB(255, 245, 241, 241),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        getShowNameSwitch()
      ],
    );
  }
}

class TabBarWithBorder extends StatelessWidget implements PreferredSizeWidget {
  TabBarWithBorder({this.child, Key key}) : super(key: key);
  final PreferredSizeWidget child;

  @override
  Widget build(BuildContext context) {
    var divisorColor = Color(0xeeeeeeee);
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(10),
          color: divisorColor,
          height: 1,
        ),
        child,
        Container(
          padding: EdgeInsets.all(10),
          color: divisorColor,
          height: 1,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(child.preferredSize.height + 2);
}
