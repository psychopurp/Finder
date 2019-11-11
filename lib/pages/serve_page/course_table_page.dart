import 'package:finder/plugin/course_table.dart';
import 'package:finder/provider/user_provider.dart';
import 'package:finder/public.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CourseTablePage extends StatefulWidget {
  @override
  _CourseTablePageState createState() => _CourseTablePageState();
}

class _CourseTablePageState extends State<CourseTablePage> {
  List<Color> colors = [
    Color(0x996666cc),
    Color(0x9999CC99),
    Color(0x99CC33CC),
    Color(0x99CC6666),
    Color(0x99FF0033),
    Color(0x996699CC),
    Color(0x9933CC99),
    Color(0x99FF0066),
    Color(0x9966CC99),
    Color(0x99FF9900),
    Color(0x99666699),
    Color(0x99CC6666),
    Color(0x99FF0066),
    Color(0x9900CCCC),
    Color(0x99FFCC00),
  ];
  int colorIndex = 0;
  Eamis eamis = Eamis();
  static DateTime start = DateTime(2019, 9, 2);
  DateTime now = DateTime.now();
  static Map<int, String> weekdays = {
    0: "",
    1: "星期一",
    2: "星期二",
    3: "星期三",
    4: "星期四",
    5: "星期五",
    6: "星期六",
    7: "星期日"
  };
  List<int> days = [0];
  int all = -1;
  double blockHeight = 50;
  double reduceScale = 2.5;
  double margin = 1;
  double padding = 1;
  int week;
  AxisDirection direction = AxisDirection.right;

  @override
  void initState() {
    super.initState();
    changeMode();
    getData();
    var fromTerm = DateTime.now().difference(start).inDays;
    week = (fromTerm / 7).ceil();
  }

  void changeMode({bool reverse = false}) {
    if (!reverse) {
      all++;
      all %= 3;
    } else {
      all--;
      if (all == -1) {
        all = 2;
      }
    }
    if (all == 1) {
      days = [0];
      for (int i = 1; i <= 7; i++) {
        for (var e in eamis.course[i]) {
          if (e != null) {
            days.add(i);
            break;
          }
        }
      }
      if (days.length <= 3) {
        blockHeight = 60;
        reduceScale = 2.2;
      } else if (days.length <= 5) {
        blockHeight = 80;
        reduceScale = 3;
      } else {
        blockHeight = 100;
        reduceScale = 3.5;
      }
    } else if (all == 0) {
      var nowDay = now.weekday;
      days = [0];
      for (int i = 0; i < 3; i++) {
        days.add(nowDay++);
        if (nowDay == 8) nowDay = 1;
      }
      blockHeight = 60;
      reduceScale = 2.2;
    } else {
      days = List<int>.generate(8, (i) => i);
      blockHeight = 100;
      reduceScale = 3.5;
    }
    margin = days.length > 5 ? 1 : 2;
    padding = days.length > 5 ? 1 : 5;
    setState(() {});
  }

  getData() async {
    await eamis.load();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var appBarColor = Color.fromARGB(255, 95, 95, 95);
    var appBarIconColor = Color.fromARGB(255, 155, 155, 155);
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.light,
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
        title: Text(
          "课表",
          style: TextStyle(
            color: appBarColor,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0.5,
        centerTitle: true,
        actions: <Widget>[
          MaterialButton(
            child: Icon(
              Icons.all_inclusive,
              color: appBarIconColor,
            ),
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onPressed: () {
              changeMode();
            },
            minWidth: 10,
          )
        ],
      ),
      body: eamis.username == null || eamis.password == null
          ? CourseTableRegister(() {
              setState(() {
                eamis = Eamis();
              });
              Future.delayed(Duration(seconds: 1), () {
                showErrorHint(context,
                    "课表包含三个模式：\n  1.最近三天的课程.\n  2.我有课程的日子的课程. \n  3.一个星期的完整课程表.\n大家可以通过左右滑动切换模式.\n欢迎大家酌情使用!");
              });
            })
          : body,
    );
  }

