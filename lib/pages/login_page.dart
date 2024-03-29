import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:finder/public.dart';
import 'package:finder/provider/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:finder/pages/index_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:finder/plugin/animated_button.dart';

typedef MyCallBackFuture = Future Function();

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
    ScreenUtil.instance = ScreenUtil(width: 750, height: 1334)..init(context);
    final user = Provider.of<UserProvider>(context);

    return Scaffold(
        body: Form(
            key: _formKey,
            child: Container(
              // color: Colors.amber,
              child: ListView(
                padding:
                    EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30)),
                children: <Widget>[
                  // title(),
                  topTitle(context),
                  phoneTextField(context),
                  Container(height: ScreenUtil().setHeight(60)),
                  passwordTextField(context),
                  //忘记密码
                  Container(
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
                  ),
                  Hero(
                    tag: "login",
                    child: LoginButton(
                      height: 100,
                      beginWidth: 600,
                      endWidth: 150,
                      onPress: () async {
                        bool isLogin = await login(user);
                        if (isLogin) {
                          Navigator.of(context).pushAndRemoveUntil(
                              new MaterialPageRoute(
                                  builder: (context) => new IndexPage()),
                              (route) => route == null);
                        } else {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  content: Text('this is alertdialog'),
                                  title: Center(
                                      child: Text(
                                    '标题',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold),
                                  )),
                                );
                              });
                        }
                      },
                      child: Text(
                        'Login',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: ScreenUtil().setHeight(50),
                  ),
                  buildOtherLoginText(),
                  otherMethod(context),
                  buildRegisterText(context),

                  // AnimatedButton(),
                  Container(
                    height: 200,
                  )
                ],
              ),
            )));
  }

  //顶部标题
  topTitle(context) => Container(
        // color: Colors.amber,
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

  phoneTextField(context) => Container(
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
          //     return '请输入正确的手机号';
          //   } else {
          //     return '正确';
          //   }
          // },
          onChanged: (String value) => _phone = value,
        ),
      );

  passwordTextField(context) => Container(
        padding: EdgeInsets.all(5),
        child: TextFormField(
          focusNode: passwordNode,
          onChanged: (String value) => _password = value,
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

  Widget _loginButton(BuildContext context) {
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

  Future login(UserProvider user) async {
    print(this._phone);
    print(this._password);

    return user.login(phone: this._phone, password: this._password);
  }
}

//首页登陆按钮动画
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
              Future.delayed(Duration(microseconds: 300), () {
                _controller.forward();
                setState(() {
                  this.index = 1;
                });

                widget.onPress();
              });
              Future.delayed(Duration(seconds: 2), () {
                _controller.reverse();
                setState(() {
                  this.index = 0;
                });
              });
            },
            onDoubleTap: () {
              _controller.reverse();
            },
            child: Container(
                alignment: Alignment.center,
                width: _widthAnimation.value,
                height: ScreenUtil().setHeight(widget.height),
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
