import 'package:finder/pages/home_page/home_page_banner.dart';
import 'package:finder/pages/home_page/home_page_topics.dart';
import 'package:finder/pages/home_page/home_page_activity.dart';
import 'package:finder/plugin/callback.dart';

import 'package:flutter/material.dart';
import 'package:finder/config/api_client.dart';
import 'package:flutter/cupertino.dart';

//data model
import 'package:finder/models/banner_model.dart';
import 'package:finder/models/topic_model.dart';
import 'package:finder/models/activity_model.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_easyrefresh/material_header.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static var formData;
  bool atHear = true;

  @override
  void initState() {
    print('homepage setstate');
    _getHomePageData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // final user = Provider.of<UserProvider>(context);
    return Scaffold(
      appBar: AppBar(
        leading: MaterialButton(
          padding: EdgeInsets.all(0),
          // color: Colors.yellow,
          shape: CircleBorder(),
          child: Icon(
            Icons.menu,
            color: Colors.white,
            size: 30,
          ),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
        title: Text(
          'Finders',
          style: TextStyle(
            color: Colors.white,
            fontSize: 19,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      // backgroundColor: Color.fromRGBO(0, 0, 0, 0.03),
      body: body,
    );
  }

  Widget get body {
    if (!atHear) return Container();
    Widget child;
    if (formData == null) {
      child = Container(
          alignment: Alignment.center,
          height: double.infinity,
          child: CupertinoActivityIndicator());
    } else {
      child = EasyRefresh(
        header: MaterialHeader(),
        child: ListView(
          children: <Widget>[
            HomePageBanner(formData['banner']),
            Padding(
              padding: EdgeInsets.all(10),
            ),
            HomePageTopics(formData['topics'], push),
            Padding(
              padding: EdgeInsets.all(10),
            ),
            HomePageActivities(formData['activities'], push),
          ],
        ),
        onRefresh: () async {
          await _getHomePageData();
        },
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

  Future _getBannerData() async {
    var bannerData = await apiClient.getHomePageBanner();
    BannerModel banner = BannerModel.fromJson(bannerData);
    return banner;
  }

  Future _getTopicsData(int pageCount) async {
    var topicsData = await apiClient.getTopics(page: 1);
    // print(topicsData);
    TopicModel topics = TopicModel.fromJson(topicsData);
    for (int i = 2; i <= pageCount; i++) {
      var topicsData2 = await apiClient.getTopics(page: i);
      topics.data.addAll(TopicModel.fromJson(topicsData2).data);
    }

    return topics;
  }

  Future _getAcitivitiesData() async {
    var activitiesData = await apiClient.getActivities(page: 1);
    // print(activitiesData);
    ActivityModel activities = ActivityModel.fromJson(activitiesData);
    // print("activitiesData==========>$activitiesData");
    // print(activities);
    return activities;
  }

  //获取首页数据并解析
  Future _getHomePageData() async {
    var newFormData = {
      'banner': await _getBannerData(),
      'topics': await _getTopicsData(3),
      'activities': await _getAcitivitiesData()
    };
    if (!mounted) return;
    setState(() {
      formData = newFormData;
    });
  }

  Future<void> push(FutureCallback code) async {
    atHear = false;
    if (code != null) {
      await code();
    }
    atHear = true;
  }
}
