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

/// GlobalTopics

class MoreTopics extends StatefulWidget {
  @override
  _MoreTopicsState createState() => _MoreTopicsState();
}

class _MoreTopicsState extends State<MoreTopics>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  @override
  void initState() {
    _tabController = new TabController(vsync: this, length: 2);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('话题'),
          elevation: 0,
          centerTitle: true,
          bottom: new TabBar(
            isScrollable: true,
            labelColor: Colors.black,
            indicatorColor: Colors.white,
            tabs: <Widget>[
              new Tab(
                child: Text(
                  '   校内    ',
                  style: TextStyle(
                      fontSize: ScreenUtil().setSp(30),
                      fontWeight: FontWeight.w500),
                ),
              ),
              new Tab(
                child: Text(
                  '   校际    ',
                  style: TextStyle(
                      fontSize: ScreenUtil().setSp(30),
                      fontWeight: FontWeight.w500),
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
                ),
                Topics(
                  isSchoolTopics: false,
                ),
              ],
            ),
            Positioned(
              bottom: ScreenUtil().setHeight(30),
              child: InkWell(
                onTap: () {
                  Application.router.navigateTo(context, '/publishTopic');
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
  Topics({this.isSchoolTopics});
  @override
  _TopicsState createState() => _TopicsState(isSchoolTopics: isSchoolTopics);
}

class _TopicsState extends State<Topics>
    with AutomaticKeepAliveClientMixin<Topics> {
  final bool isSchoolTopics;

  _TopicsState({this.isSchoolTopics});
  TopicModel topics;
  int pageCount = 2;
  int itemCount = 0;
  EasyRefreshController _refreshController = EasyRefreshController();
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    print('topics正在initstate');
    _getInitialTopicsData(2);
    super.initState();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return EasyRefresh.custom(
      enableControlFinishLoad: true,
      header: MaterialHeader(),
      footer: MaterialFooter(),
      controller: _refreshController,
      onRefresh: () async {
        await Future.delayed(Duration(microseconds: 500), () {
          _getInitialTopicsData(2);
        });
      },
      onLoad: () async {
        var data = await _getMore(this.pageCount);
        _refreshController.finishLoad(
            success: true, noMore: (data.length == 0));
      },
      slivers: <Widget>[
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              return _singleItem(context, this.topics.data[index], index);
            },
            childCount: this.itemCount,
          ),
        ),
      ],
    );
  }

  ///初始话数据
  Future _getInitialTopicsData(int pageCount) async {
    var topicsData = await apiClient.getTopics(page: 1);
    TopicModel topics = TopicModel.fromJson(topicsData);
    for (int i = 2; i <= pageCount; i++) {
      var topicsDataTemp = await apiClient.getTopics(page: i);
      TopicModel topicsTemp = TopicModel.fromJson(topicsDataTemp);
      topics.data.addAll(topicsTemp.data);
    }

    if (isSchoolTopics) {
      topics.data.removeWhere((item) => item.school == null);
    }
    // print('topicsData=======>${topicsData}');
    if (!mounted) return;
    setState(() {
      this.topics = topics;
      this.itemCount = topics.data.length;
    });
  }

  Future _getMore(int pageCount) async {
    var topicsData = await apiClient.getTopics(page: pageCount);
    // print(topicsData);
    TopicModel topics = TopicModel.fromJson(topicsData);
    if (isSchoolTopics) {
      topics.data.removeWhere((item) => item.school == null);
    }
    // print('hasmore=======${topics.hasMore}');
    if (!mounted) return;
    setState(() {
      this.topics.data.addAll(topics.data);
      this.itemCount = this.itemCount + topics.data.length;
      this.pageCount++;
    });
  }

  _singleItem(BuildContext context, TopicModelData item, int index) {
    return CachedNetworkImage(
      imageUrl: item.image,
      imageBuilder: (context, imageProvider) => InkWell(
        onTap: () {
          Application.router.navigateTo(context,
              '/home/topicDetail?id=${item.id.toString()}&title=${Uri.encodeComponent(item.title)}&image=${Uri.encodeComponent(item.image)}');
        },
        child: Align(
          alignment: Alignment.topCenter,
          child: Container(
            margin: EdgeInsets.only(
                left: ScreenUtil().setWidth(20),
                right: ScreenUtil().setWidth(20),
                top: ScreenUtil().setWidth(20)),
            height: ScreenUtil().setHeight(300),
            width: ScreenUtil().setWidth(750),
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
                    bottom: ScreenUtil().setHeight(35),
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
      ),
      errorWidget: (context, url, error) => Icon(Icons.error),
    );
  }
}
