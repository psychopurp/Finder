import 'package:cached_network_image/cached_network_image.dart';
import 'package:finder/models/internship_item.dart';
import 'package:finder/routers/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:finder/plugin/better_text.dart';

const Color ActionColor = Color(0xFFDB6B5C);
const Color ActionColorActive = Color(0xFFEC7C6D);
const Color PageBackgroundColor = Color.fromARGB(255, 233, 229, 228);

class RecommendInternshipDetailPage extends StatefulWidget {
  @override
  _RecommendInternshipDetailPageState createState() =>
      _RecommendInternshipDetailPageState();
}

class _RecommendInternshipDetailPageState
    extends State<RecommendInternshipDetailPage> {
  Map<String, Map<String, dynamic>> menuItem;

  void _handleShare() {
    print("handleShare");
  }

  void _handleReport() {}

  @override
  void initState() {
    super.initState();
    menuItem = {
      "分享": {"handle": _handleShare, "icon": Icons.share},
      "举报": {"handle": _handleReport, "icon": Icons.error}
    };
  }

  @override
  Widget build(BuildContext context) {
    var appBarColor = Color.fromARGB(255, 95, 95, 95);
    var appBarIconColor = Color.fromARGB(255, 155, 155, 155);
    var numColor = Color.fromARGB(255, 235, 173, 146);
    var split = Padding(
      padding: EdgeInsets.symmetric(horizontal: 30),
      child: Container(
        height: 1,
        color: Color(0xdddddddd),
      ),
    );
    InternshipItem item = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      appBar: AppBar(
        leading: MaterialButton(
          child: Icon(
            Icons.arrow_back_ios,
            color: appBarIconColor,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        brightness: Brightness.light,
        backgroundColor: Colors.white,
        title: BetterText(
          item.title,
          maxLines: 1,
          enableSelection: true,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: appBarColor, fontSize: 22),
        ),
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 20),
            child: PopupMenuButton(
              padding: EdgeInsets.symmetric(horizontal: 18),
              color: Colors.white,
              itemBuilder: (context) {
                List<PopupMenuItem<String>> list = [];
                menuItem.forEach((key, value) {
                  list.add(PopupMenuItem<String>(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(menuItem[key]["icon"]),
                        Expanded(
                          flex: 1,
                          child: BetterText(
                            key,
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                    value: key,
                  ));
                });
                return list;
              },
              onSelected: (key) {
                menuItem[key]["handle"]();
              },
              child: Icon(
                Icons.more_horiz,
                color: ActionColor,
                size: 30,
              ),
            ),
          )
        ],
      ),
      body: ListView(
        children: <Widget>[
          Container(
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 1),
              width: double.infinity,
              height: 250,
              child: Hero(
                tag: item.image,
                child: CachedNetworkImage(
                  imageUrl: item.image,
                  imageBuilder: (context, imageProvider) => Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              )),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
            width: double.infinity,
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      BetterText(
                        item.title,
                        enableSelection: true,
                        style: TextStyle(
                          fontSize: 24,
                          letterSpacing: 2,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(3),
                      ),
                      BetterText(
                        getTimeString(item.time),
                        enableSelection: true,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          color: numColor,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          split,
          Container(
            padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
            child: MaterialButton(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onPressed: () {
                Navigator.of(context)
                    .pushNamed(Routes.internshipCompany, arguments: item);
              },
              padding: EdgeInsets.all(0),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 50,
                    height: 50,
                    child: Hero(
                      tag: "${item.company.name}-${item.id}",
                      child: CachedNetworkImage(
                        placeholder: (context, url) {
                          return Container(
                            padding: EdgeInsets.all(10),
                            child: CircularProgressIndicator(),
                          );
                        },
                        imageUrl: item.company.image,
                        errorWidget: (context, url, err) {
                          return Container(
                            child: Icon(
                              Icons.cancel,
                              size: 50,
                              color: Colors.grey,
                            ),
                          );
                        },
                        imageBuilder: (context, imageProvider) {
                          return Container(
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(25)),
                              image: DecorationImage(
                                image: imageProvider,
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 15),
                    child: BetterText(
                      item.company.name,
                      style: TextStyle(
                        fontSize: 17,
                        color: ActionColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          split,
          Padding(
            padding: EdgeInsets.all(10),
          ),
          Container(
            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 30),
            width: ScreenUtil.screenWidthDp,
            child: BetterText(
              "薪资水平",
              textAlign: TextAlign.left,
              style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 15),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
            width: ScreenUtil.screenWidthDp,
            child: BetterText(
              item.salaryRange,
              enableSelection: true,
              style: TextStyle(
                color: Color(0xff777777),
                fontSize: 14,
              ),
            ),
          ),
          split,
          Padding(
            padding: EdgeInsets.all(10),
          ),
          Container(
            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 30),
            width: ScreenUtil.screenWidthDp,
            child: BetterText(
              "职位介绍",
              textAlign: TextAlign.left,
              style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 15),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
            child: BetterText(
              item.introduction ?? "暂时没有详情",
              enableSelection: true,
              style: TextStyle(fontSize: 16),
            ),
          ),
          split,
          Container(
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
            child: Wrap(
              direction: Axis.horizontal,
              children: List<Widget>.generate(item.tags.length,
                  (index) => getTag(item.tags[index]?.name ?? "Default")),
            ),
          ),
        ],
      ),
    );
  }

  Widget getTag(String tag) {
    return Builder(
      builder: (context) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 7, vertical: 8),
          padding: EdgeInsets.symmetric(vertical: 3, horizontal: 8),
          decoration: BoxDecoration(
              color: Color.fromARGB(255, 244, 167, 131),
              borderRadius: BorderRadius.circular(15)),
          child: BetterText(
            tag,
            style: TextStyle(color: Colors.white),
          ),
        );
      },
    );
  }

  String getTimeString(DateTime time) {
    Map<int, String> weekdayMap = {
      1: "星期一",
      2: "星期二",
      3: "星期三",
      4: "星期四",
      5: "星期五",
      6: "星期六",
      7: "星期日"
    };
    DateTime now = DateTime.now();
    if (now.year != time.year) {
      return "${time.year}-${time.month}-${time.day}";
    }
    Duration month = Duration(days: 7);
    Duration diff = now.difference(time);
    if (diff.compareTo(month) > 0) {
      return "${time.year}-${_addZero(time.month)}-${_addZero(time.day)}";
    }
    if (now.day == time.day) {
      return "${_addZero(time.hour)}:${_addZero(time.minute)}";
    }
    if (now.add(Duration(days: -1)).day == time.day) {
      return "昨天";
    }
    if (now.add(Duration(days: -2)).day == time.day) {
      return "前天";
    }
    return weekdayMap[time.weekday];
  }

  String _addZero(int value) => value < 10 ? "0$value" : "$value";
}
