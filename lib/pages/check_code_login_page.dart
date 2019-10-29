import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:finder/config/api_client.dart';
import 'package:finder/pages/register_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:finder/public.dart';
import 'package:finder/provider/user_provider.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:finder/pages/index_page.dart';
import 'package:flutter/cupertino.dart';

typedef MyCallBackFuture = Future Function();

class CheckCodeLoginPage extends StatefulWidget {
  @override
  _CheckCodeLoginPageState createState() => _CheckCodeLoginPageState();
}

class _CheckCodeLoginPageState extends State<CheckCodeLoginPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  String _phone = "";
  String _sendPhone;
  FocusNode phoneNode;
  FocusNode checkCodeNode;
  int leftTime = 0;
  bool isRegister = false;
  TextEditingController _checkCodeController;
  bool isGet = false;
  bool loading = false;

  @override
  void initState() {
    phoneNode = FocusNode();
    checkCodeNode = FocusNode();
    _checkCodeController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    phoneNode.dispose();
    checkCodeNode.dispose();
    _checkCodeController.dispose();
    super.dispose();
  }

  void timer() {
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        leftTime -= 1;
      });
      if (leftTime != 0) {
        timer();
      }
    });
  }

  void showToast(String msg) {
    BotToast.showText(
        text: msg,
        align: Alignment(0, 0.8),
        contentColor: Color(0xff888888),
        duration: Duration(seconds: 5));
  }

  Future<bool> getCheckCode() async {
    if (loading) return false;
    setState(() {
      loading = true;
    });
    RegExp phoneReg = RegExp(r"1[35789]\d{9}");
    bool right = phoneReg.hasMatch(_phone) && _phone.length == 11;
    if (!right) {
      showErrorHint(context, "手机号格式错误");
      return false;
    }
    try {
      Dio dio = ApiClient.dio;
      Response response = await dio.post('message_login/',
          data: json.encode({"phone": _phone}));
      Map<String, dynamic> result = response.data;
      if (!result["status"]) {
        showErrorHint(context, "网络连接失败, 请稍后再试");
      } else {
        showToast("验证码发送成功, 五分钟有效");
        setState(() {
          leftTime = 60;
          isGet = true;
        });
        timer();
        _sendPhone = _phone;
        isRegister = result["is_register"];
        FocusScope.of(context).requestFocus(checkCodeNode);
      }
    } on DioError catch (e) {
      print(e);
    }
    setState(() {
      loading = false;
    });
    return null;
  }

  Future<bool> checkCheckCode() async {
    if (!isGet) {
      showErrorHint(context, "请先获取验证码");
      return false;
    }
    String _checkCode = _checkCodeController.value.text;
    RegExp checkReg = RegExp(r"\d{6}");
    bool right = checkReg.hasMatch(_checkCode) && _checkCode.length == 6;
    if (!right) {
      showErrorHint(context, "验证码格式错误");
      _checkCodeController.clear();
      return false;
    }
    try {
      Dio dio = ApiClient.dio;
      Response response = await dio.post('message_check/',
          data: json.encode({"phone": _sendPhone, "code": _checkCode}));
      Map<String, dynamic> result = response.data;
      if (!result["status"]) {
        showErrorHint(context, result["error"]);
      } else {
        await Provider.of<UserProvider>(context)
            .loginWithToken(result["token"]);
        if (!isRegister) {
          String nickName =
              Provider.of<UserProvider>(context).userInfo.nickname;
          bool notRegister = nickName == "" || nickName == null;
          if (!notRegister) {
            Navigator.of(context).pushAndRemoveUntil(
                new MaterialPageRoute(builder: (context) => new IndexPage()),
                (route) => route == null);
          } else {
            Navigator.of(context).pushAndRemoveUntil(
                new MaterialPageRoute(builder: (context) => new RegisterPage()),
                (route) => route == null);
          }
        } else {
          Navigator.of(context).pushAndRemoveUntil(
              new MaterialPageRoute(builder: (context) => new RegisterPage()),
              (route) => route == null);
        }
      }
    } on DioError catch (e) {
      print(e);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Form(
            key: _formKey,
            child: Container(
              // color: Colors.amber,
              child: ListView(
                physics: NeverScrollableScrollPhysics(),
                padding:
                    EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30)),
                children: <Widget>[
                  // title(),
                  Padding(
                    padding: EdgeInsets.all(10),
                  ),
                  topTitle(context),
                  Padding(
                    padding: EdgeInsets.all(10),
                  ),
                  phoneTextField(context),
                  Container(height: ScreenUtil().setHeight(60)),
                  checkCodeTextField(context),
                  //忘记密码
                  Padding(
                    padding: EdgeInsets.all(50),
                  ),
                  LoginButton(
                    height: 100,
                    beginWidth: 600,
                    endWidth: 150,
                    onPress: checkCheckCode,
                    child: Text(
                      '登录 | 注册',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ),
                  SizedBox(
                    height: ScreenUtil().setHeight(50),
                  ),
                ],
              ),
            )));
  }

  //顶部标题
  topTitle(context) => Container(
        padding: EdgeInsets.only(
            left: ScreenUtil().setHeight(100),
            top: kToolbarHeight,
            bottom: ScreenUtil().setHeight(130)),
        child: DefaultTextStyle(
          style: Theme.of(context)
              .textTheme
              .title
              .copyWith(color: Theme.of(context).accentColor),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Finders · 登录 | 注册',
              ),
              Container(
                margin: EdgeInsets.only(top: ScreenUtil().setHeight(15)),
                color: Theme.of(context).primaryColor,
                width: ScreenUtil().setWidth(350),
                height: ScreenUtil().setHeight(2),
              ),
            ],
          ),
        ),
      );

  phoneTextField(context) => Row(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Container(
              padding: EdgeInsets.all(5),
              child: TextFormField(
                focusNode: phoneNode,
                onEditingComplete: () {
                  FocusScope.of(context).requestFocus(checkCodeNode);
                },
                autofocus: false,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                    // icon: Icon(Icons.person),
                    hintText: "",
                    labelText: '手机号',
                    contentPadding: EdgeInsets.only(bottom: 10)),
                onChanged: (String value) => _phone = value,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10),
          ),
          MaterialButton(
            elevation: 1,
            textColor: Colors.white,
            color: Theme.of(context).primaryColor,
            disabledColor: Theme.of(context).primaryColor.withOpacity(0.8),
            disabledTextColor: Colors.white,
            minWidth: ScreenUtil.screenWidthDp / 3,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Text(
                leftTime == 0 ? loading ? "加载中..." : "获取验证码" : "$leftTime"),
            onPressed: leftTime == 0
                ? () {
                    getCheckCode();
                  }
                : null,
          )
        ],
      );

  checkCodeTextField(context) => Container(
        padding: EdgeInsets.all(5),
        child: TextFormField(
          focusNode: checkCodeNode,
          controller: _checkCodeController,
          keyboardType:
              TextInputType.numberWithOptions(decimal: false, signed: false),
          decoration: InputDecoration(
            labelText: '验证码',
            contentPadding: EdgeInsets.only(bottom: 10),
          ),
        ),
      );
}