  Widget get body {
    if (!eamis.ok) {
      return Container(
        width: ScreenUtil.screenWidthDp,
        height: ScreenUtil.screenHeightDp,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              child: CircularProgressIndicator(),
              height: 40,
              width: 40,
            ),
            Padding(
              padding: EdgeInsets.all(30),
            ),
            Text("加载中"),
          ],
        ),
      );
    }
    return GestureDetector(
      onHorizontalDragEnd: (detail) {
        if (detail.primaryVelocity > 0) {
          direction = AxisDirection.right;
          changeMode(reverse: true);
        } else {
          direction = AxisDirection.left;
          changeMode();
        }
      },
      child: Container(
          height: ScreenUtil.screenHeightDp,
          child: AnimatedSwitcher(
            duration: Duration(milliseconds: 300),
            child: Padding(
              key: ValueKey(all),
              padding: EdgeInsets.only(top: 10, bottom: 10),
              child: table,
            ),
            transitionBuilder: (child, animation) {
              return SlideTransitionX(
                child: RefreshIndicator(
                  onRefresh: () async {
                    await eamis.getData();
                  },
                  child: SingleChildScrollView(
                      physics: AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics()),
                      child: child),
                ),
                direction: direction,
                position: animation,
              );
            },
          )),
    );
  }

  Widget get table {
    Widget child;
    List<int> reduce = [];
    for (int i = 0; i < 14; i++) {
      bool flag = false;
      for (int j = 1; j < days.length; j++) {
        if (eamis.course[days[j]][i] != null) {
          flag = true;
          break;
        }
      }
      if (!flag) {
        reduce.add(i);
      }
    }
    child = Row(
      key: ValueKey(all),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List<Widget>.generate(days.length, (index) {
        List<Widget> children = [
          Container(
            child: Text(
              weekdays[days[index]],
              style: TextStyle(fontSize: days.length > 5 ? 12 : 14),
            ),
            padding: EdgeInsets.only(bottom: 10),
          )
        ];
        if (index == 0) {
          children.addAll(List<Widget>.generate(eamis.unitCount, (i) {
            return Container(
              alignment: Alignment.center,
              height: (reduce.contains(i)
                  ? blockHeight / reduceScale
                  : blockHeight),
              child: Text(eamis.course[index][i].course.name),
            );
          }));
        } else {
          int count = 0;
          Course last = Course(courseId: -1);
          int i = 0;
          eamis.course[days[index]].forEach((e) {
            if (last?.courseId == -1) {
              last = e?.course;
              count = 1;
            } else {
              Course now = e?.course;
              if (now == last) {
                count++;
                if (now == null && count == 2) {
                  int reduceCount = 0;
                  for (int x = 0; x < count; x++) {
                    if (reduce.contains(i - x)) reduceCount++;
                  }
                  children.add(getBlock(last, count, reduce: reduceCount));
                  count = 0;
                }
              } else {
                if (count != 0) {
                  int reduceCount = 0;
                  for (int x = 0; x < count; x++) {
                    if (reduce.contains(i - x - 1)) reduceCount++;
                  }
                  children.add(getBlock(last, count, reduce: reduceCount));
                }
                last = now;
                count = 1;
              }
            }
            i++;
          });
          if (count != 0) children.add(getBlock(last, count));
        }
        double verboseWidth = 80 - days.length * 7.0;
        return Container(
          width: index == 0
              ? verboseWidth
              : (ScreenUtil.screenWidthDp - verboseWidth) / (days.length - 1),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: children,
          ),
        );
//        return Column(
//            children: List<Widget>.generate(eamis.course[days[index]].length,
//                    (i) =>
//                    Text(eamis.course[days[index]][i]?.course?.name ?? ""))
//              ..insert(0, Text(weekdays[index])));
      }),
    );
    colorIndex = 0;
    return child;
  }

  getBlock(Course course, int classes, {int reduce = 0}) {
    Color color;
    bool isActivity = true;
    if (course == null) {
      color = Color.fromARGB(255, 245, 245, 245);
    } else {
      isActivity = course.validWeeks[week];
      if (!isActivity) {
        color = Color(0xffeeeeee);
      } else {
        color = colors[colorIndex++];
        colorIndex %= colors.length;
      }
    }
    double height = blockHeight * reduce / reduceScale +
        blockHeight * (classes - reduce) -
        margin * 2;

    List<Widget> children = course == null
        ? null
        : <Widget>[
            Container(
              width: double.infinity,
              child: Text(
                course.name,
                style: TextStyle(
                    fontSize: days.length > 5 ? 12 : 14,
                    color: isActivity ? Colors.white : Color(0xff666666)),
              ),
              alignment: all == 0 ? Alignment.center : Alignment.centerLeft,
            ),
            Padding(
              padding: EdgeInsets.all(3),
            ),
            Container(
              width: double.infinity,
              child: Text(
                course.position,
                style: TextStyle(
                    fontSize: days.length > 5 ? 12 : 14,
                    color: isActivity ? Colors.white : Color(0xff666666)),
              ),
              alignment: all == 0 ? Alignment.center : Alignment.centerLeft,
            ),
          ];
    if (!isActivity) {
      children
        ..add(
          Padding(
            padding: EdgeInsets.all(3),
          ),
        )
        ..add(
          Container(
            width: double.infinity,
            child: Text(
              "(非本周)",
              style: TextStyle(fontSize: days.length > 5 ? 12 : 14),
            ),
            alignment: all == 0 ? Alignment.center : Alignment.centerLeft,
          ),
        );
    }
    return Container(
      height: height,
      width: double.infinity,
      margin: EdgeInsets.all(margin),
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: course == null
          ? null
          : SingleChildScrollView(
              child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: children),
            ),
    );
  }
}

