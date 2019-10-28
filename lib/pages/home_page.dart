import 'package:finder/models/message_model.dart';
import 'package:finder/pages/home_page/home_page_banner.dart';
import 'package:finder/pages/home_page/home_page_topics.dart';
import 'package:finder/pages/home_page/home_page_activity.dart';
import 'package:finder/provider/user_provider.dart';
import 'package:finder/public.dart';

import 'package:flutter/material.dart';
import 'package:finder/config/api_client.dart';
import 'package:flutter/cupertino.dart';
//data model
import 'package:finder/models/banner_model.dart';
import 'package:finder/models/topic_model.dart';
import 'package:finder/models/activity_model.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_easyrefresh/material_header.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var formData;

  @override
  void initState() {
    print('homepage setstate');
    _getHomePageData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context);
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
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
        ),

        // backgroundColor: Color.fromRGBO(0, 0, 0, 0.03),
        body: body);
  }

  Widget get body {
    Widget child;
    if (this.formData == null) {
      child = Container(
          alignment: Alignment.center,
          height: double.infinity,
          child: CupertinoActivityIndicator());
    } else {
      child = EasyRefresh(
        header: MaterialHeader(),
        child: ListView(
          children: <Widget>[
            HomePageBanner(this.formData['banner']),
            HomePageTopics(this.formData['topics']),
            HomePageActivities(this.formData['activities']),
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
    var formData = {
      'banner': await _getBannerData(),
      'topics': await _getTopicsData(3),
      'activities': await _getAcitivitiesData()
    };
    if (!mounted) return;
    // print(formData);
    setState(() {
      this.formData = formData;
    });
  }
}
