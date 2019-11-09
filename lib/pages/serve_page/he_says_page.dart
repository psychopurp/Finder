import 'dart:convert';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:finder/config/api_client.dart';
import 'package:finder/models/he_says_item.dart';
import 'package:finder/plugin/drop_down_text.dart';
import 'package:finder/routers/routes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:finder/routers/application.dart';
import 'package:flutter/services.dart';
import 'package:flutter_swiper/flutter_swiper.dart';

import '../../public.dart';

const Color ActionColor = Color(0xFFDB6B5C);
const Color ActionColorActive = Color(0xFFEC7C6D);
const Color PageBackgroundColor = Color.fromARGB(255, 233, 229, 228);

class HeSaysPage extends StatefulWidget {
  @override
  _HeSaysPageState createState() => _HeSaysPageState();
}

class _HeSaysPageState extends State<HeSaysPage> {
  DateTime _time;
  List<HeSheSayItem> data = [];
  List<HeSheSayItem> bannerData = [];
  bool requestStatus = false;
  bool isRequest = true;
  bool hasMore = true;
  int page = 1;
  int lastPage = 1;
  ScrollController _scrollController;
  String error = "网络连接失败, 请稍后再试";

  set time(DateTime time) {
    setState(() {
      _time = time;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  @override
  void initState() {
    super.initState();
    this.time = new DateTime.now();
    getHeSheSays(delay: true);
    getLeadHeSheSays(delay: true);
    _scrollController = ScrollController();
  }

  Future<void> getHeSheSays({bool delay: false}) async {
    if (delay) {
      await Future.delayed(Duration(milliseconds: 100));
    }
    int timestamp = this._time.millisecondsSinceEpoch ~/ 1000;
    Dio dio = ApiClient.dio;
    try {
      var reqPage = page;
      Response response = await dio.get('get_he_she_say/',
          queryParameters: {"timestamp": timestamp, "page": page});
      Map<String, dynamic> result = response.data;
      setState(() {
        if (result["status"]) {
          data.addAll(List.generate(result["data"].length, (index) {
            var item = HeSheSayItem.fromJson(result["data"][index]);
            return item;
          }));
          requestStatus = true;
          if (hasMore && !result["has_more"]) {
            lastPage = reqPage;
          }
          hasMore = result["has_more"];
        } else {
          requestStatus = false;
          error = result["error"];
        }
        isRequest = false;
      });
    } on DioError catch (e) {
      print(e);
      print(e.response.data.toString());
      setState(() {
        requestStatus = false;
      });
    }
  }

  Future<void> getLeadHeSheSays({bool delay: false}) async {
    if (delay) {
      await Future.delayed(Duration(milliseconds: 100));
    }
    try {
      Dio dio = ApiClient.dio;
      Response response = await dio.get('get_lead_he_she_say/');
      Map<String, dynamic> result = response.data;
      if (result["status"]) {
        setState(() {
          bannerData = List.generate(result["data"].length,
              (index) => HeSheSayItem.fromJson(result["data"][index]));
        });
      }
    } on DioError catch (e) {
      print(e);
      setState(() {
        bannerData = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var appBarColor = Color.fromARGB(255, 95, 95, 95);
    var appBarIconColor = Color.fromARGB(255, 155, 155, 155);
//    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
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
          "他 · 她说",
          style: TextStyle(
            color: appBarColor,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: TimeSelector(time: _time, onSelected: changeDate),
        elevation: 0.5,
        centerTitle: true,
      ),
      backgroundColor: PageBackgroundColor,
      body: Container(
        width: ScreenUtil.screenWidthDp,
        height: ScreenUtil.screenHeightDp,
        child: GestureDetector(
          onHorizontalDragEnd: (detail) {
            double x = detail.primaryVelocity;
            if ((x > 0 ? x : -x) < 500) {
              return;
            }
            if (x < 0) {
              var now = DateTime.now();
              if (_time.day == now.day && _time.difference(now).inHours < 24) {
                BotToast.showText(
                    text: "已经是今天咯~\n明天再来试试吧~", align: Alignment(0, 0.5));
              }else{
                var nextDate = _time.add(Duration(days: 1));
                print(nextDate);
                changeDate(nextDate);
              }
            } else {
              var lastDate = _time.add(Duration(days: -1));
              print(lastDate);
              changeDate(lastDate);
            }
          },
          child: RefreshIndicator(
              onRefresh: refresh,
              child: body),
        ),
      ),
      floatingActionButton: FloatingActionButton(
//        highlightColor: ActionColorActive,
        splashColor: ActionColorActive,
        backgroundColor: ActionColor,
        hoverColor: ActionColorActive,
        focusColor: ActionColorActive,
        foregroundColor: ActionColorActive,
        child: Icon(
          Icons.add,
          color: Colors.white,
          size: 30,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        onPressed: () async {
          await Application.router.navigateTo(context, '/serve/heSays/heSaysPublish');
          refresh();
        },
      ),
    );
  }

  Future<void> refresh() async {
      setState(() {
        data = [];
        page = 1;
        isRequest = true;
      });
      await getLeadHeSheSays();
      await getHeSheSays();
  }

  get body {
    Widget child;
    if (!requestStatus && !isRequest) {
      child = Center(
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(30),
            ),
            Icon(
              Icons.error,
              size: 50,
            ),
            Padding(
              padding: EdgeInsets.all(10),
            ),
            Text(error)
          ],
        ),
      );
    } else if (isRequest) {
      child = Center(
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(30),
            ),
            Container(
              height: 50,
              width: 50,
              child: CircularProgressIndicator(),
            ),
            Padding(
              padding: EdgeInsets.all(10),
            ),
            Text("加载中...")
          ],
        ),
      );
    }
    Widget last = Container(
      color: Colors.white,
      child: Column(children: [
        Center(
          child: hasMore
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      width: 30,
                      height: 30,
                      child: CircularProgressIndicator(),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10),
                    ),
                    Text("加载中"),
                  ],
                )
              : GestureDetector(
                  onTap: () async {
                    await _scrollController.animateTo(0,
                        duration: Duration(milliseconds: 200),
                        curve: Curves.easeOut);
                    setState(() {
                      data = [];
                      page = 1;
                      isRequest = true;
                    });
                    await getLeadHeSheSays();
                    await getHeSheSays();
                  },
                  child: Container(
                    width: double.infinity,
                    color: Colors.white,
                    padding: EdgeInsets.only(top: 10, bottom: 10),
                    alignment: Alignment.center,
                    child: Text("没有更多了"),
                  ),
                ),
        ),
        Container(
          padding: EdgeInsets.only(bottom: 15),
        )
      ]),
    );
    if (bannerData.length == 0 && child == null) {
      child = ListView.builder(
        physics: AlwaysScrollableScrollPhysics(),
        controller: _scrollController,
        itemBuilder: (context, index) {
          if (index == data.length) {
            if (hasMore) {
              page += 1;
              getHeSheSays();
            }
            return last;
          }
          return _itemBuilder(index);
        },
        itemCount: data.length + 1,
      );
    }
    if (child == null)
      child = ListView.builder(
        physics: AlwaysScrollableScrollPhysics(),
        controller: _scrollController,
        itemBuilder: (context, index) {
          if (index == 0) {
            return banner;
          } else if (index == data.length + 1) {
            if (hasMore) {
              page += 1;
              getHeSheSays();
            }
            return last;
          } else {
            return _itemBuilder(index - 1);
          }
        },
        itemCount: data.length + 2,
      );
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 400),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(child: child, opacity: animation);
      },
      child: child,
    );
  }

  Widget _itemBuilder(int index) {
    HeSheSayItem item = data[index];
    final double verticalPadding = 15;
    final double horizontalPadding = 25;
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: index == 0
          ? EdgeInsets.only(
              top: verticalPadding,
              left: horizontalPadding,
              right: horizontalPadding)
          : EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Column(
        children: <Widget>[
          Column(
            children: <Widget>[
              Container(
                child: Row(
                  children: <Widget>[
                    MaterialButton(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onPressed: () {
                        if (item.authorId != 0)
                          Application.router.navigateTo(context,
                              "${Routes.userProfile}?senderId=${item.authorId}&heroTag=${item.authorId}-${item.id}");
                      },
                      padding: EdgeInsets.all(0),
                      child: Row(
                        children: <Widget>[
                          Container(
                            width: 50,
                            height: 50,
                            child: Hero(
                              tag: "${item.authorId}-${item.id}",
                              child: CachedNetworkImage(
                                placeholder: (context, url) {
                                  return Container(
                                    padding: EdgeInsets.all(10),
                                    child: CircularProgressIndicator(),
                                  );
                                },
                                imageUrl: item.authorAvatar,
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
                            child: Text(
                              item.authorName,
                              style: TextStyle(
                                fontSize: 17,
                                color: ActionColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(),
                    ),
                    LikeButton(item.isLike, item.likeCount, (status) {
                      handleLike(item, status);
                    })
                  ],
                ),
              ),
              DropDownTextWidget(content: item.content),
            ],
          ),
          Container(
            constraints: BoxConstraints(
              minWidth: double.infinity,
              minHeight: 1,
            ),
            margin: EdgeInsets.symmetric(vertical: verticalPadding),
            color: PageBackgroundColor,
          )
        ],
      ),
    );
  }

  get banner {
    return Container(
      margin: EdgeInsets.only(top: 0, bottom: 10),
      padding: EdgeInsets.only(bottom: 15.0),
      height: 250,
      width: 400,
      color: Colors.white,
      child: Swiper(
        itemCount: bannerData.length,
        autoplay: bannerData.length > 1,
        onTap: (index) {
          Navigator.pushNamed(context, Routes.heSaysDetail,
              arguments: bannerData[index]);
        },
        pagination: SwiperPagination(
          margin: const EdgeInsets.only(
              top: 10.0, left: 10.0, right: 10.0, bottom: 5.0),
          alignment: Alignment.bottomCenter,
          builder: DotSwiperPaginationBuilder(
            size: 6,
            activeSize: 7,
            activeColor: ActionColorActive,
            color: ActionColor,
          ),
        ),
        itemBuilder: (context, index) {
          HeSheSayItem item = bannerData[index];
          var image = CachedNetworkImage(
            imageUrl: item.image,
            imageBuilder: (context, imageProvider) => Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(3)),
                image: DecorationImage(
                  image: imageProvider,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
          return Padding(
              padding: EdgeInsets.only(bottom: 25, left: 10, right: 10),
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  bannerData.length > 1
                      ? Hero(tag: item.id, child: image)
                      : image,
                  Container(
                    constraints: BoxConstraints(
                        minHeight: double.infinity, minWidth: double.infinity),
                    color: Color.fromARGB(50, 45, 45, 45),
                  ),
                  Container(
                    constraints: BoxConstraints(maxWidth: 300),
                    child: Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: Color.fromARGB(255, 239, 239, 239),
                          fontSize: 30),
                    ),
                  ),
                  Positioned(
                    right: 10,
                    bottom: 15,
                    child: LikeButton(
                      item.isLike,
                      item.likeCount,
                      (status) {
                        handleLike(item, status);
                      },
                      notLikeColor: Color.fromARGB(255, 239, 239, 239),
                    ),
                  )
                ],
              ));
        },
      ),
    );
  }

  handleLike(HeSheSayItem item, bool status) async {
    Dio dio = ApiClient.dio;
    var data = {"like": status, "id": item.id};
    var jsonData = json.encode(data);
    var response = await dio.post("like_he_she_say/", data: jsonData);
    var responseData = response.data;
    if (responseData["status"]) {
      setState(() {
        item.isLike = status;
        if (status) {
          item.likeCount += 1;
        } else {
          item.likeCount -= 1;
        }
      });
    } else {
      BotToast.showText(text: "不要点太快啦!", align: Alignment(0, 0.5));
    }
  }

  changeDate(DateTime time) {
    setState(() {
      this.time = time;
      page = 1;
      isRequest = true;
      data = [];
    });
    getLeadHeSheSays();
    getHeSheSays();
  }
}

typedef TimeSelectedCallback = void Function(DateTime time);
typedef BoolCallback = void Function(bool status);

class TimeSelector extends StatelessWidget implements PreferredSizeWidget {
  TimeSelector({@required this.time, Key key, this.onSelected})
      : super(key: key);
  final DateTime time;
  final TimeSelectedCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Divider(
          height: 1,
        ),
        MaterialButton(
            highlightColor: Colors.white,
            splashColor: Colors.white,
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Align(
                    child: Icon(
                      Icons.today,
                      color: ActionColor,
                      size: 28,
                    ),
                    alignment: Alignment.topRight,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 15, right: 15),
                    child: Text(
                      time.year.toString() +
                          '-' +
                          time.month.toString() +
                          '-' +
                          time.day.toString(),
                      style: TextStyle(fontFamily: 'arail'),
                    ),
                  ),
                  Text(
                    '▼',
                    style: TextStyle(
                      fontSize: 9,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            onPressed: () {
              showDatePicker(
                locale: Locale('zh'),
                context: context,
                initialDate: time,
                firstDate: new DateTime.now().subtract(new Duration(days: 30)),
                // 减 30 天
                lastDate: new DateTime.now(),
              ).then((time) {
                if (this.onSelected != null && time != null) {
                  onSelected(time);
                }
              });
            })
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(40.0);
}

class LikeButton extends StatelessWidget {
  LikeButton(this.isLike, this.likeCount, this.onPressed, {this.notLikeColor});

  final bool isLike;
  final int likeCount;
  final BoolCallback onPressed;
  final Color notLikeColor;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 200),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return ScaleTransition(child: child, scale: animation);
      },
      child: Container(
        key: ValueKey<int>(likeCount),
        child: MaterialButton(
          onPressed: () {
            onPressed(!this.isLike);
          },
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Icon(
                isLike ? Icons.favorite : Icons.favorite_border,
                color: ActionColor,
                size: 28,
              ),
              Padding(
                padding: EdgeInsets.only(left: 5),
              ),
              Text(
                likeCount < 999 ? "$likeCount" : "999+",
                style: TextStyle(
                    color: isLike ? ActionColor : notLikeColor ?? Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
