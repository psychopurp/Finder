import 'package:finder/public.dart';
import 'package:flutter/material.dart';

///登录页动画按钮

class AnimatedButton extends StatefulWidget {
  @override
  _AnimatedButtonState createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with TickerProviderStateMixin {
  AnimationController _controller;
  AnimationController _widthController;
  Tween<double> _widthTween;
  Tween<double> _scaleTween;
  Animation<double> _widthAnimation;
  Animation<double> _animation;
  static var btnColors = [
    Color.fromRGBO(219, 107, 92, 1),
    Color.fromRGBO(219, 107, 92, 0.8)
  ];
  Color btnColor = btnColors[0];
  int index = 0;

  @override
  void initState() {
    super.initState();

    _controller =
        AnimationController(vsync: this, duration: Duration(microseconds: 400));
    _widthController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 400));
    _widthTween = Tween(
        begin: ScreenUtil().setWidth(600), end: ScreenUtil().setWidth(150));
    _scaleTween = Tween(begin: 0, end: 1);

    _animation =
        CurvedAnimation(parent: _controller, curve: Curves.easeInOutBack);
    _widthAnimation =
        CurvedAnimation(parent: _widthController, curve: Curves.easeInOutBack)
            .drive(_widthTween);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _widthAnimation,
      builder: (BuildContext context, Widget child) {
        return Align(
          child: GestureDetector(
            onTapDown: (_) {
              setState(() {
                this.btnColor = btnColors[1];
              });
            },
            onTapUp: (_) {
              Future.delayed(Duration(microseconds: 600), () {
                setState(() {
                  this.btnColor = btnColors[0];
                  index = 1;
                });
                _widthController.forward();
                _controller.forward();
              });
            },
            onTap: () {
              print('tapped');
            },
            child: Container(
              alignment: Alignment.center,
              height: ScreenUtil().setHeight(100),
              width: _widthAnimation.value,
              child: IndexedStack(
                alignment: Alignment.center,
                index: index,
                children: <Widget>[
                  Text(
                    "登陆",
                    style: TextStyle(
                        fontFamily: "Poppins",
                        color: Colors.white,
                        fontSize: ScreenUtil().setSp(30)),
                  ),
                  ScaleTransition(
                    scale: _scaleTween.animate(_animation),
                    child: Icon(
                      Icons.done,
                      color: Colors.white,
                      size: ScreenUtil().setSp(60),
                    ),
                  )
                ],
              ),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50), color: btnColor),
            ),
          ),
        );
      },
    );
  }
}
