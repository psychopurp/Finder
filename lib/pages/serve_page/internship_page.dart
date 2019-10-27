import 'dart:math';

import 'package:dio/dio.dart';
import 'package:finder/config/api_client.dart';
import 'package:finder/models/internship_item.dart';
import 'package:finder/plugin/list_builder.dart';
import 'package:finder/public.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_easyrefresh/material_footer.dart';
import 'package:flutter_easyrefresh/material_header.dart';
import 'package:flutter_swiper/flutter_swiper.dart';

const Color ActionColorActive = Color(0xFFEC7C6D);
const Color PageBackgroundColor = Color.fromARGB(255, 233, 229, 228);
const Color ActionColor = Color(0xFFDB6B5C);

class InternshipPage extends StatefulWidget {
  @override
  _InternshipPageState createState() => _InternshipPageState();
}

class _InternshipPageState extends State<InternshipPage> {
  List<InternshipItem> _bannerData = [];
  List<InternshipItem> _data = [];
  static InternshipBigType allBig = InternshipBigType(id: 0, name: "全部");
  static InternshipSmallType allSmall = InternshipSmallType(id: 0, name: "全部");
  static List<InternshipBigType> _bigTypes = [allBig];
  static Map<InternshipBigType, List<InternshipSmallType>> _smallTypes = {
    allBig: [allSmall]
  };
  static InternshipBigType _nowBigType = allBig;
  static InternshipSmallType _nowSmallType = allSmall;
  EasyRefreshController _loadController;
  int _nowPage = 1;
  bool isShow = true;
  bool loading = true;
  bool moreThanMoment = false;
  bool hasMore = true;
  String query = "";

  @override
  void initState() {
    super.initState();
    getRecommend();
    getBigTypes();
    getInternships();
    _loadController = EasyRefreshController();
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        moreThanMoment = true;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _nowBigType = allBig;
    _nowSmallType = allSmall;
    _loadController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isShow) {
      Future<void>.delayed(Duration(milliseconds: 200), () {
        SystemChrome.setSystemUIOverlayStyle(
            SystemUiOverlayStyle(statusBarIconBrightness: Brightness.dark));
      });
    }

