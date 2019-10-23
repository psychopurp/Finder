import 'package:dio/dio.dart';
import 'package:finder/config/api_client.dart';
import 'package:finder/plugin/avatar.dart';
import 'package:finder/plugin/list_builder.dart';
import 'package:finder/public.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  List<InternshipBigType> _bigTypes = [];
  Map<InternshipBigType, List<InternshipSmallType>> _smallTypes = {};
  InternshipBigType _nowBigType;
  List<InternshipSmallType> _nowSmallTypes;
  int _nowPage = 1;

  @override
  void initState() {
    super.initState();
    getRecommend();
    getBigTypes();
    getInternships();
  }

  @override
  Widget build(BuildContext context) {
    Future<void>.delayed(Duration(milliseconds: 200), () {
      SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(statusBarIconBrightness: Brightness.dark));
    });
    return Scaffold(
      body: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            color: Colors.white,
            child: InternshipPageHeader(
              onSearch: (text) {
                print(text);
              },
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
    if (_bannerData.length == 0 && _data.length == 0) {
      child = Center(
        child: Text("暂时没有数据"),
      );
    } else {
      if (_bannerData.length != 0) {
        preItems.add(banner);
      }
      child = Padding(
        padding: EdgeInsets.only(top: 5),
        child: listBuilder(preItems, getItem, _data.length),
      );
    }
    return RefreshIndicator(
      child: child,
      onRefresh: () async {},
    );
  }

  get banner {
    return Container(
      padding: EdgeInsets.only(bottom: 15.0),
      height: 250,
      width: double.infinity,
      color: Colors.transparent,
      child: Swiper(
        itemCount: _bannerData.length,
        autoplay: _bannerData.length > 1,
        onTap: (index) {
          Navigator.pushNamed(context, Routes.heSaysDetail,
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
                ? Hero(tag: item.id, child: image)
                : image,
          );
        },
      ),
    );
  }

  Widget getItem(int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 10, left: 5, right: 5),
      width: double.infinity,
      height: 150,
      color: Colors.red,
    );
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
          _bigTypes = List<InternshipBigType>.generate(result["data"].length,
              (index) => InternshipBigType.fromJson(result["data"][index]));
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

  Future<void> getSmallTypes(InternshipBigType bigType) async {
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
        setState(() {
          List<InternshipSmallType> smallTypes =
              List<InternshipSmallType>.generate(
                  result["data"].length,
                  (index) =>
                      InternshipSmallType.fromJson(result["data"][index]));
          _smallTypes[bigType] = smallTypes;
        });
      }
    } on DioError catch (e) {
      print(e);
      print(url);
      setState(() {
        if (_smallTypes.containsKey(bigType)) {
          _smallTypes.remove(bigType);
        }
      });
    }
  }

  Future<void> getInternships() async {
    String url = 'get_internships/';
    try {
      Dio dio = ApiClient.dio;
      Map<String, dynamic> query = {'page': _nowPage};
      if (_nowSmallTypes != null && _nowSmallTypes.length != 0) {
        query['small_type_ids'] = List<int>.generate(
            _nowSmallTypes.length, (index) => _nowSmallTypes[index].id);
      }
      Response response = await dio.get(url, queryParameters: query);
      Map<String, dynamic> result = response.data;
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
    inputWidth = ScreenUtil.screenWidthDp - 120;
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 400))
          ..addListener(() {
            setState(() {});
          });
    _opacityAnimation = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _positionAnimation = Tween<double>(begin: -inputWidth, end: 90).animate(
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

class InternshipItem {
  InternshipItem(
      {this.id,
      this.image,
      this.company,
      this.types,
      this.salaryRange,
      this.tags,
      this.title});

  factory InternshipItem.fromJson(Map<String, dynamic> map) {
    return InternshipItem(
      id: map['id'],
      company: CompanyItem.fromJson(map['company']),
      types: List<InternshipSmallType>.generate((map['types'] ?? []).length,
          (index) => InternshipSmallType.fromJson(map['types'][index])),
      tags: List<InternshipTag>.generate((map['tags'] ?? []).length,
          (index) => InternshipTag.fromJson(map['tags'][index])),
      salaryRange: map['salary_range'],
      title: map['title'],
    );
  }

  factory InternshipItem.recommend(Map<String, dynamic> json) {
    Map<String, dynamic> map = json["internship"];
    return InternshipItem(
      id: map['id'],
      image: Avatar.getImageUrl(json['image']),
      company: CompanyItem.fromJson(map['company']),
      types: List<InternshipSmallType>.generate((map['types'] ?? []).length,
          (index) => InternshipSmallType.fromJson(map['types'][index])),
      tags: List<InternshipTag>.generate((map['tags'] ?? []).length,
          (index) => InternshipTag.fromJson(map['tags'][index])),
      salaryRange: map['salary_range'],
      title: map['title'],
    );
  }

  final int id;
  final String title;
  final String image;
  final CompanyItem company;
  final List<InternshipSmallType> types;
  final List<InternshipTag> tags;
  final String salaryRange;
}

class CompanyItem {
  CompanyItem({this.id, this.name, this.image});

  factory CompanyItem.fromJson(Map<String, dynamic> map) {
    if (map == null) return null;
    return CompanyItem(
        id: map["id"],
        name: map["name"],
        image: Avatar.getImageUrl(map["image"]));
  }

  final int id;
  final String name;
  final String image;
}

class InternshipType {
  InternshipType({this.id, this.name});

  final int id;
  final String name;

  @override
  int get hashCode {
    if (runtimeType == InternshipSmallType) {
      return 1000000000 + id;
    } else {
      return 2000000000 + id;
    }
  }

  @override
  bool operator ==(other) {
    return other.runtimeType == runtimeType && other.id == this.id;
  }
}

class InternshipSmallType extends InternshipType {
  InternshipSmallType({int id, String name}) : super(id: id, name: name);

  factory InternshipSmallType.fromJson(Map<String, dynamic> map) {
    return InternshipSmallType(
      id: map["id"],
      name: map["name"],
    );
  }
}

class InternshipBigType extends InternshipType {
  InternshipBigType({int id, String name}) : super(id: id, name: name);

  factory InternshipBigType.fromJson(Map<String, dynamic> map) {
    return InternshipBigType(
      id: map["id"],
      name: map["name"],
    );
  }
}

class InternshipTag {
  InternshipTag({this.id, this.name});

  factory InternshipTag.fromJson(Map<String, dynamic> map) {
    return InternshipTag(
      id: map["id"],
      name: map["name"],
    );
  }

  final int id;
  final String name;
}
