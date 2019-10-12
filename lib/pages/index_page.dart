import 'package:finder/pages/mine_page/user_profile_page.dart';
import 'package:finder/pages/register_page.dart';
import 'package:finder/routers/application.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'home_page.dart';
import 'mine_page.dart';
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
    ServePage(),
    RegisterPage(),
    // UserProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    ScreenUtil.instance = ScreenUtil(width: 750, height: 1334)..init(context);
    return Scaffold(
      primary: false,
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
              _singleButton(IconData(0xe688, fontFamily: 'myIcon'), 'Home', 0),
              _singleButton(IconData(0xe631, fontFamily: 'myIcon'), 'Find', 1),
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
                                        "/publishTopicComment",
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
              _singleButton(IconData(0xe6b8, fontFamily: 'myIcon'), 'Serve', 3),
              _singleButton(
                  IconData(0xe66d, fontFamily: 'myIcon'), 'Profile', 4),
            ],
          ),
        ),
      ),
    );
  }

  _singleButton(IconData iconData, String title, int index) {
    bool isSelected = (this._selectIndex == index) ? true : false;
    var selectedWidget = Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Icon(
          iconData,
          color: isSelected ? Colors.black : Colors.black.withOpacity(0.5),
        ),
        Text(
          title,
          style: TextStyle(
            fontFamily: 'normal',
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.black : Colors.black.withOpacity(0.5),
          ),
        ),
      ],
    );
    var unSelectedWidget = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(
          iconData,
          color: Colors.black.withOpacity(0.5),
        ),
        Container(),
      ],
    );

    return InkWell(
      onTap: () {
        Future.delayed(Duration(microseconds: 500), () {});
        setState(() {
          this._selectIndex = index;
        });
      },
      child: Container(
        height: kBottomNavigationBarHeight,
        width: ScreenUtil().setWidth(150),
        child: selectedWidget,
      ),
    );
    // child: !isSelected
    //     ? AnimatedSwitcher(
    //         transitionBuilder:
    //             (Widget child, Animation<double> animation) =>
    //                 ScaleTransition(child: child, scale: animation),
    //         duration: Duration(milliseconds: 300),
    //         child: Container(
    //           key: ValueKey(currentWidget),
    //           height: kBottomNavigationBarHeight,
    //           width: ScreenUtil().setWidth(150),
    //           // color: isSelected ? Colors.amber : Colors.cyan,
    //           child: currentWidget,
    //         ),
    //       )
    //     : Container(
    //         key: ValueKey(currentWidget),
    //         height: kBottomNavigationBarHeight,
    //         width: ScreenUtil().setWidth(150),
    //         // color: isSelected ? Colors.amber : Colors.cyan,
    //         child: currentWidget,
    //       ));
  }
}
