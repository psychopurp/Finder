import 'package:finder/config/global.dart';
import 'package:finder/pages/home_page/activity/activity_search_page.dart';
import 'package:finder/plugin/callback.dart';
import 'package:flutter/cupertino.dart';
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

  ActivityTypesModel activityTypes;

  @override
  void initState() {
    if (global.activityTypes != null) {
      this.activityTypes = global.activityTypes;
      _tabController = new TabController(
          vsync: this, length: this.activityTypes.data.length);
    } else {
      ApiClient.dio.get('get_activity_types/').then((val) {
        this.activityTypes = ActivityTypesModel.fromJson(val.data);
        this
            .activityTypes
            .data
            .insert(1, ActivityTypesModelData(id: -1, name: "全部"));
        _tabController = new TabController(
            vsync: this, length: this.activityTypes.data.length);
      });
    }

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
          brightness: Brightness.dark,
          textTheme: TextTheme(
              title: TextStyle(
                  color: Colors.black,
                  fontFamily: 'Poppins',
                  fontSize: ScreenUtil().setSp(45))),
          title: Text('知 · 活动'),
          actions: <Widget>[
            MaterialButton(
              child: Icon(Icons.search),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) {
                  return ActivitySearchPage();
                }));
                // showSearch(
                //     context: context,
                //     delegate: ActivitySearchDelegate(hintText: "搜索你喜欢的话题"));
              },
            ),
          ],
          elevation: 0,
          backgroundColor: Colors.white,
          centerTitle: true,
          bottom: new TabBar(
            isScrollable: true,
            labelColor: Colors.black,
            indicatorColor: Theme.of(context).primaryColor,
            indicatorWeight: 3,
            tabs: this.activityTypes.data.map((item) {
              return Tab(
                child: Text(
                  item.name,
                  style: TextStyle(
                      fontSize: ScreenUtil().setSp(30),
                      fontWeight: FontWeight.w500),
                ),
              );
            }).toList(),
            controller: _tabController,
          ),
        ),
        backgroundColor: Colors.white,
        body: TabBarView(
          controller: _tabController,
          children: this.activityTypes.data.map((item) {
            return ChildActivities(
              activityType: item,
            );
          }).toList(),
        ));
  }
}

class ChildActivities extends StatefulWidget {
  final ActivityTypesModelData activityType;

  ChildActivities({this.activityType});

  @override
  _ChildActivitiesState createState() =>
      _ChildActivitiesState(activityType: activityType);
}

class _ChildActivitiesState extends State<ChildActivities>
    with AutomaticKeepAliveClientMixin<ChildActivities> {
  final ActivityTypesModelData activityType;

  _ChildActivitiesState({this.activityType});

  List<ActivityModelData> activities = [];
  bool hasMore = true;
  bool isLoading = true;
  int pageCount = 1;
  bool atHear = true;
  EasyRefreshController _refreshController;

  @override
  bool get wantKeepAlive => true;

  Future<void> push(FutureCallback code) async {
    atHear = false;
    if (code != null) {
      await code();
    }
    atHear = true;
  }

  @override
  void initState() {
    _refreshController = EasyRefreshController();
    getData(pageCount: 1);
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
    if (!atHear) return Container();
    return body;
  }

  Widget get body {
    Widget child;
    if (this.isLoading) {
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
          this.isLoading = true;
          this.activities = [];
          await getData(pageCount: 1);
          _refreshController.resetLoadState();
        },
        onLoad: () async {
          await Future.delayed(Duration(milliseconds: 500), () {
            getData(pageCount: this.pageCount);
          });
          _refreshController.finishLoad(success: true, noMore: (!this.hasMore));
        },
        slivers: <Widget>[
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return _singleItem(this.activities[index]);
              },
              childCount: this.activities.length,
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

  Future getData({int pageCount}) async {
    List<ActivityModelData> temp = [];
    bool hasMore;
    if (this.activities.length == 0) {
      for (int i = 1; i <= pageCount; i++) {
        var data =
            await apiClient.getActivities(page: i, typeId: activityType.id);
        print(data['total_page']);
        ActivityModel activities = ActivityModel.fromJson(data);
        hasMore = activities.hasMore;
        temp.addAll(activities.data);
      }
      this.pageCount = pageCount;
    } else {
      var data = await apiClient.getActivities(
          page: this.pageCount, typeId: activityType.id);
      ActivityModel activities = ActivityModel.fromJson(data);
      print(data['total_page']);
      hasMore = activities.hasMore;
      temp.addAll(activities.data);
    }

    if (!mounted) return;
    setState(() {
      this.isLoading = false;
      this.activities.addAll(temp);
      this.hasMore = hasMore;
      this.pageCount++;
    });
  }

  _singleItem(ActivityModelData item) {
    String heroTag =
        this.activityType.name + item.id.toString() + 'moreActivities';
    DateTime start = item.startTime;
    DateTime end = item.endTime;
    String startTime = start.year.toString() +
        '-' +
        start.month.toString() +
        '-' +
        start.day.toString();
    String endTime = end.year.toString() +
        '-' +
        end.month.toString() +
        '-' +
        end.day.toString();

    Widget child;
    child = Container(
        margin: EdgeInsets.only(bottom: 20),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.black12, width: 1),
              // top: BorderSide(color: Colors.black12, width: 1)),
            ),
            // borderRadius: BorderRadius.circular(10),
            color: Colors.white),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            ///活动海报
            Hero(
              tag: heroTag,
              child: Container(
                height: ScreenUtil().setHeight(320),
                width: ScreenUtil().setWidth(250),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(3)),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black12,
                          offset: Offset(-1.0, 2.0),
                          blurRadius: 2.0,
                          spreadRadius: 2.0),
                    ],
                    image: DecorationImage(
                        image: CachedNetworkImageProvider(item.poster),
                        fit: BoxFit.cover)),
              ),
            ),

            ///活动信息
            Expanded(
              child: Container(
                padding: EdgeInsets.only(left: 10),
                // color: Colors.amber,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    ///活动标题
                    Container(
                      // color: Colors.cyan,
                      padding: EdgeInsets.symmetric(vertical: 0),
                      child: Text(
                        '#' + item.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: ScreenUtil().setSp(30),
                            fontWeight: FontWeight.lerp(
                                FontWeight.w400, FontWeight.w800, 0.8)),
                      ),
                    ),

                    Container(
                      padding: EdgeInsets.only(top: 10),
                      child: Text(
                        '主办方：' + item.sponsor,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: ScreenUtil().setSp(25),
                            fontWeight: FontWeight.w500),
                      ),
                    ),

                    ///活动时间
                    Container(
                      // color: Colors.amber,
                      padding: EdgeInsets.only(bottom: 10, top: 5),
                      child: Text(
                        '开始时间：' + startTime + '\n' + '结束时间：' + endTime,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: ScreenUtil().setSp(25),
                            fontWeight: FontWeight.w500),
                      ),
                    ),

                    ///活动地点
                    Container(
                      // color: Colors.amber,
                      padding: EdgeInsets.symmetric(vertical: 0),
                      child: Text(
                        '活动地点：' + item.place,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: ScreenUtil().setSp(25),
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ));

    child = GestureDetector(
      onTap: () {
        push(() async {
          var formData = {'item': item, 'heroTag': heroTag};
          Navigator.pushNamed(context, Routes.activityDetail,
              arguments: formData);
        });
      },
      child: child,
    );

    return child;
  }
}
