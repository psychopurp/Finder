import 'package:flutter/material.dart';
import 'package:finder/public.dart';
import 'package:finder/models/activity_model.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_easyrefresh/material_header.dart';
import 'package:flutter_easyrefresh/material_footer.dart';
import 'package:finder/config/api_client.dart';

class MoreActivities extends StatefulWidget {
  @override
  _MoreActivitiesState createState() => _MoreActivitiesState();
}

class _MoreActivitiesState extends State<MoreActivities>
    with SingleTickerProviderStateMixin {
  TabController _tabController;

  @override
  void initState() {
    _tabController = new TabController(vsync: this, length: 4);
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
          iconTheme: IconThemeData(color: Colors.black),
          textTheme: TextTheme(
              title: TextStyle(
                  color: Colors.black,
                  fontFamily: 'Poppins',
                  fontSize: ScreenUtil().setSp(45))),
          title: Text('知 · 活动'),
          actions: <Widget>[
            MaterialButton(
              child: Icon(Icons.search),
              onPressed: () {},
            ),
          ],
          elevation: 0,
          backgroundColor: Colors.white,
          centerTitle: true,
          bottom: new TabBar(
            isScrollable: true,
            labelColor: Colors.black,
            indicatorColor: Colors.black,
            tabs: <Widget>[
              new Tab(
                child: Text(
                  '推荐',
                  style: TextStyle(
                      fontSize: ScreenUtil().setSp(30),
                      fontWeight: FontWeight.w500),
                ),
              ),
              new Tab(
                child: Text(
                  '学术讲座',
                  style: TextStyle(
                      fontSize: ScreenUtil().setSp(30),
                      fontWeight: FontWeight.w500),
                ),
              ),
              new Tab(
                child: Text(
                  '文娱活动',
                  style: TextStyle(
                      fontSize: ScreenUtil().setSp(30),
                      fontWeight: FontWeight.w500),
                ),
              ),
              new Tab(
                child: Text(
                  '其他',
                  style: TextStyle(
                      fontSize: ScreenUtil().setSp(30),
                      fontWeight: FontWeight.w500),
                ),
              ),
            ],
            controller: _tabController,
          ),
        ),
        backgroundColor: Colors.white,
        body: TabBarView(
          controller: _tabController,
          children: <Widget>[
            ChildActivities(
              tagName: '推荐',
            ),
            ChildActivities(
              tagName: '推荐',
            ),
            ChildActivities(
              tagName: '推荐',
            ),
            ChildActivities(
              tagName: '推荐',
            ),
          ],
        ));
  }
}

class ChildActivities extends StatefulWidget {
  final String tagName;
  ChildActivities({this.tagName});
  @override
  _ChildActivitiesState createState() =>
      _ChildActivitiesState(tagName: tagName);
}

class _ChildActivitiesState extends State<ChildActivities>
    with AutomaticKeepAliveClientMixin<ChildActivities> {
  final String tagName;
  _ChildActivitiesState({this.tagName});

  ActivityModel activities;
  int pageCount = 2;
  int itemCount = 0;
  EasyRefreshController _refreshController = EasyRefreshController();
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    _getInitialActivitiesData(1);
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
        await Future.delayed(Duration(seconds: 1), () {
          setState(() {});
        });
      },
      onLoad: () async {
        var data = await _getMore(this.pageCount, context);
        _refreshController.finishLoad(
            success: true, noMore: (data.length == 0));
      },
      slivers: <Widget>[
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              return _singleItem(context, this.activities.data[index], index);
            },
            childCount: this.itemCount,
          ),
        ),
      ],
    );
  }

  Future _getInitialActivitiesData(int pageCount) async {
    var activityData = await apiClient.getActivities(page: 1);
    // print(topicsData);
    ActivityModel activities = ActivityModel.fromJson(activityData);
    print('activities=======>${activities.data}');
    setState(() {
      this.activities = activities;
      this.itemCount = activities.data.length;
    });
    return activities;
  }

  Future _getMore(int pageCount, BuildContext context) async {
    var activityData = await apiClient.getActivities(page: pageCount);
    // print(topicsData);
    ActivityModel activities = ActivityModel.fromJson(activityData);
    print('activities=======>${activities.toJson()}');
    setState(() {
      this.activities.data.addAll(activities.data);
      this.itemCount = this.itemCount + activities.data.length;
      this.pageCount++;
    });
    return activities.data;
  }

  _singleItem(BuildContext context, ActivityModelData item, int index) {
    return CachedNetworkImage(
      imageUrl: item.poster,
      imageBuilder: (context, imageProvider) => InkWell(
        onTap: () {
          print(index);
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
                            offset: Offset(-3.0, 5.0),
                            blurRadius: 10.0,
                            spreadRadius: 1.0),
                      ],
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.fill,
                      ),
                    )),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(
                          top: ScreenUtil().setHeight(50),
                          bottom: ScreenUtil().setHeight(20)),
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
                      margin: EdgeInsets.only(top: ScreenUtil().setHeight(20)),
                      width: ScreenUtil().setWidth(420),
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        item.place,
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
                      margin: EdgeInsets.only(
                          right: ScreenUtil().setWidth(40),
                          top: ScreenUtil().setHeight(40)),
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
