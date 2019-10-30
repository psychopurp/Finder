import 'dart:convert';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:finder/config/api_client.dart';
import 'package:finder/config/global.dart';
import 'package:flutter/material.dart';
import 'package:finder/models/recruit_model.dart';

// import 'package:flutter_screenutil/flutter_screenutil.dart';
const Color ActionColor = Color(0xFFDB6B5C);
const Color ActionColorActive = Color(0xFFEC7C6D);
const Color PageBackgroundColor = Color.fromARGB(255, 233, 229, 228);

class RecruitPublishPage extends StatefulWidget {
  @override
  _RecruitPublishPageState createState() => _RecruitPublishPageState();
}

class _RecruitPublishPageState extends State<RecruitPublishPage>
    with SingleTickerProviderStateMixin {
  TextEditingController inputController;
  TextEditingController titleInputController;
  TextEditingController _tagController;
  static List<RecruitTypesModelData> _types = [];
  static List<RecruitTypesModelData> _nowTypes = [];
  FocusNode _tagFocus;
  List<String> tags = [];
  String errorHint = "";
  Dio dio;

  @override
  void dispose() {
    inputController.dispose();
    titleInputController.dispose();
    _tagController.dispose();
    _types = [];
    _tagFocus.dispose();
    _nowTypes = [];
    super.dispose();
  }

  void initState() {
    super.initState();
    inputController = TextEditingController();
    titleInputController = TextEditingController();
    _tagController = TextEditingController();
    _tagFocus = FocusNode();
    dio = ApiClient.dio;
    RecruitTypesModel recruitTypes = global.recruitTypes;
    if (recruitTypes.status) {
      _types = recruitTypes.data;
    }
  }

  Future<bool> postData() async {
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
    if(_types.length == 0){
      errorHint = "请至少选择一个类型";
      return false;
    }
    try {
      var response = await dio.post("add_recruit/",
          data: json.encode({
            "title": title,
            "introduction": content,
            "types": _nowTypes.map((e)=>e.id).toList(),
            "tags": tags
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
            "招募",
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

  Widget getTag(String tag, {bool select = true}) {
    return Builder(
      builder: (context) {
        return GestureDetector(
          onTap: (){
            setState(() {
              tags.remove(tag);
            });
          },
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 5, vertical: 8),
            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            decoration: BoxDecoration(
                color: !select
                    ? Color.fromARGB(255, 204, 204, 204)
                    : Theme.of(context).accentColor,
                borderRadius: BorderRadius.circular(15)),
            child: Text(
              tag,
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget get body {
    return ListView(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
          child: TextField(
            maxLines: 1,
            maxLength: 30,
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
            maxLength: 3000,
            autofocus: false,
            controller: inputController,
            cursorColor: ActionColor,
          ),
        ),
        Row(children: <Widget>[
          Padding(
            padding: EdgeInsets.all(10),
          ),
          Expanded(
            flex: 1,
            child: TextField(
              maxLines: 1,
              cursorColor: ActionColor,
              controller: _tagController,
              focusNode: _tagFocus,
              decoration: InputDecoration(
                labelText: '标签',
                filled: true,
                hintText: '请输入标签',
                fillColor: Color.fromARGB(255, 245, 241, 241),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          MaterialButton(
            onPressed: () {
              String value = _tagController.value.text.trim();
              if(value == "") return;
              _tagController.clear();
              tags.add(value);
              _tagFocus.unfocus();
            },
            child: Icon(Icons.add),
          )
        ]),
        Padding(
          padding: EdgeInsets.all(10),
          child: Wrap(
            children: tags.map((e)=>getTag(e)).toList(),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(10),
          child: TypeSelector(
            onChange: () {
              setState(() {});
            },
          ),
        )
      ],
    );
  }
}

class TypeSelector extends StatefulWidget {
  TypeSelector({this.onChange});

  final VoidCallback onChange;

  @override
  _TypeSelectorState createState() => _TypeSelectorState();
}

class _TypeSelectorState extends State<TypeSelector>
    with TickerProviderStateMixin {
  bool isOpen = false;

  List<RecruitTypesModelData> get _types => _RecruitPublishPageState._types;

  List<RecruitTypesModelData> get _nowTypes =>
      _RecruitPublishPageState._nowTypes;

  AnimationController _animationController;
  AnimationController _rotateController;
  Animation _rotateAnimation;
  Animation _animation;
  Animation _curve;

  double _oldHeight = 0;

  @override
  void initState() {
    super.initState();
    const Duration duration = Duration(milliseconds: 300);
    _animationController = AnimationController(vsync: this, duration: duration);
    _rotateController = AnimationController(vsync: this, duration: duration);
    _animationController.addListener(() {
      setState(() {});
    });
    _curve =
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
    _animation = Tween<double>(begin: 0, end: 1).animate(_curve);
    _rotateAnimation = Tween<double>(begin: 0, end: pi / 2).animate(
        CurvedAnimation(curve: Curves.easeInOut, parent: _rotateController));
  }

  Future<void> changeHeightTo(height) async {
    double oldHeight = _oldHeight;
    _animationController.reset();
    _animation = Tween<double>(begin: oldHeight, end: height).animate(_curve);
    await _animationController.forward();
    _oldHeight = height;
  }

  Future<void> changeHeight() async {
    int length = _types.length; // 获取较大的列表长度
    double height = (length / 5).ceil() * 65.0 + 31;
    await changeHeightTo(height);
  }

  @override
  void dispose() {
    super.dispose();
    _animationController.dispose();
    _rotateController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget child;
    child = Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 20),
      margin: EdgeInsets.symmetric(vertical: 5),
      child: Column(
        children: <Widget>[
          Row(children: <Widget>[
            _nowTypes.length == 0
                ? Text("请选择招募类型")
                : _nowTypes.length <= 2
                    ? Row(
                        children: _nowTypes.map((e) => getTag(e.name)).toList(),
                      )
                    : Row(
                        children: List<Widget>.generate(
                            2, (index) => getTag(_nowTypes[index].name))
                          ..add(getTag("等")),
                      ),
            Expanded(
              flex: 1,
              child: Container(),
            ),
            MaterialButton(
              onPressed: () {
                if (!isOpen) {
                  open();
                } else {
                  close();
                }
              },
              minWidth: 10,
              padding: EdgeInsets.symmetric(horizontal: 13),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Text(
                    "修改分类",
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xff444444),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(3),
                  ),
                  Transform.rotate(
                    angle: _rotateAnimation.value,
                    child: Icon(
                      Icons.arrow_forward_ios,
                      size: 11,
                    ),
                  )
                ],
              ),
            ),
          ]),
          Container(
            height: _animation.value,
            padding: EdgeInsets.symmetric(vertical: 10),
            child: SingleChildScrollView(
              physics: NeverScrollableScrollPhysics(),
              child: Column(
                children: <Widget>[
                  Wrap(
                    children: List<Widget>.generate(
                        _types.length,
                        (index) => GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (!_nowTypes.contains(_types[index])) {
                                    _nowTypes.add(_types[index]);
                                  } else
                                    _nowTypes.remove(_types[index]);
                                });
                              },
                              child: getTag(_types[index].name,
                                  select: _nowTypes.contains(_types[index])),
                            )),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
    return child;
  }

  Future<void> close() async {
    _rotateController.reverse();
    await changeHeightTo(0.0);
    isOpen = false;
    setState(() {});
  }

  Future<void> open() async {
    _rotateController.forward();
    await changeHeight();
    isOpen = true;
  }

  Widget getTag(String tag, {bool select = true}) {
    return Builder(
      builder: (context) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 5, vertical: 8),
          padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          decoration: BoxDecoration(
              color: !select
                  ? Color.fromARGB(255, 204, 204, 204)
                  : Theme.of(context).accentColor,
              borderRadius: BorderRadius.circular(15)),
          child: Text(
            tag,
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
            ),
          ),
        );
      },
    );
  }
}