    return Scaffold(
      body: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            color: Colors.white,
            child: InternshipPageHeader(
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
              "暂时没有这个类别的实习哟~\n换一个类型看看吧！",
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
            _nowPage = 1;
            _bannerData = [];
            await getRecommend();
            _data = [];
            await getInternships();
          },
          onLoad: () async {
            await getInternships();
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
          Navigator.pushNamed(context, Routes.recommendInternshipDetail,
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
          InternshipItem item = _bannerData[index];
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
    CompanyItem company = _data[index].company;
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
          Row(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(5),
              ),
              MaterialButton(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onPressed: () async {
                  isShow = false;
                  await Navigator.of(context)
                      .pushNamed(Routes.internshipCompany, arguments: item);
                  isShow = true;
                },
                padding: EdgeInsets.all(0),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 50,
                      height: 50,
                      child: Hero(
                        tag: "${company.name}-${item.id}",
                        child: CachedNetworkImage(
                          placeholder: (context, url) {
                            return Container(
                              padding: EdgeInsets.all(10),
                              child: CircularProgressIndicator(),
                            );
                          },
                          imageUrl: company.image,
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
                        company.name,
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
                  .pushNamed(Routes.internshipDetail, arguments: item);
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

  Future<void> changeType(
      InternshipBigType bigType, InternshipSmallType smallType) async {
    this._data = [];
    this._nowPage = 1;
    _nowBigType = bigType;
    _nowSmallType = smallType;
    await getInternships();
  }

  Future<void> getRecommend() async {
    String url = 'get_recommend_internships/';
    try {
      Dio dio = ApiClient.dio;
      Response response = await dio.get(url);
      Map<String, dynamic> result = response.data;
      if (result["status"]) {
        setState(() {
          _bannerData = List<InternshipItem>.generate(result["data"].length,
              (index) => InternshipItem.recommend(result["data"][index]));
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

  Future<void> getBigTypes() async {
    String url = 'get_internship_big_types/';
    try {
      Dio dio = ApiClient.dio;
      Response response = await dio.get(url);
      Map<String, dynamic> result = response.data;
      if (result["status"]) {
        setState(() {
          _bigTypes = [allBig]..addAll(List<InternshipBigType>.generate(
              result["data"].length,
              (index) => InternshipBigType.fromJson(result["data"][index])));
        });
      }
    } on DioError catch (e) {
      print(e);
      print(url);
      setState(() {
        if (_bigTypes == null) {
          _bigTypes = [];
        }
      });
    }
  }

  static Future<void> getSmallTypes(InternshipBigType bigType) async {
    if (_smallTypes.containsKey(bigType)) {
      return;
    }
    String url = 'get_internship_small_types/';
    try {
      Dio dio = ApiClient.dio;
      Response response =
          await dio.get(url, queryParameters: {'big_type_id': bigType.id});
      Map<String, dynamic> result = response.data;
      if (result["status"]) {
        List<InternshipSmallType> smallTypes =
            List<InternshipSmallType>.generate(result["data"].length,
                (index) => InternshipSmallType.fromJson(result["data"][index]));
        _smallTypes[bigType] = smallTypes;
      }
    } on DioError catch (e) {
      print(e);
      print(url);
      if (_smallTypes.containsKey(bigType)) {
        _smallTypes.remove(bigType);
      }
    }
  }

  Future<void> getInternships() async {
    String url = 'get_internships/';
    try {
      Dio dio = ApiClient.dio;
      Map<String, dynamic> query = {'page': _nowPage, 'query': this.query};
      if (_nowSmallType.id != 0) {
        query['small_type_ids'] = _nowSmallType.id;
      }
      Response response = await dio.get(url, queryParameters: query);
      Map<String, dynamic> result = response.data;
      if (result["status"]) {
        setState(() {
          var newData = List<InternshipItem>.generate(result["data"].length,
              (index) => InternshipItem.fromJson(result["data"][index]));
          if (_data == null)
            _data = newData;
          else
            _data.addAll(newData);
        });
        _nowPage += 1;
        hasMore = result['has_more'];
      }
    } on DioError catch (e) {
      print(e);
      print(url);
    }
    loading = false;
  }

  Future<void> onSearch(String queryStr) async {
    queryStr = queryStr.trim();
    _nowPage = 1;
    _data = [];
    _nowSmallType = allSmall;
    _nowBigType = allBig;
    query = queryStr;
    getInternships();
  }
}

typedef SearchCallBack = void Function(String text);

class InternshipPageHeader extends StatefulWidget
    implements PreferredSizeWidget {
  InternshipPageHeader({this.onSearch});

  final SearchCallBack onSearch;
  final double height = 56;

  @override
  _InternshipPageHeaderState createState() => _InternshipPageHeaderState();

  @override
  Size get preferredSize => Size.fromHeight(height);
}

class _InternshipPageHeaderState extends State<InternshipPageHeader>
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
    var appBarColor = Color.fromARGB(255, 95, 95, 95);
    var appBarIconColor = Color.fromARGB(255, 155, 155, 155);
    return Container(
      height: widget.height,
      width: double.infinity,
      color: Colors.white,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Positioned(
              left: 0,
              child: Opacity(
                opacity: _opacityAnimation.value,
                child: MaterialButton(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  child: Icon(
                    Icons.arrow_back_ios,
                    color: appBarIconColor,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              )),
          Positioned(
            child: Opacity(
              opacity: _opacityAnimation.value,
              child: Text(
                "招募 · 实习",
                style: TextStyle(
                  color: appBarColor,
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
                color: appBarIconColor,
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

typedef FilterChangeCallBack = void Function(
    InternshipBigType, InternshipSmallType);

class Filter extends StatefulWidget {
  Filter({this.onChange});

  final FilterChangeCallBack onChange;

  @override
  _FilterState createState() => _FilterState();
}

class _FilterState extends State<Filter> with TickerProviderStateMixin {
  bool isOpen = false;

  List<InternshipBigType> get _bigTypes => _InternshipPageState._bigTypes;

  Map<InternshipBigType, List<InternshipSmallType>> get _smallTypes =>
      _InternshipPageState._smallTypes;

  InternshipBigType get _nowBigType => _InternshipPageState._nowBigType;

  InternshipSmallType get _nowSmallType => _InternshipPageState._nowSmallType;

  InternshipBigType _tempBigType;
  InternshipSmallType _tempSmallType;
  AnimationController _animationController;
  AnimationController _rotateController;
  Animation _rotateAnimation;
  Animation _animation;
  Animation _curve;

  double _oldHeight = 0;

  @override
  void initState() {
    super.initState();
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
    int length = _tempBigType != null
        ? (_smallTypes[_tempBigType]?.length ?? 0) > (_bigTypes?.length ?? 0)
            ? _smallTypes[_tempBigType]?.length ?? 0
            : _bigTypes?.length ?? 0
        : _bigTypes?.length ?? 0; // 获取较大的列表长度
    double height = length * 55.0 + 31;
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
              getTag(_nowBigType.name),
              getTag(_nowSmallType.name),
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
                      "修改职业",
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
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        child: Column(
                            children: List<Widget>.generate(_bigTypes.length,
                                (index) {
                          return Container(
                            padding: EdgeInsets.all(0),
                            child: MaterialButton(
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              elevation: 0,
                              onPressed: () async {
                                _tempBigType = _bigTypes[index];
                                _tempSmallType = null;
                                await _InternshipPageState.getSmallTypes(
                                    _tempBigType);
                                setState(() {});
                                changeHeight();
                              },
                              child: Text(
                                _bigTypes[index].name,
                                style: TextStyle(
                                  color: _tempBigType == _bigTypes[index]
                                      ? Colors.white
                                      : Colors.black,
                                  fontSize: _tempBigType == _bigTypes[index]
                                      ? 15
                                      : 14,
                                ),
                              ),
                            ),
                            decoration: BoxDecoration(
                                color: _tempBigType == _bigTypes[index]
                                    ? Theme.of(context)
                                        .primaryColor
                                        .withOpacity(0.85)
                                    : Colors.white,
                                border: index != _bigTypes.length - 1
                                    ? Border(
                                        bottom: BorderSide(
                                            color: Color(0xffeeeeee)))
                                    : null),
                          );
                        })),
                        decoration: BoxDecoration(
                            border: _tempBigType == null ||
                                    (_bigTypes?.length ?? 0) >
                                        (_smallTypes[_tempBigType]?.length ?? 0)
                                ? Border(
                                    right: BorderSide(
                                        color: Color(0xffeeeeee), width: 1),
                                  )
                                : null),
                      ),
                      Expanded(
                        flex: 1,
                        child: _tempBigType != null
                            ? Container(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.max,
                                  children: _smallTypes
                                          .containsKey(_tempBigType)
                                      ? List<Widget>.generate(
                                          _smallTypes[_tempBigType]?.length ??
                                              0,
                                          (index) {
                                            InternshipSmallType item =
                                                _smallTypes[_tempBigType]
                                                    [index];
                                            return Container(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 0, horizontal: 10),
                                              width: double.infinity,
                                              child: MaterialButton(
                                                splashColor: Colors.transparent,
                                                highlightColor:
                                                    Colors.transparent,
                                                elevation: 0,
                                                onPressed: () async {
                                                  setState(() {
                                                    _tempSmallType = item;
                                                  });
                                                },
                                                child: Text(
                                                  item.name,
                                                  style: TextStyle(
                                                    color:
                                                        _tempSmallType == item
                                                            ? Theme.of(context)
                                                                .primaryColor
                                                            : Color(0xff555555),
                                                  ),
                                                ),
                                              ),
                                              margin: EdgeInsets.only(left: 15),
                                              decoration: BoxDecoration(
                                                  border: index !=
                                                          _smallTypes[_tempBigType]
                                                                  .length -
                                                              1
                                                      ? Border(
                                                          bottom: BorderSide(
                                                              color: Color(
                                                                  0xffeeeeee)))
                                                      : null),
                                            );
                                          },
                                        )
                                      : <Widget>[
                                          Container(
                                            child: CircularProgressIndicator(),
                                          ),
                                          Container(
                                            child: Text("加载中"),
                                          ),
                                        ],
                                ),
                                decoration: BoxDecoration(
                                  border: _tempBigType != null &&
                                          _bigTypes.length <
                                              _smallTypes[_tempBigType].length
                                      ? Border(
                                          left: BorderSide(
                                              color: Color(0xffeeeeee),
                                              width: 1))
                                      : null,
                                ),
                              )
                            : Container(),
                      )
                    ],
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
                        onPressed: _tempSmallType != null
                            ? () {
                                (widget.onChange ?? (b, s) {})(
                                    _tempBigType, _tempSmallType);
                                close();
                              }
                            : null,
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
    _tempSmallType = null;
    _tempBigType = null;
    isOpen = false;
    setState(() {});
  }

  Future<void> open() async {
    _tempBigType = _nowBigType;
    _tempSmallType = _nowSmallType;
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
