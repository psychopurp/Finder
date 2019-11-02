import 'package:finder/config/api_client.dart';
import 'package:finder/models/activity_model.dart';
import 'package:finder/provider/store.dart';
import 'package:finder/public.dart';
import 'package:finder/routers/application.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_easyrefresh/material_footer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ActivitySearchDelegate extends SearchDelegate<String> {
  ActivitySearchDelegate({
    String hintText,
  }) : super(
          searchFieldLabel: hintText,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.search,
        );
  ActivityModel activityModel;

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.search),
        onPressed: () async {
          // getData(query).then((val){return sho});
          query = "";
          // show
          showSuggestions(context);
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
          icon: AnimatedIcons.menu_arrow, progress: transitionAnimation),
      onPressed: () async {
        if (query.isEmpty) {
          close(context, null);
        } else {
          query = "";
          showSuggestions(context);
        }
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Container(child: Text(query));
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container();
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    assert(context != null);
    final ThemeData theme = Theme.of(context);
    assert(theme != null);
    return theme.copyWith(
        primaryColor: Colors.white,
        primaryIconTheme: theme.primaryIconTheme.copyWith(color: Colors.grey),
        primaryColorBrightness: Brightness.light,
        primaryTextTheme: theme.textTheme,
        indicatorColor: Color.fromRGBO(219, 107, 92, 1),
        textTheme: TextTheme(body1: TextStyle(fontSize: 14)));
  }

  Future getData(String query) async {
    var data = await apiClient.getActivities(query: query);
    ActivityModel activities = ActivityModel.fromJson(data);
    return activities;
  }

  _singleItem(BuildContext context, ActivityModelData item, int index) {
    return CachedNetworkImage(
      imageUrl: item.poster,
      imageBuilder: (context, imageProvider) => InkWell(
        onTap: () {
          Application.router.navigateTo(
              context, "${Routes.activityDetail}?activityId=${item.id}");
        },
        child: Align(
          alignment: Alignment.topCenter,
          child: Container(
            // margin: EdgeInsets.only(
            //   left: ScreenUtil().setWidth(40),
            //   right: ScreenUtil().setWidth(40),
            // ),
            height: ScreenUtil().setHeight(400),
            width: ScreenUtil().setWidth(670),
            decoration: BoxDecoration(
                // color: Colors.blue,
                border: Border(bottom: BorderSide(color: Colors.black12))),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                    height: ScreenUtil().setHeight(320),
                    width: ScreenUtil().setWidth(250),
                    decoration: BoxDecoration(
                      // color: Colors.green,
                      borderRadius: BorderRadius.all(Radius.circular(3)),
                      // border: Border.all(color: Colors.black, width: 2),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black38,
                            offset: Offset(-1.0, 2.0),
                            blurRadius: 2.0,
                            spreadRadius: 1.0),
                      ],
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover,
                      ),
                    )),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Container(
                      // color: Colors.cyan,
                      width: ScreenUtil().setWidth(420),
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        item.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: ScreenUtil().setSp(30),
                            fontWeight: FontWeight.lerp(
                                FontWeight.w400, FontWeight.w800, 0.8)),
                      ),
                    ),
                    Container(
                      // color: Colors.amber,
                      width: ScreenUtil().setWidth(420),
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        item.startTime.split(" ")[0].replaceAll('-', '.') +
                            "-" +
                            item.endTime.split(' ')[0].replaceAll('-', '.'),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: ScreenUtil().setSp(30),
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    Container(
                      // color: Colors.amber,
                      // margin: EdgeInsets.only(top: ScreenUtil().setHeight(20)),
                      width: ScreenUtil().setWidth(420),
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        item.place,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: ScreenUtil().setSp(25),
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(
                        right: ScreenUtil().setWidth(40),
                        // top: ScreenUtil().setHeight(20)),
                      ),
                      padding: EdgeInsets.all(7),
                      decoration: BoxDecoration(
                          // color: Colors.amber,
                          border: Border.all(color: Color(0xFFF0AA89)),
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                      child: Text(
                        "  详情  ",
                        style: TextStyle(
                            fontSize: ScreenUtil().setSp(22),
                            color: Color(0xFFF0AA89)),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
      errorWidget: (context, url, error) => Icon(Icons.error),
    );
  }
}

class ActivitySearchPage extends StatefulWidget {
  @override
  _ActivitySearchPageState createState() => _ActivitySearchPageState();
}

class _ActivitySearchPageState extends State<ActivitySearchPage> {
  List<ActivityModelData> activities = [];
  bool loading = true;
  bool hasMore = true;
  bool isSearch = false;

  EasyRefreshController _refreshController;
  TextEditingController _controller;
  static const int ONSEARCH = 0;
  static const int NOTDOING = 1; //什么都不做
  int curruntState = -1;
  int pageCount = 2;

  // static cosnt int

  @override
  void initState() {
    _refreshController = EasyRefreshController();
    _controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        // centerTitle: true,
        automaticallyImplyLeading: false,
        title: TextField(
          controller: _controller,
          cursorColor: Theme.of(context).primaryColor, //设置光标
          decoration: InputDecoration(
              //输入框decoration属性
              contentPadding: EdgeInsets.only(top: 15),
              // contentPadding: new EdgeInsets.only(left: 0.0),
              fillColor: Theme.of(context).dividerColor,
              filled: true,
              border: InputBorder.none,
              prefixIcon: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(Icons.arrow_back, color: Colors.black),
              ),
              suffixIcon: IconButton(
                  icon: Icon(Icons.search, color: Colors.black),
                  onPressed: () {
                    if (this.curruntState == ONSEARCH) {
                      this.activities.clear();
                      this.loading = true;
                    }
                    getData();
                    setState(() {});
                  }),
              hintText: "来搜搜你喜欢的活动..",
              hintStyle: new TextStyle(fontSize: 14, color: Colors.black45)),
          style: new TextStyle(fontSize: 14, color: Colors.black),
        ),
      ),
      body: body,
    );
  }

  Widget get body {
    Widget child;
    switch (this.curruntState) {
      case NOTDOING:
        child = Container();
        break;
      case ONSEARCH:
        if (loading) {
          child = Container(
              alignment: Alignment.center,
              height: double.infinity,
              child: CupertinoActivityIndicator());
        } else {
          child = EasyRefresh.custom(
            enableControlFinishLoad: true,
            footer: MaterialFooter(),
            controller: _refreshController,
            onLoad: () async {
              await Future.delayed(Duration(milliseconds: 500), () {
                getMore(pageCount: this.pageCount);
              });
              _refreshController.finishLoad(
                  success: true, noMore: (!this.hasMore));
            },
            // scrollController: _scrollController,
            slivers: <Widget>[
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return buildActivityList(this.activities[index]);
                  },
                  childCount: this.activities.length,
                ),
              ),
            ],
          );
        }
        break;
      default:
    }

    return child;
  }

  buildActivityList(ActivityModelData item) {
    Widget child;
    child = Container(
      // margin: EdgeInsets.only(
      //   left: ScreenUtil().setWidth(40),
      //   right: ScreenUtil().setWidth(40),
      // ),
      padding: EdgeInsets.only(left: 20),
      height: ScreenUtil().setHeight(400),
      width: ScreenUtil().setWidth(670),
      decoration: BoxDecoration(
          // color: Colors.blue,
          border: Border(bottom: BorderSide(color: Colors.black12))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
              height: ScreenUtil().setHeight(320),
              width: ScreenUtil().setWidth(250),
              decoration: BoxDecoration(
                // color: Colors.green,
                borderRadius: BorderRadius.all(Radius.circular(3)),
                // border: Border.all(color: Colors.black, width: 2),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black38,
                      offset: Offset(-1.0, 2.0),
                      blurRadius: 2.0,
                      spreadRadius: 1.0),
                ],
                image: DecorationImage(
                  image: CachedNetworkImageProvider(item.poster),
                  fit: BoxFit.cover,
                ),
              )),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Container(
                // color: Colors.cyan,
                width: ScreenUtil().setWidth(420),
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: ScreenUtil().setSp(30),
                      fontWeight: FontWeight.lerp(
                          FontWeight.w400, FontWeight.w800, 0.8)),
                ),
              ),
              Container(
                // color: Colors.amber,
                width: ScreenUtil().setWidth(420),
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  item.startTime.split(" ")[0].replaceAll('-', '.') +
                      "-" +
                      item.endTime.split(' ')[0].replaceAll('-', '.'),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: ScreenUtil().setSp(30),
                      fontWeight: FontWeight.w500),
                ),
              ),
              Container(
                // color: Colors.amber,
                // margin: EdgeInsets.only(top: ScreenUtil().setHeight(20)),
                width: ScreenUtil().setWidth(420),
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  item.place,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: ScreenUtil().setSp(25),
                      fontWeight: FontWeight.w500),
                ),
              ),
              Container(
                margin: EdgeInsets.only(
                  right: ScreenUtil().setWidth(40),
                  // top: ScreenUtil().setHeight(20)),
                ),
                padding: EdgeInsets.all(7),
                decoration: BoxDecoration(
                    // color: Colors.amber,
                    border: Border.all(color: Color(0xFFF0AA89)),
                    borderRadius: BorderRadius.all(Radius.circular(20))),
                child: Text(
                  "  详情  ",
                  style: TextStyle(
                      fontSize: ScreenUtil().setSp(22),
                      color: Color(0xFFF0AA89)),
                ),
              )
            ],
          )
        ],
      ),
    );

    child = GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, Routes.activityDetail, arguments: item);
        },
        child: child);

    return child;
  }

  Future getData() async {
    String query = (_controller.text != null || _controller.text != "")
        ? _controller.text
        : "";
    // print(query);
    var data = await apiClient.getActivities(query: query, page: 1);
    // print(data);
    ActivityModel activities = ActivityModel.fromJson(data);

    setState(() {
      this.activities.addAll(activities.data);
      this.curruntState = ONSEARCH;
      this.loading = false;
      this.hasMore = activities.hasMore;
    });
  }

  Future getMore({int pageCount}) async {
    String query = _controller.text ?? "";
    var data = await apiClient.getActivities(query: query, page: pageCount);
    ActivityModel activities = ActivityModel.fromJson(data);

    setState(() {
      this.activities.addAll(activities.data);
      this.pageCount = this.pageCount + 1;
      this.curruntState = ONSEARCH;
      this.loading = false;
      this.hasMore = activities.hasMore;
    });
  }
}
