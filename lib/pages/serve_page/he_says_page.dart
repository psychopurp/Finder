import 'dart:convert';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:finder/config/api_client.dart';
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
  bool requestStatus = true;
  bool isRequest = false;
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
    getHeSheSays();
    getLeadHeSheSays();
    _scrollController = ScrollController();
  }

  Future<void> getHeSheSays() async {
    int timestamp = this._time.millisecondsSinceEpoch ~/ 1000;
    Dio dio = ApiClient.dio;
    try {
      var reqPage = page;
      Response response = await dio.get('get_he_she_say/',
          queryParameters: {"timestamp": timestamp, "page": page});
      Map<String, dynamic> result = response.data;
      setState(() {
        if (result["status"]) {
          data.addAll(List.generate(result["data"].length,
              (index) => HeSheSayItem.fromJson(result["data"][index])));
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

  Future<void> getLeadHeSheSays() async {
    try {
      Dio dio = ApiClient.dio;
      Response response = await dio.get('get_lead_he_she_say/');
      Map<String, dynamic> result = response.data;
      if (result["status"]) {
        setState(() {
          bannerData = List.generate(result["data"].length, (index) {
            var item = HeSheSayItem.fromJson(result["data"][index]);
            item.image = ApiClient.host + item.image;
            return item;
          });
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
        bottom: TimeSelector(
          time: _time,
          onSelected: (time) {
            setState(() {
              this.time = time;
              page = 1;
              isRequest = true;
              data = [];
            });
            getLeadHeSheSays();
            getHeSheSays();
          },
        ),
        elevation: 0.5,
        centerTitle: true,
      ),
      backgroundColor: PageBackgroundColor,
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            data = [];
            page = 1;
            isRequest = true;
          });
          await getLeadHeSheSays();
          await getHeSheSays();
        },
        child: body,
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
        onPressed: () {
          Application.router.navigateTo(context, '/serve/heSays/heSaysPublish');
        },
      ),
    );
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
                        duration: Duration(milliseconds: 200), curve: Curves.easeOut);
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
                      onPressed: () {},
                      padding: EdgeInsets.all(0),
                      child: Row(
                        children: <Widget>[
                          Container(
                            width: 50,
                            height: 50,
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
              ContentWidget(content: item.content),
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
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("提示"),
              content: Text("请先登录再点赞!"),
              actions: <Widget>[
                FlatButton(
                  child: Text("取消"),
                  onPressed: () => Navigator.pop(context),
                ),
                FlatButton(
                  child: Text("确认"),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/login');
                  },
                ),
              ],
            );
          });
    }
  }
}

class ContentWidget extends StatefulWidget {
  ContentWidget({@required this.content});

  final String content;

  @override
  _ContentWidgetState createState() => _ContentWidgetState();
}

class _ContentWidgetState extends State<ContentWidget>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation animation;
  Tween<double> tween;
  bool isShowMore = false;
  bool isMoreText = false;
  int lines;
  double fontSize;
  double maxHeight;
  Duration _defaultDuration = Duration(milliseconds: 200);
  Curve curve = Curves.easeInOut;

  @override
  void initState() {
    super.initState();
    fontSize = 14;
    maxHeight = fontSize * 7.5;
    controller = AnimationController(vsync: this, duration: _defaultDuration);
    double width = 350;
    int lineWords = (width / fontSize).ceil();
    lines = (widget.content.length / lineWords).ceil();
    if (lines < 5) {
      maxHeight = lines * 1.5 * fontSize;
    }
    tween = Tween<double>(begin: maxHeight, end: lines * fontSize * 1.5);
    animation =
        tween.animate(CurvedAnimation(curve: curve, parent: controller));
    animation.addListener(() {
      setState(() {
        maxHeight = animation.value;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget mainContent = Container(
      constraints: BoxConstraints(maxHeight: maxHeight, minHeight: 0),
      margin: EdgeInsets.only(top: 10),
      alignment: Alignment.topLeft,
      child: Text(
        widget.content,
        textAlign: TextAlign.left,
        overflow: TextOverflow.ellipsis,
        maxLines: isMoreText ? 1000 : 5,
        style: TextStyle(fontSize: fontSize),
      ),
    );
    TextStyle style = TextStyle(fontSize: 13, color: Color(0xFFF0AA89));
    return lines < 5
        ? mainContent
        : Column(
            children: <Widget>[
              mainContent,
              Container(
                child: MaterialButton(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  padding: EdgeInsets.all(0),
                  child: isShowMore
                      ? Text(
                          "收起",
                          style: style,
                        )
                      : Text(
                          "查看全文",
                          style: style,
                        ),
                  onPressed: () {
                    setState(() {
                      if (isShowMore) {
                        controller.reverse();
                      } else {
                        controller.forward();
                      }
                      isShowMore = !isShowMore;
                      if (!isMoreText) {
                        isMoreText = true;
                      }
                    });
                    if (!isShowMore) {
                      Future.delayed(_defaultDuration).then((_) {
                        setState(() {
                          isMoreText = !isMoreText;
                        });
                      });
                    }
                  },
                ),
                width: double.infinity,
                alignment: Alignment.topRight,
              )
            ],
          );
  }
}

class HeSheSayItem {
  HeSheSayItem(
      {this.authorAvatar,
      this.authorId,
      this.authorName,
      this.content,
      this.image,
      this.isLike,
      this.likeCount,
      this.title,
      this.id,
      this.time});

  factory HeSheSayItem.fromJson(Map<String, dynamic> map) {
    Map<String, dynamic> author = map["author"];
    String authorAvatar = author["avatar"];
    int authorId = author["id"];
    String authorName = author["nickname"];
    String title = map["title"];
    String content = map["content"];
    String image = map["image"];
    int likeCount = map["like"];
    bool isLike = map["isLike"];
    int id = map["id"];
    String time = map["time"].toString();
    return HeSheSayItem(
        authorName: authorName,
        authorAvatar: authorAvatar,
        authorId: authorId,
        isLike: isLike,
        likeCount: likeCount,
        image: image,
        content: content,
        title: title,
        id: id,
        time: time);
  }

  final int id;
  final String authorName;
  final int authorId;
  final String authorAvatar;
  final String content;
  final String title;
  bool isLike;
  int likeCount;
  String image;
  final String time;
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