//首页登录按钮动画
class LoginButton extends StatefulWidget {
  final double beginWidth;
  final double endWidth;
  final double height;
  final Widget child;
  final AsyncCallback onPress;

  final IconData endIcon;

  LoginButton(
      {this.beginWidth,
      this.endWidth,
      this.endIcon = Icons.done,
      @required this.child,
      this.onPress,
      @required this.height});

  @override
  _LoginButtonState createState() => _LoginButtonState();
}

class _LoginButtonState extends State<LoginButton>
    with TickerProviderStateMixin {
  AnimationController _controller;
  Animation _widthAnimation;
  Animation _scaleAnimation;
  Tween<double> _widthTween;
  int index = 0;

  @override
  void initState() {
    super.initState();

    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 400));
    _widthTween = Tween(
        begin: ScreenUtil().setWidth(widget.beginWidth),
        end: ScreenUtil().setWidth(widget.endWidth));
    _widthAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeInOutBack)
            .drive(_widthTween);
    _scaleAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeInOutBack);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _widthAnimation,
      builder: (BuildContext context, Widget child) {
        return Align(
          child: InkWell(
            highlightColor: Colors.transparent,
            radius: 0,
            onTap: () {
              Future.delayed(Duration(microseconds: 300), () async {
                _controller.forward();
                setState(() {
                  this.index = 1;
                });
                await widget.onPress();
                _controller.reverse();
                this.index = 0;
              });
            },
            child: Container(
                alignment: Alignment.center,
                width: _widthAnimation.value,
                height: 50,
                decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(30)),
                child: IndexedStack(
                  alignment: Alignment.center,
                  index: this.index,
                  children: <Widget>[
                    widget.child,
                    ScaleTransition(
                      scale: Tween<double>(begin: 0, end: 1)
                          .animate(_scaleAnimation),
                      child: CupertinoActivityIndicator(),
                    )
                  ],
                )),
          ),
        );
      },
    );
  }
}
