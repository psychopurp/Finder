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
          title: Text('more topics'),
          elevation: 0,
          centerTitle: true,
          bottom: new TabBar(
            isScrollable: true,
            labelColor: Colors.black,
            indicatorColor: Colors.white,
            tabs: <Widget>[
              new Tab(
                child: Text(
                  '   推荐    ',
                  style: TextStyle(
                      fontSize: ScreenUtil().setSp(30),
                      fontWeight: FontWeight.w500),
                ),
              ),
              new Tab(
                child: Text(
                  '   学术讲座    ',
                  style: TextStyle(
                      fontSize: ScreenUtil().setSp(30),
                      fontWeight: FontWeight.w500),
                ),
              ),
              new Tab(
                child: Text(
                  '   文娱活动    ',
                  style: TextStyle(
                      fontSize: ScreenUtil().setSp(30),
                      fontWeight: FontWeight.w500),
                ),
              ),
              new Tab(
                child: Text(
                  '   其他    ',
                  style: TextStyle(
                      fontSize: ScreenUtil().setSp(30),
                      fontWeight: FontWeight.w500),
                ),
              ),
            ],
            controller: _tabController,
          ),
        ),
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
    // this.tagName=widget.tagName
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
          print(item.id);
        },
        child: Align(
          alignment: Alignment.topCenter,
          child: Container(
            margin: EdgeInsets.only(
                left: ScreenUtil().setWidth(20),
                right: ScreenUtil().setWidth(20),
                top: ScreenUtil().setWidth(20)),
            height: ScreenUtil().setHeight(400),
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
              children: <Widget>[
                Positioned(
                    top: ScreenUtil().setHeight(10),
                    child: Container(
                      padding: EdgeInsets.all(3),
                      decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.only(
                              // topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                              // bottomLeft: Radius.circular(10),
                              bottomRight: Radius.circular(20))),
                      child: Text(
                        '校内话题',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: ScreenUtil().setSp(20)),
                      ),
                    )),
                Opacity(
                  opacity: 0.1,
                  child: Container(
                    // width: ScreenUtil().setWidth(750),
                    decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.all(Radius.circular(3))),
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  // color: Colors.blue,
                  child: Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: ScreenUtil().setSp(28),
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
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
