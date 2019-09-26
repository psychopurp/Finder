import 'package:flutter/material.dart';
import 'package:finder/public.dart';
import 'package:finder/provider/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:finder/pages/index_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:finder/plugin/animated_button.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  String _phone, _password;
  FocusNode phoneNode = new FocusNode();
  FocusNode passwordNode = new FocusNode();

  bool _isObscure = true;
  Color _eyeColor;
  List _loginMethod = [
    {"title": "微信", "icon": IconData(0xe628, fontFamily: 'myIcon')},
    {"title": "QQ", "icon": IconData(0xe67f, fontFamily: 'myIcon')},
    {"title": "微博", "icon": IconData(0xe644, fontFamily: 'myIcon')},
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // getToken(context);

    ScreenUtil.instance = ScreenUtil(width: 750, height: 1334)..init(context);
    return Scaffold(
        body: Form(
            key: _formKey,
            child: Container(
              // color: Colors.amber,
              child: ListView(
                padding:
                    EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30)),
                children: <Widget>[
                  title(),
                  phoneTextField(),
                  Container(height: ScreenUtil().setHeight(60)),
                  passwordTextField(context),
                  buildForgetPasswordText(context),
                  loginButton(context),
                  buildOtherLoginText(),
                  otherMethod(context),
                  buildRegisterText(context),
                  AnimatedButton(),
                  Container(
                    height: 200,
                  )
                ],
              ),
            )));
  }

  Align buildRegisterText(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Padding(
        padding: EdgeInsets.only(top: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('没有账号？'),
            InkWell(
              child: Text(
                '点击注册',
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
              onTap: () {
                //TODO 跳转到注册页面
                print('去注册');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  ButtonBar otherMethod(BuildContext context) {
    return ButtonBar(
      alignment: MainAxisAlignment.center,
      children: _loginMethod
          .map((item) => Builder(
                builder: (context) {
                  return IconButton(
                      icon: Icon(item['icon'],
                          color: Theme.of(context).iconTheme.color),
                      onPressed: () {
                        //TODO : 第三方登录方法
                        Scaffold.of(context).showSnackBar(new SnackBar(
                          content: new Text("${item['title']}登录"),
                          action: new SnackBarAction(
                            label: "取消",
                            onPressed: () {},
                          ),
                        ));
                      });
                },
              ))
          .toList(),
    );
  }

  Align buildOtherLoginText() {
    return Align(
        alignment: Alignment.center,
        child: Container(
          // color: Colors.green,
          child: Text(
            '其他账号登录',
            style: TextStyle(color: Colors.grey, fontSize: 14.0),
          ),
        ));
  }

  Widget loginButton(BuildContext context) {
    final user = Provider.of<UserProvider>(context);
    return Align(
      child: Container(
        // color: Colors.green,
        margin: EdgeInsets.only(
            top: ScreenUtil().setHeight(20),
            bottom: ScreenUtil().setHeight(40)),
        width: ScreenUtil().setWidth(600),
        height: ScreenUtil().setHeight(100),
        child: RaisedButton(
          child: Text(
            'Login',
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          color: Theme.of(context).primaryColor,
          onPressed: () async {
            print("pressed");

            // if (_formKey.currentState.validate()) {
            //   ///只有输入的内容符合要求通过才会到达此处

            //   showDialog(
            //       context: context,
            //       builder: (context) => Padding(
            //             padding: EdgeInsets.symmetric(
            //                 vertical: ScreenUtil().setHeight(367),
            //                 horizontal: ScreenUtil().setWidth(100)),
            //             child: Container(
            //               color: Colors.white,
            //               child: CupertinoActivityIndicator(),
            //             ),
            //           ));
            //   _formKey.currentState.save();
            //   //TODO 执行登录方法
            //   if (await user.login(phone: _phone, password: _password)) {
            //     Navigator.of(context).pushAndRemoveUntil(
            //         new MaterialPageRoute(builder: (context) => new IndexPage()),
            //         (route) => route == null);
            //   } else {
            //     showDialog(
            //         context: context,
            //         builder: (context) => Padding(
            //               padding: EdgeInsets.symmetric(
            //                   vertical: ScreenUtil().setHeight(367),
            //                   horizontal: ScreenUtil().setWidth(100)),
            //               child: Container(
            //                 color: Colors.white,
            //                 child: Text('登陆失败'),
            //               ),
            //             ));
            //   }
            //   print('email:$_phone , password:$_password');
            // }
          },
          shape: StadiumBorder(),
        ),
      ),
    );
  }

  Container buildForgetPasswordText(BuildContext context) {
    return Container(
      // color: Colors.yellow,
      alignment: Alignment.centerRight,
      padding: EdgeInsets.only(top: ScreenUtil().setHeight(8)),
      child: FlatButton(
        child: Text(
          '忘记密码？',
          style: TextStyle(fontSize: 14.0, color: Colors.grey),
        ),
        onPressed: () {},
      ),
    );
  }

  Container title() {
    return Container(
      // color: Colors.amber,
      padding: EdgeInsets.only(
          left: ScreenUtil().setHeight(100),
          top: kToolbarHeight,
          bottom: ScreenUtil().setHeight(130)),
      child: DefaultTextStyle(
        style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontFamily: "Poppins",
            fontSize: ScreenUtil().setSp(50)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Login · 登陆',
            ),
            Container(
              margin: EdgeInsets.only(top: ScreenUtil().setHeight(15)),
              color: Theme.of(context).primaryColor,
              width: ScreenUtil().setWidth(270),
              height: ScreenUtil().setHeight(2),
            ),
          ],
        ),
      ),
    );
  }

  Container phoneTextField() {
    return Container(
      padding: EdgeInsets.all(5),
      child: TextFormField(
        focusNode: phoneNode,
        onEditingComplete: () {
          FocusScope.of(context).requestFocus(passwordNode);
        },
        autofocus: false,
        keyboardType: TextInputType.phone,
        decoration: InputDecoration(
            // icon: Icon(Icons.person),
            hintText: "",
            labelText: '手机号/邮箱地址',
            contentPadding: EdgeInsets.only(bottom: 10)),
        // validator: (String value) {
        //   var emailReg = RegExp(
        //       r"[\w!#$%&'*+/=?^_`{|}~-]+(?:\.[\w!#$%&'*+/=?^_`{|}~-]+)*@(?:[\w](?:[\w-]*[\w])?\.)+[\w](?:[\w-]*[\w])?");
        //   if (!emailReg.hasMatch(value)) {
        //     return '请输入正确的邮箱地址';
        //   } else {
        //     return '正确';
        //   }
        // },
        onSaved: (String value) => _phone = value,
      ),
    );
  }

  Container passwordTextField(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(5),
      child: TextFormField(
        focusNode: passwordNode,
        onSaved: (String value) => _password = value,
        obscureText: _isObscure,
        validator: (value) {
          if (value.isEmpty) {
            return '请输入密码';
          }
        },
        decoration: InputDecoration(
            labelText: '密码',
            // prefixIcon: Icon(Icons.person),
            contentPadding: EdgeInsets.only(bottom: 10),
            suffixIcon: IconButton(
                icon: Icon(
                  Icons.remove_red_eye,
                  color: _eyeColor,
                ),
                onPressed: () {
                  setState(() {
                    _isObscure = !_isObscure;
                    _eyeColor = _isObscure
                        ? Colors.grey
                        : Theme.of(context).iconTheme.color;
                  });
                })),
      ),
    );
  }

  Future login(BuildContext context, phone, password) async {
    final user = Provider.of<UserProvider>(context);
    await user.login(phone: phone, password: password);
  }

  getToken(BuildContext context) async {
    final user = Provider.of<UserProvider>(context);

    Navigator.of(context).pushAndRemoveUntil(
        new MaterialPageRoute(builder: (context) => new IndexPage()),
        (route) => route == null);
  }
}