class SlideTransitionX extends AnimatedWidget {
  SlideTransitionX({
    Key key,
    @required Animation<double> position,
    this.transformHitTests = true,
    this.direction = AxisDirection.down,
    this.child,
  })  : assert(position != null),
        super(key: key, listenable: position) {
    // 偏移在内部处理
    switch (direction) {
      case AxisDirection.up:
        _tween = Tween(begin: Offset(0, 1), end: Offset(0, 0));
        break;
      case AxisDirection.right:
        _tween = Tween(begin: Offset(-1, 0), end: Offset(0, 0));
        break;
      case AxisDirection.down:
        _tween = Tween(begin: Offset(0, -1), end: Offset(0, 0));
        break;
      case AxisDirection.left:
        _tween = Tween(begin: Offset(1, 0), end: Offset(0, 0));
        break;
    }
  }

  Animation<double> get position => listenable;

  final bool transformHitTests;

  final Widget child;

  //退场（出）方向
  final AxisDirection direction;

  Tween<Offset> _tween;

  @override
  Widget build(BuildContext context) {
    Offset offset = _tween.evaluate(position);
    if (position.status == AnimationStatus.reverse) {
      switch (direction) {
        case AxisDirection.up:
          offset = Offset(offset.dx, -offset.dy);
          break;
        case AxisDirection.right:
          offset = Offset(-offset.dx, offset.dy);
          break;
        case AxisDirection.down:
          offset = Offset(offset.dx, -offset.dy);
          break;
        case AxisDirection.left:
          offset = Offset(-offset.dx, offset.dy);
          break;
      }
    }
    return FractionalTranslation(
      translation: offset,
      transformHitTests: transformHitTests,
      child: child,
    );
  }
}

class CourseTableRegister extends StatefulWidget {
  CourseTableRegister(this.onLogin);

  final VoidCallback onLogin;

  @override
  _CourseTableRegisterState createState() => _CourseTableRegisterState();
}

class _CourseTableRegisterState extends State<CourseTableRegister> {
  TextEditingController _password;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _password = TextEditingController();
    Future.delayed(Duration(milliseconds: 200), () {
      showErrorHint(context,
          "本系统使用教务系统账号密码登录.\n\nFinders使用您的账号在本地登录教务系统获取课表.\n\nFinders承诺, 您的密码将不会上传到服务器, 我们也不会以任何形式记录您的密码.\n\n使用本系统, 将默认您同意此行为, 如果不能接受, 请返回首页.\n");
    });
  }

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ScreenUtil.screenWidthDp,
      height: ScreenUtil.screenHeightDp,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(ScreenUtil.screenHeightDp / 10),
            ),
            MaterialButton(
              minWidth: ScreenUtil.screenWidthDp / 1.5,
              height: 50,
              child: Text(
                "学号: ${Provider.of<UserProvider>(context).userInfo.studentId.toString()}",
                style: TextStyle(color: Colors.black),
              ),
              onPressed: () {
                Navigator.of(context).pushNamed(Routes.modifyInfoPage);
              },
              color: Color.fromARGB(255, 245, 241, 241),
              elevation: 1,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0)),
            ),
            Padding(
              padding: EdgeInsets.all(30),
            ),
            Container(
              width: ScreenUtil.screenWidthDp / 1.5,
              child: TextField(
                expands: false,
                obscureText: true,
                keyboardType: TextInputType.text,
                cursorColor: Theme.of(context).primaryColor,
                controller: _password,
                decoration: InputDecoration(
                  labelText: "密码",
                  filled: true,
                  hintText: "请输入您教务系统的密码",
                  fillColor: Color.fromARGB(255, 245, 241, 241),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(30),
            ),
            MaterialButton(
              minWidth: ScreenUtil.screenWidthDp / 1.5,
              height: 50,
              child: Text(
                "确认",
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () async {
                showDialog(
                  context: context,
                  barrierDismissible: false, //点击遮罩不关闭对话框
                  builder: (context) {
                    return UnconstrainedBox(
                      constrainedAxis: Axis.vertical,
                      child: SizedBox(
                        width: 280,
                        child: AlertDialog(
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              CircularProgressIndicator(value: .8),
                              Padding(
                                padding: const EdgeInsets.only(top: 26.0),
                                child: Text("正在加载，请稍后..."),
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
                var eamis = Eamis();
                eamis.password = _password.text;
                eamis.username = Provider.of<UserProvider>(context)
                    .userInfo
                    .studentId
                    .toString();
                await eamis.run();
                Navigator.of(context).pop();
                if (!eamis.ok) {
                  showErrorHint(context, "密码错误");
                  eamis.password = null;
                  eamis.username = null;
                  eamis.clear();
                  eamis = Eamis();
                } else {
                  print(eamis.password);
                  print(eamis.username);
                  widget.onLogin();
                }
              },
              color: Theme.of(context).primaryColor,
              elevation: 1,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0)),
            ),
          ],
        ),
      ),
    );
  }
}
