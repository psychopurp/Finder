import 'package:finder/plugin/callback.dart';
import 'package:finder/provider/store.dart';
import 'package:finder/routers/application.dart';
import 'package:flutter/material.dart';
import 'package:finder/public.dart';
import 'package:finder/models/topic_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:finder/config/api_client.dart';
import 'package:flutter/rendering.dart';

//easyrefresh
import 'package:flutter_easyrefresh/easy_refresh.dart';

// import 'package:flutter_easyrefresh/bezier_circle_header.dart';
// import 'package:flutter_easyrefresh/bezier_bounce_footer.dart';
import 'package:flutter_easyrefresh/material_header.dart';
import 'package:flutter_easyrefresh/material_footer.dart';

/// 此页面定义了三个statefull 页面

/// MoreTopics -父页面

/// Topics

class MoreTopics extends StatefulWidget {
  @override
  _MoreTopicsState createState() => _MoreTopicsState();
}

class _MoreTopicsState extends State<MoreTopics>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  bool atHear = true;

  Future<void> push(FutureCallback code) async {
    atHear = false;
    if (code != null) {
      await code();
    }
    atHear = true;
  }

  @override
  void initState() {
    _tabController = new TabController(vsync: this, length: 2);
    super.initState();
  }

  @override
  void dispose() {
    _TopicsState.interSchoolTopics = null;
    _TopicsState.schoolTopics = null;
    _TopicsState.schoolOffset = 0;
    _TopicsState.interSchoolOffset = 0;
    _TopicsState.schoolPageCount = 0;
    _TopicsState.interSchoolPageCount = 0;
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!atHear)
      return Scaffold(
        appBar: AppBar(
          title: const Text("话题"),
        ),
      );
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
            "话题",
            style: TextStyle(
              color: appBarColor,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          elevation: 0.5,
          centerTitle: true,
          bottom: new TabBar(
            labelStyle: TextStyle(fontSize: 16),
            isScrollable: true,
            labelColor: appBarColor,
            labelPadding: EdgeInsets.symmetric(horizontal: 30),
            indicatorColor: Theme.of(context).primaryColor,
            indicatorWeight: 3,
            tabs: <Widget>[
              new Tab(
                child: Text(
                  '校内',
                  // style: TextStyle(
                  //     fontSize: ScreenUtil().setSp(30),
                  //     fontWeight: FontWeight.w500),
                ),
              ),
              new Tab(
                child: Text(
                  '校际',
                  // style: TextStyle(
                  //     fontSize: ScreenUtil().setSp(30),
                  //     fontWeight: FontWeight.w500),
                ),
              ),
            ],
            controller: _tabController,
          ),
        ),
        // backgroundColor: Colors.orange,
        body: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            TabBarView(
              controller: _tabController,
              children: <Widget>[
                Topics(
                  isSchoolTopics: true,
                  push: push,
                ),
                Topics(
                  isSchoolTopics: false,
                  push: push,
                ),
              ],
            ),
            Positioned(
              bottom: ScreenUtil().setHeight(30),
              child: InkWell(
                onTap: () {
                  push(() async {
                    await Application.router
                        .navigateTo(context, '/publishTopic');
                  });
                },
                child: Chip(
                  elevation: 5,
                  shadowColor: Colors.black,
                  backgroundColor:
                      Theme.of(context).primaryColor.withOpacity(1),
                  avatar: Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                  label: Text(
                    '添加话题',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ));
  }
}

class Topics extends StatefulWidget {
  final bool isSchoolTopics;
  final PushCallback push;

  Topics({this.isSchoolTopics, this.push});

  @override
  _TopicsState createState() => _TopicsState(isSchoolTopics: isSchoolTopics);
}

class _TopicsState extends State<Topics> {
  final bool isSchoolTopics;
  static double schoolOffset = 0;
  static double interSchoolOffset = 0;

  _TopicsState({this.isSchoolTopics});

  ScrollController _scrollController;

  static TopicModel schoolTopics;
  static TopicModel interSchoolTopics;
  static int schoolPageCount = 0;
  static int interSchoolPageCount = 0;
  int itemCount = 0;
  EasyRefreshController _refreshController;

  @override
  void initState() {
    print('topics正在initstate');
    if (isSchoolTopics) {
      if (schoolTopics == null) {
        _getInitialTopicsData(2);
        _scrollController = ScrollController();
      } else {
        _scrollController = ScrollController(initialScrollOffset: schoolOffset);
        itemCount = schoolTopics.data.length;
      }
    } else {
      if (interSchoolTopics == null) {
        _getInitialTopicsData(2);
        _scrollController = ScrollController();
      } else {
        _scrollController =
            ScrollController(initialScrollOffset: interSchoolOffset);
        itemCount = interSchoolTopics.data.length;
      }
    }
    _scrollController.addListener(() {
      if (isSchoolTopics) {
        schoolOffset = _scrollController.offset;
      } else {
        interSchoolOffset = _scrollController.offset;
      }
    });
    _refreshController = EasyRefreshController();
    super.initState();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return body;
  }

