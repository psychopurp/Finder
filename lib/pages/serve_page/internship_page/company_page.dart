import 'dart:collection';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:finder/config/api_client.dart';
import 'package:finder/models/internship_item.dart';
import 'package:finder/pages/serve_page/internship_page.dart';
import 'package:finder/public.dart';
import 'package:flutter/material.dart';

const double AppBarHeight = 330;

class CompanyRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    InternshipItem item = ModalRoute.of(context).settings.arguments;
    return CompanyPage(item);
  }
}

class CompanyPage extends StatefulWidget {
  CompanyPage(this.item) : company = item.company;

  final CompanyItem company;
  final InternshipItem item;

  @override
  _CompanyPageState createState() => _CompanyPageState();
}

class _CompanyPageState extends State<CompanyPage>
    with SingleTickerProviderStateMixin {
  CompanyDetail company;
  bool loading = true;
  List<InternshipItem> _data = [];
  ScrollController _detailScrollController;
  ScrollController _internshipScrollController;
  AnimationController _animationController;
  Animation _animation1;
  Animation _animation2;
  Animation _curvedAnimation;
  double moveOffset = 0;
  int selected = 0;
  double leftPosition;
  double rightPosition;
  double offset;
  Offset initOffset;
  bool moveHorizontal = false;
  bool isLeft = false;
  bool tapping = false;
  Queue<double> fiveTicker = Queue<double>();
  Offset lastOffset;
  bool moveFirst = true;
  bool moving = false;

  void syncScrollController(int index) {
    double maxOffset = AppBarHeight - MediaQuery.of(context).padding.top - 110;
    if (index == 0) {
      if (selected == 0) {
        if (_detailScrollController.offset < maxOffset) {
          _internshipScrollController.jumpTo(_detailScrollController.offset);
        } else if (_internshipScrollController.offset < maxOffset) {
          _internshipScrollController.jumpTo(maxOffset);
        }
      }
    } else {
      if (selected == 1) {
        if (_internshipScrollController.offset < maxOffset) {
          _detailScrollController.jumpTo(_internshipScrollController.offset);
        } else if (_detailScrollController.offset < maxOffset) {
          _detailScrollController.jumpTo(maxOffset);
        }
      }
    }
  }

  void handleTapDown(PointerDownEvent event) {
    initOffset = event.position;
    lastOffset = initOffset;
  }

  double abs(double x) {
    return x < 0 ? -x : x;
  }

  void handleTapMove(PointerMoveEvent event) {
    if (initOffset != null && !tapping) {
      Offset now = event.position;
      Offset sub = now - initOffset;
      if (abs(sub.dx) > abs(sub.dy)) {
        moveHorizontal = true;
        if (sub.dx < 0) {
          isLeft = true;
        }
      }
      tapping = true;
    }
    if (moveHorizontal) {
      Offset now = event.position;
      Offset sub = now - initOffset;
      double dx = sub.dx;
      fiveTicker.add((now - lastOffset).dx);
      lastOffset = now;
      if (fiveTicker.length > 5) {
        fiveTicker.removeFirst();
      }
      if (!isLeft) {
        if (selected == 0) {
          return;
        } else {
          setState(() {
            leftPosition = -ScreenUtil.screenWidthDp + dx;
            rightPosition = dx;
          });
        }
      } else {
        if (selected == 1) {
          return;
        } else {
          setState(() {
            leftPosition = dx;
            rightPosition = ScreenUtil.screenWidthDp + dx;
          });
        }
      }
    }
  }

  void handleTapUp(PointerUpEvent event) {
    if (moveHorizontal) {
      Offset now = event.position;
      Offset sub = now - initOffset;
      double dx = sub.dx;
      double lastDx = 0;
      for (double i in fiveTicker) {
        lastDx += i;
      }
      fiveTicker.clear();
      if (isLeft) {
        if (dx > 0 || lastDx > 0) {
          moveToLeft();
        } else {
          setState(() {
            selected = 1;
          });
          moveToRight();
        }
      } else {
        if (dx < 0 || lastDx < 0) {
          moveToRight();
        } else {
          setState(() {
            selected = 0;
          });
          moveToLeft();
        }
      }
    }
    initOffset = null;
    tapping = false;
    moveHorizontal = false;
    isLeft = false;
  }

  _moveListener() {
    setState(() {
      leftPosition = _animation1.value;
      rightPosition = _animation2.value;
    });
  }

  Future<void> moveToRight() async {
    double left = leftPosition;
    double right = rightPosition;
    _animation1 = Tween<double>(begin: left, end: -ScreenUtil.screenWidthDp)
        .animate(_curvedAnimation);
    _animation2 = Tween<double>(begin: right, end: 0).animate(_curvedAnimation);
    _animationController.reset();
    await _animationController.forward();
  }

  Future<void> moveToLeft() async {
    double left = leftPosition;
    double right = rightPosition;
    _animation1 = Tween<double>(begin: left, end: 0).animate(_curvedAnimation);
    _animation2 = Tween<double>(begin: right, end: ScreenUtil.screenWidthDp)
        .animate(_curvedAnimation);
    _animationController.reset();
    _animationController.forward();
  }

  @override
  void initState() {
    super.initState();
    getDetail();
    getInternships();
    _detailScrollController = ScrollController();
    _internshipScrollController = ScrollController();
    _detailScrollController.addListener(() {
      setState(() {
        if (selected == 0) offset = _detailScrollController.offset;
        syncScrollController(0);
      });
    });
    _internshipScrollController.addListener(() {
      setState(() {
        if (selected == 1) offset = _internshipScrollController.offset;
        syncScrollController(1);
      });
    });
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200));
    leftPosition = 0;
    rightPosition = ScreenUtil.screenWidthDp;
    _curvedAnimation =
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
    _animationController.addListener(_moveListener);
  }

  @override
  void dispose() {
    super.dispose();
    _detailScrollController.dispose();
    _internshipScrollController.dispose();
    _animationController.dispose();
  }

  Widget getItem(int index) {
    InternshipItem item = _data[index];
    return Container(
      margin: EdgeInsets.only(bottom: 10, left: 5, right: 5),
      padding: EdgeInsets.symmetric(horizontal: 15),
      width: double.infinity,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(10),
          ),
          GestureDetector(
            onTap: () {
              Navigator.of(context)
                  .pushNamed(Routes.internshipDetail, arguments: item);
            },
            behavior: HitTestBehavior.opaque,
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      width: ScreenUtil.screenWidthDp - 140,
                      padding: EdgeInsets.only(left: 13, bottom: 8),
                      child: Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: Color(0xff555555),
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(),
                    ),
                    Padding(
                      padding: EdgeInsets.only(right: 10),
                      child: Text(
                        getTimeString(item.time),
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 14,
                          color: ActionColor,
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.only(left: 13),
                  width: ScreenUtil.screenWidthDp,
                  child: Text(
                    item.salaryRange,
                    style: TextStyle(
                      color: Color(0xff777777),
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.only(top: 10),
            child: Wrap(
              direction: Axis.horizontal,
              children: List<Widget>.generate(item.tags.length,
                  (index) => getTag(item.tags[index]?.name ?? "Default")),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(15),
          )
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
          child: Text(
            tag,
            style: TextStyle(color: Colors.white),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Stack(
        children: <Widget>[
          Positioned(
            bottom: 0,
            child: Container(
              height: ScreenUtil.screenHeightDp - AppBarHeight + (offset ?? 0),
              width: ScreenUtil.screenWidthDp,
              color: Colors.white,
            ),
          ),
          Stack(
            children: <Widget>[
              Positioned(
                left: leftPosition,
                child: Container(
                  child: details,
                  width: ScreenUtil.screenWidthDp,
                  height: ScreenUtil.screenHeightDp,
                ),
              ),
              Positioned(
                left: rightPosition,
                child: Container(
                  child: internships,
                  width: ScreenUtil.screenWidthDp,
                  height: ScreenUtil.screenHeightDp,
                ),
              )
            ],
          ),
          Positioned(
            bottom: 0,
            child: Listener(
              behavior: moveHorizontal
                  ? HitTestBehavior.opaque
                  : HitTestBehavior.translucent,
              onPointerDown: handleTapDown,
              onPointerUp: handleTapUp,
              onPointerMove: handleTapMove,
              child: Container(
                width: ScreenUtil.screenWidthDp,
                height:
                    ScreenUtil.screenHeightDp - AppBarHeight + (offset ?? 0),
              ),
            ),
          ),
          CompanyPageHeader(
            company: company,
            companyMainInfo: widget.company,
            itemId: widget.item.id,
            selected: selected,
            offset: offset,
            leftOffset: leftPosition,
            onChange: (index) {
              if (index == 0 && selected == 1) {
                selected = 0;
                moveToLeft();
              } else if (index == 1 && selected == 0) {
                selected = 1;
                moveToRight();
              }
            },
          ),
          loading
              ? Container(
                  width: double.infinity,
                  height: double.infinity,
                  child: Listener(
                    behavior: HitTestBehavior.opaque,
                    child: UnconstrainedBox(
                      child: Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            CircularProgressIndicator(),
                            Padding(
                              padding: EdgeInsets.all(10),
                            ),
                            Text("加载中..."),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }

  Widget get listTopItem => Container(
        height: AppBarHeight - MediaQuery.of(context).padding.top,
        width: ScreenUtil.screenWidthDp,
        color: Colors.transparent,
      );

  Widget get internships => ListView.builder(
        itemBuilder: (context, index) {
          if (index == 0)
            return listTopItem;
          else
            return getItem(index - 1);
        },
        itemCount: _data.length + 1,
        controller: _internshipScrollController,
      );

  Widget get details => ListView(
        children: <Widget>[
          listTopItem,
        ]..addAll(detailItems),
        controller: _detailScrollController,
      );

  List<Widget> get detailItems {
    List<String> tabs = ["公司简介", "公司介绍", "公司地址", "公司网址"];
    List<String> infos = [
      company?.briefIntroduction ?? "",
      company?.introduction ?? "",
      company?.address ?? "",
      company?.website ?? "暂时没有网址哟~"
    ];
    return List<Widget>.generate(4, (index) {
      String text = tabs[index];
      String info = infos[index];
      return Container(
        padding: EdgeInsets.all(15),
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              text,
              textAlign: TextAlign.left,
              style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 15),
            ),
            Padding(
              padding: EdgeInsets.all(8),
            ),
            Text(
              info,
              style: TextStyle(color: Color(0xff444444)),
            ),
            Padding(
              padding: EdgeInsets.all(10),
            ),
          ],
        ),
      );
    })
      ..insert(
          0,
          Container(
            color: Colors.white,
            padding: EdgeInsets.all(10),
          ));
  }

  Future<void> getDetail() async {
    String url = 'get_companies/';
    try {
      Dio dio = ApiClient.dio;
      Response response = await dio
          .get(url, queryParameters: {'company_id': widget.company.id});
      Map<String, dynamic> result = response.data;
      if (result["status"]) {
        setState(() {
          company = CompanyDetail.fromJson(result['data'][0]);
        });
      }
    } on DioError catch (e) {
      print(e);
      print(url);
    }
    setState(() {
      loading = false;
    });
  }

  Future<void> getInternships() async {
    String url = 'get_company_internships/';
    try {
      Dio dio = ApiClient.dio;
      Map<String, dynamic> query = {'company_id': widget.company.id};
      Response response = await dio.get(url, queryParameters: query);
      Map<String, dynamic> result = response.data;
      print(result);
      if (result["status"]) {
        setState(() {
          _data = List<InternshipItem>.generate(result["data"].length,
              (index) => InternshipItem.fromJson(result["data"][index]));
        });
      }
    } on DioError catch (e) {
      print(e);
      print(url);
    }
    loading = false;
  }
}

typedef ChangeCallback = void Function(int index);

class CompanyPageHeader extends StatelessWidget {
  CompanyPageHeader(
      {@required this.selected,
      @required this.companyMainInfo,
      @required this.company,
      this.offset = 0,
      this.itemId,
      this.tabs = const ["公司详情", "现有职位"],
      this.onChange,
      this.leftOffset});

  final CompanyDetail company;
  final ChangeCallback onChange;
  final CompanyItem companyMainInfo;
  final int selected;
  final List<String> tabs;
  final int itemId;
  final double offset;
  final double leftOffset;

  @override
  Widget build(BuildContext context) {
    double offset = this.offset ?? 0;
    double maxTabsBottom =
        AppBarHeight - MediaQuery.of(context).padding.top - 110;
    double tabsBottom = offset > maxTabsBottom ? maxTabsBottom : offset;
    double textLeft = 65 * (maxTabsBottom - tabsBottom) / maxTabsBottom + 75;
    double textTop = 80 * (maxTabsBottom - tabsBottom) / maxTabsBottom +
        10 +
        MediaQuery.of(context).padding.top;
    double avatarOpacity = (maxTabsBottom - 2 * tabsBottom) / maxTabsBottom;
    avatarOpacity = avatarOpacity < 0 ? 0 : avatarOpacity;
    double bottomLeft = ScreenUtil.screenWidthDp / 2 -
        30 -
        ((leftOffset + ScreenUtil.screenWidthDp) / ScreenUtil.screenWidthDp -
                0.5) *
            132;
    TextStyle unSelectedStyle = TextStyle(
      fontSize: 15,
      color: Color(0xff555555),
    );
    TextStyle selectedStyle = TextStyle(
      fontSize: 15,
      color: Theme.of(context).primaryColor.withOpacity(0.8),
    );
    List<Widget> tabsWidgets = List<Widget>.generate(
        tabs.length,
        (index) => MaterialButton(
              onPressed: () {
                if (onChange != null) onChange(index);
              },
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              child: Text(
                tabs[index],
                style: index == selected ? selectedStyle : unSelectedStyle,
              ),
            ));
    for (int i = 0; i < tabsWidgets.length - 1; i += 2) {
      tabsWidgets.insert(
          i + 1,
          Padding(
            padding: EdgeInsets.all(20),
          ));
    }
    Widget topBar = Positioned(
      left: 0,
      child: Container(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        width: ScreenUtil.screenWidthDp,
        color: Theme.of(context).primaryColor,
        alignment: Alignment.centerLeft,
        child: MaterialButton(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
    Widget avatar = Container(
      width: 74,
      height: 74,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(37)),
        color: Colors.white,
      ),
      child: Hero(
        tag: "${companyMainInfo.name}-$itemId",
        child: CachedNetworkImage(
          placeholder: (context, url) {
            return Container(
              padding: EdgeInsets.all(10),
              child: CircularProgressIndicator(),
            );
          },
          imageUrl: companyMainInfo.image,
          errorWidget: (context, url, err) {
            return Container(
              child: Icon(
                Icons.cancel,
                size: 70,
                color: Colors.grey,
              ),
            );
          },
          imageBuilder: (context, imageProvider) {
            return Padding(
              padding: EdgeInsets.all(2),
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(35)),
                  image: DecorationImage(
                    image: imageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
    avatar = Opacity(
      child: avatar,
      opacity: avatarOpacity,
    );

    Widget companyName = Row(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(left: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                companyMainInfo.name,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              Text(
                company == null ? "" : "${company.type} / ${company.size}人",
                style: TextStyle(
                    color: Color(0xffeeeeee).withOpacity(avatarOpacity),
                    fontSize: 12),
              )
            ],
          ),
        ),
      ],
    );
    return Container(
      width: ScreenUtil.screenWidthDp,
      height: AppBarHeight,
      child: Stack(
        children: <Widget>[
          Positioned(
            top: textTop - 17,
            left: textLeft - 80,
            child: avatar,
          ),
          Positioned(
            bottom: tabsBottom,
            child: Stack(
              children: <Widget>[
                Container(
                  width: ScreenUtil.screenWidthDp,
                  height: 90,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30)),
                ),
                Positioned(
                  bottom: 0,
                  child: Container(
                    width: ScreenUtil.screenWidthDp,
                    height: 60,
                    color: Colors.white,
                    child: Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: tabsWidgets,
                        ),
                        Positioned(
                          bottom: 10,
                          left: bottomLeft,
                          child: Container(
                              width: 60,
                              height: 4,
                              color: Theme.of(context)
                                  .primaryColor
                                  .withOpacity(0.5)),
                        ),
                        Positioned(
                          bottom: 0,
                          child: Container(
                            color: Theme.of(context).primaryColor,
                            width: ScreenUtil.screenWidthDp,
                            height: 1,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          topBar,
          Positioned(top: textTop, left: textLeft, child: companyName),
        ],
      ),
    );
  }
}

class CompanyDetail {
  CompanyDetail(
      {this.id,
      this.name,
      this.briefIntroduction,
      this.tags,
      this.address,
      this.introduction,
      this.size,
      this.type,
      this.website,
      this.city,
      this.province});

  factory CompanyDetail.fromJson(Map<String, dynamic> map) {
    return CompanyDetail(
        id: map['id'],
        name: map['name'],
        briefIntroduction: map['brief_introduction'],
        introduction: map['introduction'],
        city: map['city']['name'],
        province: map['city']['province'],
        address: map['address'],
        website: map['website'],
        size: map['size'],
        type: map["type"]);
  }

  final int id;
  final String name;
  final String briefIntroduction;
  final String introduction;
  final String city;
  final String province;
  final String address;
  final String website;
  final String size;
  final String type;
  final List<InternshipTag> tags;
}
