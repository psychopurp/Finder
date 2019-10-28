import 'dart:math';

import 'package:dio/dio.dart';
import 'package:finder/config/api_client.dart';
import 'package:finder/config/global.dart';
import 'package:finder/models/topic_comments_model.dart';
import 'package:finder/pages/serve_page/he_says_page.dart';
import 'package:finder/plugin/list_builder.dart';
import 'package:finder/models/recruit_model.dart';
import 'package:finder/public.dart';
import 'package:finder/routers/application.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_easyrefresh/material_footer.dart';
import 'package:flutter_easyrefresh/material_header.dart';
import 'package:flutter_swiper/flutter_swiper.dart';

const Color ActionColorActive = Color(0xFFEC7C6D);
const Color PageBackgroundColor = Color.fromARGB(255, 233, 229, 228);
const Color ActionColor = Color(0xFFDB6B5C);

class RecruitPage extends StatefulWidget {
  @override
  _RecruitPageState createState() => _RecruitPageState();
}

class _RecruitPageState extends State<RecruitPage> {
  List<RecruitModelData> _bannerData = [];
  List<RecruitModelData> _data = [];
  static RecruitTypesModelData all = RecruitTypesModelData(id: 0, name: "全部");
  static List<RecruitTypesModelData> _types = [all];
  static RecruitTypesModelData _nowType = all;
  EasyRefreshController _loadController;
  int _nowPage = 1;
  bool loading = true;
  bool moreThanMoment = false;
  bool hasMore = true;
  String query = "";

  @override
  void initState() {
    super.initState();
    getRecommend();
    getTypes();
    getRecruitsData();
    _loadController = EasyRefreshController();
    Future.delayed(Duration(milliseconds: 200), () {
      setState(() {
        moreThanMoment = true;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _nowType = all;
    _loadController.dispose();
    _types = [all];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            color: Theme.of(context).primaryColor,
            child: RecruitPageHeader(
              onSearch: onSearch,
            ),
          ),
          Expanded(
            flex: 1,
            child: body,
          )
        ],
      ),
    );
  }

  Widget get body {
    Widget child;
    List<Widget> preItems = [];
    if (loading || !moreThanMoment) {
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
    } else if (_bannerData.length == 0 && _data.length == 0) {
      child = Center(
        child: Text("暂时没有数据"),
      );
    } else {
      if (_bannerData.length != 0) {
        preItems.add(banner);
      }
      preItems.add(Filter(onChange: changeType));
      if (_data.length == 0) {
        preItems.add(Center(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 40),
            color: Colors.white,
            width: double.infinity,
            alignment: Alignment.center,
            child: Text(
              "暂时没有找到相关的招募哟~\n重新找找看吧！",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ),
        ));
      }
      child = Padding(
        padding: EdgeInsets.only(top: 5),
        child: EasyRefresh(
          header: MaterialHeader(),
          footer: MaterialFooter(),
          controller: _loadController,
          enableControlFinishLoad: true,
          headerIndex: 0,
          key: ValueKey(child),
          child: listBuilder(preItems, getItem, _data.length),
          onRefresh: () async {
            loading = true;
            _nowPage = 1;
            _bannerData = [];
            await getRecommend();
            _data = [];
            await getRecruitsData();
            loading = false;
          },
          onLoad: () async {
            await getRecruitsData();
            _loadController.finishLoad(success: true, noMore: !hasMore);
          },
        ),
      );
    }