  Widget get body {
    TopicModel topics;
    if (isSchoolTopics) {
      topics = schoolTopics;
    } else {
      topics = interSchoolTopics;
    }
    Widget child;
    if (topics == null) {
      child = Container(
          alignment: Alignment.center,
          height: double.infinity,
          child: CupertinoActivityIndicator());
    } else {
      child = EasyRefresh.custom(
        enableControlFinishLoad: true,
        header: MaterialHeader(),
        footer: MaterialFooter(),
        controller: _refreshController,
        onRefresh: () async {
          await Future.delayed(Duration(microseconds: 500), () {
            topics.data = [];
            _getInitialTopicsData(2);
          });
          _refreshController.resetLoadState();
        },
        onLoad: () async {
          int pageCount =
              isSchoolTopics ? schoolPageCount : interSchoolPageCount;
          bool hasMore = await _getMore(pageCount);
          print(hasMore);
          _refreshController.finishLoad(success: true, noMore: (!hasMore));
        },
        scrollController: _scrollController,
        slivers: <Widget>[
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return _singleItem(context, topics.data[index], index);
              },
              childCount: this.itemCount,
            ),
          ),
        ],
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

  ///初始话数据 获取两页数据
  Future _getInitialTopicsData(int pageCount) async {
    var topicsData = await apiClient.getTopics(page: 1);
    TopicModel newTopics = TopicModel.fromJson(topicsData);
    for (int i = 2; i <= pageCount; i++) {
      var topicsDataTemp = await apiClient.getTopics(page: i);
      TopicModel topicsTemp = TopicModel.fromJson(topicsDataTemp);
      newTopics.data.addAll(topicsTemp.data);
    }
    // newTopics.data

    if (isSchoolTopics) {
      newTopics.data.removeWhere((item) => item.school == null);
    } else {
      newTopics.data.removeWhere((item) => item.school != null);
    }
    // print('topicsData=======>${topicsData}');
    if (!mounted) return;
    setState(() {
      if (isSchoolTopics) {
        schoolTopics = newTopics;
        schoolPageCount = pageCount + 1;
      } else {
        interSchoolTopics = newTopics;
        interSchoolPageCount = pageCount + 1;
      }
      this.itemCount = schoolTopics.data.length;
    });
  }

  ///return hasMore
  Future<bool> _getMore(int pageCount) async {
    var topicsData = await apiClient.getTopics(page: pageCount);

    TopicModel newTopics = TopicModel.fromJson(topicsData);

    if (isSchoolTopics) {
      newTopics.data.removeWhere((item) => item.school == null);
    } else {
      newTopics.data.removeWhere((item) => item.school != null);
    }

    setState(() {
      if (isSchoolTopics) {
        schoolTopics.data.addAll(newTopics.data);
        schoolPageCount ++;
      } else {
        interSchoolTopics.data.addAll(newTopics.data);
        interSchoolPageCount ++;
      }
      this.itemCount = this.itemCount + newTopics.data.length;
    });
    return newTopics.hasMore;
  }

  _singleItem(BuildContext context, TopicModelData item, int index) {
    ///宽高比 1.6/1
    return CachedNetworkImage(
      imageUrl: item.image,
      imageBuilder: (context, imageProvider) {
        return ImageItem(
          item: item,
          imageProvider: imageProvider,
          onTap: () {
            widget.push(() async {
              Application.router.navigateTo(context,
                  '/home/topicDetail?id=${item.id.toString()}&title=${Uri.encodeComponent(item.title)}&image=${Uri.encodeComponent(item.image)}');
            });
          },
          key: ValueKey(item.image),
        );
      },
      errorWidget: (context, url, error) => Icon(Icons.error),
    );
  }
}

class ImageItem extends StatelessWidget {
  ImageItem({this.item, this.imageProvider, this.onTap, Key key})
      : super(key: key);
  final TopicModelData item;
  final ImageProvider imageProvider;
  final VoidCallback onTap;
  static final double topicHeight = ScreenUtil().setHeight(430);
  static final double topicWidth = topicHeight * 1.6;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          margin: EdgeInsets.only(top: ScreenUtil().setWidth(20)),
          height: topicHeight,
          width: topicWidth,
          decoration: BoxDecoration(
            // color: Colors.green,
            borderRadius: BorderRadius.all(Radius.circular(3)),
            // border: Border.all(color: Colors.black, width: 2),
            image: DecorationImage(
              image: imageProvider,
              fit: BoxFit.fill,
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Opacity(
                opacity: 0.2,
                child: Container(
                  // width: ScreenUtil().setWidth(750),
                  color: Colors.black,
                ),
              ),
              Container(
                height: ScreenUtil().setHeight(200),
                width: ScreenUtil().setWidth(550),
                alignment: Alignment.center,
                // padding: EdgeInsets.symmetric(horizontal: 80),
                decoration: BoxDecoration(
                    // color: Colors.white,
                    border: Border.all(color: Colors.white.withOpacity(0.3))),
                child: Text(
                  item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: Colors.white,
                    fontSize: ScreenUtil().setSp(40),
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Positioned(
                  bottom: topicHeight / 4.5,
                  child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                    ),
                    child: Text(
                      '点击查看详情',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: ScreenUtil().setSp(20)),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
