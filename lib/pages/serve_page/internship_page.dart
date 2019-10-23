import 'package:dio/dio.dart';
import 'package:finder/config/api_client.dart';
import 'package:finder/plugin/avatar.dart';
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
  List<InternshipItem> bannerData = [];
  List<InternshipItem> data = [InternshipItem(id: 0)];

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
          body
        ],
      ),
    );
  }

  Widget get body => ListView.builder(
        itemBuilder: (context, index) {
          if (index == 0) {
            return banner;
          }
          return getItem(index - 1);
        },
        itemCount: data.length + 1,
      );

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
          InternshipItem item = bannerData[index];
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
            child: bannerData.length > 1
                ? Hero(tag: item.id, child: image)
                : image,
          );
        },
      ),
    );
  }

  Widget getItem(int index) {
    return null;
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
              (index) => InternshipItem.fromJson(result["data"][index]));
        });
      }
    } on DioError catch (e) {
      print(e);
      setState(() {
        bannerData = [];
      });
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
              )),
        ],
      ),
    );
  }
}

class InternshipItem {
  InternshipItem(
      {this.id, this.image, this.company, this.types, this.salaryRange});

  factory InternshipItem.fromJson(Map<String, dynamic> map) {
    return InternshipItem(
        id: map['id'],
        image: Avatar.getImageUrl(map['image']),
        company: CompanyItem.fromJson(map['company']),
        types: List<InternshipType>.generate(map['types'].length,
            (index) => InternshipType.fromJson(map['types'][index])),
        salaryRange: map['salary_range']);
  }

  final int id;
  final String image;
  final CompanyItem company;
  final List<InternshipType> types;
  final String salaryRange;
}

class CompanyItem {
  CompanyItem({this.id, this.name, this.image});

  factory CompanyItem.fromJson(Map<String, dynamic> map) {
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

  factory InternshipType.fromJson(Map<String, dynamic> map) {
    return InternshipType(
      id: map["id"],
      name: map["name"],
    );
  }

  final int id;
  final String name;
}