    return AnimatedSwitcher(
        duration: Duration(milliseconds: 1000),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
              child: child,
              opacity:
              CurvedAnimation(curve: Curves.easeInOut, parent: animation));
        },
        child: child);
  }

  Widget get banner {
    return Container(
      padding: EdgeInsets.only(bottom: 15.0),
      height: 250,
      width: double.infinity,
      color: Colors.white,
      child: Swiper(
        itemCount: _bannerData.length,
        autoplay: _bannerData.length > 1,
        onTap: (index) {
          Navigator.pushNamed(context, Routes.recommendRecruitDetail,
              arguments: _bannerData[index]);
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
          RecruitModelData item = _bannerData[index];
          var image = CachedNetworkImage(
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
          );
          return Padding(
            padding: EdgeInsets.only(bottom: 25, left: 10, right: 10),
            child: _bannerData.length > 1
                ? Hero(tag: item.image, child: image)
                : image,
          );
        },
      ),
    );
  }

  Widget getItem(int index) {
    Sender sender = _data[index].sender;
    RecruitModelData item = _data[index];
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
          Row(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(5),
              ),
              MaterialButton(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onPressed: () async {
                  Application.router.navigateTo(context,
                      "${Routes.userProfile}?senderId=${item.sender.id}&heroTag=user:${item.sender.id}-${item.id}");
                },
                padding: EdgeInsets.all(0),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 50,
                      height: 50,
                      child: Hero(
                        tag: "user:${item.sender.id}-${item.id}",
                        child: CachedNetworkImage(
                          placeholder: (context, url) {
                            return Container(
                              padding: EdgeInsets.all(10),
                              child: CircularProgressIndicator(),
                            );
                          },
                          imageUrl: sender.avatar,
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
                      padding: EdgeInsets.only(left: 20),
                      child: Text(
                        sender.nickname,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
            margin: EdgeInsets.symmetric(vertical: 14, horizontal: 15),
            color: Color(0xcceeeeee),
            height: 1,
          ),
          GestureDetector(
            onTap: () {
              Navigator.of(context)
                  .pushNamed(Routes.recruitDetail, arguments: item);
            },
            behavior: HitTestBehavior.opaque,
            child: Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.only(left: 13, bottom: 8),
                  width: ScreenUtil.screenWidthDp,
                  child: Text(
                    item.title,
                    style: TextStyle(
                        color: Color(0xff555555),
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                ),
                Container(
                    padding: EdgeInsets.only(left: 13),
                    width: ScreenUtil.screenWidthDp,
                    child: ContentWidget(
                      content: item.introduction,
                    )),
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

  Future<void> changeType(RecruitTypesModelData type) async {
    setState(() {
      this._data = [];
      this._nowPage = 1;
      _nowType = type;
      this.hasMore = true;
    });
    await getRecruitsData();
  }

  Future getRecruitsData() async {
    var data;
    Map<String, dynamic> query = {'page': _nowPage, 'query': this.query};
    if (_nowType.id != 0) {
      query['type_id'] = _nowType.id;
    }
    data = await apiClient.getRecruits(query);
    RecruitModel recruits = RecruitModel.fromJson(data);
    if (recruits.status) {
      _nowPage += 1;
      hasMore = recruits.hasMore;
      setState(() {
        _data.addAll(recruits.data);
      });
    }
    setState(() {
      loading = false;
    });
  }

  Future<void> getRecommend() async {
    String url = 'get_recommend_recruits/';
    try {
      Dio dio = ApiClient.dio;
      Response response = await dio.get(url);
      Map<String, dynamic> result = response.data;
      if (result["status"]) {
        setState(() {
          _bannerData = List<RecruitModelData>.generate(result["data"].length,
                  (index) => RecruitModelData.fromRecommend(result["data"][index]));
        });
      }
    } on DioError catch (e) {
      print(e);
      print(url);
      setState(() {
        _bannerData = [];
      });
    }
  }

  Future<void> getTypes() async {
    RecruitTypesModel recruitTypes = global.recruitTypes;
    if (recruitTypes.status) {
      _types.addAll(recruitTypes.data);
    }
  }

  Future<void> onSearch(String queryStr) async {
    queryStr = queryStr.trim();
    _nowPage = 1;
    _data = [];
    _nowType = all;
    query = queryStr;
    getRecruitsData();
  }
}

typedef SearchCallBack = void Function(String text);

class RecruitPageHeader extends StatefulWidget implements PreferredSizeWidget {
  RecruitPageHeader({this.onSearch});

  final SearchCallBack onSearch;
  final double height = 56;

  @override
  _RecruitPageHeaderState createState() => _RecruitPageHeaderState();

  @override
  Size get preferredSize => Size.fromHeight(height);
}

class _RecruitPageHeaderState extends State<RecruitPageHeader>
    with SingleTickerProviderStateMixin {
  TextEditingController _searchController;
  AnimationController _animationController;
  Animation _opacityAnimation;
  Animation _positionAnimation;
  FocusNode _focusNode;
  double inputWidth;
  bool open = false;

  @override
  void initState() {
    super.initState();
    inputWidth = ScreenUtil.screenWidthDp - 110;
    _animationController =
    AnimationController(vsync: this, duration: Duration(milliseconds: 400))
      ..addListener(() {
        setState(() {});
      });
    _opacityAnimation = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _positionAnimation = Tween<double>(begin: -inputWidth, end: 80).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _searchController = TextEditingController();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    super.dispose();
    _searchController.dispose();
    _animationController.dispose();
    _focusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      width: double.infinity,
      color: Theme.of(context).primaryColor,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Positioned(
            child: Opacity(
              opacity: _opacityAnimation.value,
              child: Text(
                "招募 · 寻你",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Positioned(
            right: 0,
            child: MaterialButton(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              child: Icon(
                Icons.search,
                size: 30,
                color: Colors.white,
              ),
              onPressed: () {
                if (!open) {
                  _animationController.forward();
                  FocusScope.of(context).requestFocus(_focusNode);
                } else {
                  _animationController.reverse();
                  String text = _searchController.text;
                  _searchController.clear();
                  (widget.onSearch ?? (text) {})(text);
                  _focusNode.unfocus();
                }
                open = !open;
              },
            ),
          ),
          Positioned(
            right: _positionAnimation.value,
            child: Opacity(
              opacity: 1 - _opacityAnimation.value,
              child: Container(
                width: inputWidth,
                child: TextField(
                  focusNode: _focusNode,
                  maxLines: 1,
                  cursorColor: ActionColor,
                  controller: _searchController,
                  decoration: InputDecoration(
                    contentPadding:
                    EdgeInsets.symmetric(vertical: 7, horizontal: 10),
                    filled: true,
                    fillColor: Color.fromARGB(255, 245, 241, 241),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
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
    return "今天";
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

typedef FilterChangeCallBack = void Function(RecruitTypesModelData);

class Filter extends StatefulWidget {
  Filter({this.onChange});

  final FilterChangeCallBack onChange;

  @override
  _FilterState createState() => _FilterState();
}

class _FilterState extends State<Filter> with TickerProviderStateMixin {
  bool isOpen = false;

  List<RecruitTypesModelData> get _types => _RecruitPageState._types;

  RecruitTypesModelData get _nowType => _RecruitPageState._nowType;

  RecruitTypesModelData _tempType;
  AnimationController _animationController;
  AnimationController _rotateController;
  Animation _rotateAnimation;
  Animation _animation;
  Animation _curve;

  double _oldHeight = 0;

  @override
  void initState() {
    super.initState();
    _tempType = _nowType;
    const Duration duration = Duration(milliseconds: 300);
    _animationController = AnimationController(vsync: this, duration: duration);
    _rotateController = AnimationController(vsync: this, duration: duration);
    _animationController.addListener(() {
      setState(() {});
    });
    _curve =
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
    _animation = Tween<double>(begin: 0, end: 1).animate(_curve);
    _rotateAnimation = Tween<double>(begin: 0, end: pi / 2).animate(
        CurvedAnimation(curve: Curves.easeInOut, parent: _rotateController));
  }

  Future<void> changeHeightTo(height) async {
    double oldHeight = _oldHeight;
    _animationController.reset();
    _animation = Tween<double>(begin: oldHeight, end: height).animate(_curve);
    await _animationController.forward();
    _oldHeight = height;
  }

  Future<void> changeHeight() async {
    int length = _types.length; // 获取较大的列表长度
    double height = (length / 3).ceil() * 65.0 + 31;
    await changeHeightTo(height);
  }

  @override
  void dispose() {
    super.dispose();
    _animationController.dispose();
    _rotateController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget child;
    child = Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 20),
      margin: EdgeInsets.symmetric(vertical: 5),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              getTag(_nowType.name),
              Expanded(
                flex: 1,
                child: Container(),
              ),
              MaterialButton(
                onPressed: () {
                  if (!isOpen) {
                    open();
                  } else {
                    close();
                  }
                },
                minWidth: 10,
                padding: EdgeInsets.symmetric(horizontal: 13),
                child: Row(
                  children: <Widget>[
                    Text(
                      "修改分类",
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xff444444),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(3),
                    ),
                    Transform.rotate(
                      angle: _rotateAnimation.value,
                      child: Icon(
                        Icons.arrow_forward_ios,
                        size: 11,
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
          Container(
            height: _animation.value,
            padding: EdgeInsets.symmetric(vertical: 10),
            child: SingleChildScrollView(
              physics: NeverScrollableScrollPhysics(),
              child: Column(
                children: <Widget>[
                  Wrap(
                    children: List<Widget>.generate(
                        _types.length,
                            (index) => GestureDetector(
                          onTap: () {
                            setState(() {
                              _tempType = _types[index];
                            });
                          },
                          child: getTag(_types[index].name,
                              select: _types[index].id == _tempType.id),
                        )),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      MaterialButton(
                        onPressed: () {
                          close();
                        },
                        child: Text(
                          "取消",
                          style: TextStyle(color: Color(0xff999999)),
                        ),
                        minWidth: 10,
                      ),
                      MaterialButton(
                        textColor: Theme.of(context).primaryColor,
                        onPressed: () {
                          (widget.onChange ?? (b) {})(_tempType);
                          close();
                        },
                        child: Text(
                          "确定",
                        ),
                        minWidth: 10,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
    return child;
  }

  Future<void> close() async {
    _rotateController.reverse();
    await changeHeightTo(0.0);
    _tempType = _nowType;
    isOpen = false;
    setState(() {});
  }

  Future<void> open() async {
    _tempType = _nowType;
    _rotateController.forward();
    await changeHeight();
    isOpen = true;
  }

  Widget getTag(String tag, {bool select = true}) {
    return Builder(
      builder: (context) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
          decoration: BoxDecoration(
              color: !select
                  ? Color.fromARGB(255, 204, 204, 204)
                  : Theme.of(context).accentColor,
              borderRadius: BorderRadius.circular(15)),
          child: Text(
            tag,
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
            ),
          ),
        );
      },
    );
  }
}
