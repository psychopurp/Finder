import 'package:finder/models/message_model.dart';
import 'package:finder/pages/profile_drawer.dart';
import 'package:finder/pages/register_page.dart';
import 'package:finder/provider/user_provider.dart';
import 'package:finder/routers/application.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'home_page.dart';
import 'message_page.dart';
import 'serve_page.dart';
import 'recruit_page.dart';
import 'package:finder/public.dart';

class IndexPage extends StatefulWidget {
  @override
  _IndexPageState createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> with TickerProviderStateMixin {
  int _selectIndex = 0;

  var pages = [
    HomePage(),
    RecruitPage(), RecruitPage(),
    // LoginPage(),
    MessagePage(),
    ServePage(),
//    UserProfilePage(),
  ];

  void update() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 300), () {
      String nickName = Provider.of<UserProvider>(context).userInfo.nickname;
      bool notRegister = nickName == "" || nickName == null;
      if (notRegister) {
        Navigator.of(context).pushAndRemoveUntil(
            new MaterialPageRoute(builder: (context) => new RegisterPage()),
            (route) => route == null);
      }
      MessageModel().addListener(update);
    });
  }

  @override
  void dispose() {
    super.dispose();
    if(MessageModel.instance != null){
      MessageModel().removeListener(update);
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.instance = ScreenUtil(width: 750, height: 1334)..init(context);
    return Scaffold(
      // primary: false,
      drawer: ProfileDrawer(),
//      body: AnimatedSwitcher(
//        duration: Duration(seconds: 1),
//        transitionBuilder: (context, animate) => SlideTransition(
//          child: pages[_selectIndex],
//          position: Tween(begin: Offset(-1, 0), end: Offset(0, 0)).animate(animate),
//        ),
//        child: pages[_selectIndex],
//      ), // 切换动画
      body: pages[_selectIndex],

      bottomNavigationBar: SafeArea(
        child: BottomAppBar(
          color: Colors.white,
          // clipBehavior: Clip.antiAliasWithSaveLayer,
          // elevation: 0,
          // shape: CircularNotchedRectangle(),
          // notchMargin: 1,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              _singleButton(IconData(0xe688, fontFamily: 'myIcon'), '首页', 0),
              _singleButton(IconData(0xe631, fontFamily: 'myIcon'), '寻你', 1),
              Container(
                height: kBottomNavigationBarHeight - 6,
                alignment: Alignment.center,
                width: ScreenUtil().setWidth(150),
                decoration: ShapeDecoration(
                  shadows: [
                    BoxShadow(
                        color: Colors.black12,
                        spreadRadius: 1,
                        offset: Offset(-0.6, 2))
                  ],
                  shape: CircleBorder(),
                  gradient: SweepGradient(
                    center: FractionalOffset.center,
                    startAngle: 0.0,
                    endAngle: 20,
                    colors: <Color>[
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withGreen(150),
                      Theme.of(context).primaryColor.withBlue(70),
                      Theme.of(context).primaryColor.withRed(40),
                      Theme.of(context).primaryColor.withOpacity(0.5),
                    ],
                    stops: const <double>[0.0, 0.25, 0.5, 0.75, 1.0],
                  ),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    showCupertinoModalPopup(
                        context: context,
                        builder: (_) {
                          return Container(
                            alignment: Alignment.center,
                            height: 200,
                            width: 300,
                            // color: Colors.amber,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                MaterialButton(
                                  padding: EdgeInsets.all(15),
                                  color: Colors.white,
                                  onPressed: () {
                                    Navigator.pop(context);
                                    Application.router.navigateTo(
                                        context, "/publishTopic",
                                        transition: TransitionType.cupertino);
                                  },
                                  shape: CircleBorder(),
                                  child: Text("话题"),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(bottom: 28.0),
                                  child: MaterialButton(
                                    padding: EdgeInsets.all(15),
                                    color: Colors.white,
                                    onPressed: () {
                                      Navigator.pop(context);
                                      Application.router.navigateTo(
                                        context,
                                        Routes.publishRecruit,
                                      );
                                    },
                                    shape: CircleBorder(),
                                    child: Text("招募"),
                                  ),
                                ),
                                MaterialButton(
                                  padding: EdgeInsets.all(15),
                                  color: Colors.white,
                                  onPressed: () {
                                    Navigator.pop(context);
                                    Application.router.navigateTo(
                                        context, "/publishActivity",
                                        transition: TransitionType.cupertino);
                                  },
                                  shape: CircleBorder(),
                                  child: Text("活动"),
                                ),
                              ],
                            ),
                          );
                        });
                    // Application.router.navigateTo(context, "/publishActivity");
                  },
                ),
              ),
              _singleButton(IconData(0xe879, fontFamily: 'myIcon'), '消息', 3,
                  withTips: true, count: MessageModel().allUnReadCount),
              _singleButton(IconData(0xe6b8, fontFamily: 'myIcon'), '服务', 4),
//              _singleButton(
//                  IconData(0xe66d, fontFamily: 'myIcon'), 'Profile', 4),
            ],
          ),
        ),
      ),
    );
  }

  _singleButton(IconData iconData, String title, int index,
      {bool withTips = false, int count = 0}) {
    bool isSelected = (this._selectIndex == index) ? true : false;
    Widget currentWidget;

    Color selectedColor = Theme.of(context).primaryColor;
    Color unSelectedColor = Colors.black.withOpacity(0.5);
    if (isSelected) {
      currentWidget = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            iconData,
            color: selectedColor,
            size: 28,
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: selectedColor,
            ),
          ),
        ],
      );
    } else {
      currentWidget = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            iconData,
            color: unSelectedColor,
            size: 28,
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: unSelectedColor,
            ),
          ),
        ],
      );
    }
    currentWidget = Container(
      child: currentWidget,
      width: double.infinity,
      color: Colors.white,
    );
    if (withTips && count != 0) {
      Widget tips = Container(
        width: count < 100 ? 28 : 35,
        height: 20,
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Text(
          count < 1000 ? "$count" : "999",
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
        ),
      );
      currentWidget = Stack(
        children: <Widget>[
          Center(
            child: currentWidget,
          ),
          Positioned(
            right: count < 100 ? 10 : 0,
            top: 3,
            child: tips,
          )
        ],
      );
    }

    return GestureDetector(
      onTap: () {
//        Future.delayed(Duration(microseconds: 500), () {});
        setState(() {
          this._selectIndex = index;
        });
      },
      child: AnimatedSwitcher(
        transitionBuilder: (Widget child, Animation<double> animation) =>
            isSelected
                ? ScaleTransition(
                    child: child,
                    scale: animation,
                  )
                : FadeTransition(
                    child: child,
                    opacity: animation,
                  ),
        duration: Duration(milliseconds: 200),
        child: Container(
          key: ValueKey(isSelected),
          height: kBottomNavigationBarHeight,
          width: ScreenUtil().setWidth(150),
          // color: isSelected ? Colors.amber : Colors.cyan,
          child: currentWidget,
        ),
      ),
    );
  }
}
