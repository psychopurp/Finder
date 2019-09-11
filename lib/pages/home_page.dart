import 'package:finder/pages/home_page/home_page_banner.dart';
import 'package:finder/pages/home_page/home_page_topics.dart';
import 'package:finder/pages/home_page/home_page_activity.dart';
import 'package:finder/public.dart';
import 'package:finder/config/global.dart';

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
  Map<String, dynamic> formData;

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
          title: Text(
            'Finders',
            style: TextStyle(
                color: Colors.black.withOpacity(0.8),
                fontFamily: 'Yellowtail',
                fontWeight: FontWeight.w400,
                fontSize: ScreenUtil().setSp(70)),
          ),
          elevation: 1,
          centerTitle: true,
        ),
        backgroundColor: Color.fromRGBO(0, 0, 0, 0.03),
        body: (this.formData != null)
            ? Container(
                color: Colors.white.withOpacity(0.1),
                child: EasyRefresh(
                  header: MaterialHeader(),
                  onRefresh: () async {
                    await Future.delayed(Duration(seconds: 1), () {
                      setState(() {});
                    });
                  },
                  child: ListView(
                    children: <Widget>[
                      HomePageBanner(this.formData['banner']),
                      HomePageTopics(this.formData['topics']),
                      HomePageActivities(this.formData['activities']),
                    ],
                  ),
                ),
              )
            : Center(child: CupertinoActivityIndicator()));
  }

  Future _getBannerData() async {
    var bannerData = await apiClient.getHomePageBanner();
    BannerModel banner = BannerModel.fromJson(bannerData);
    return banner;
  }

  Future _getTopicsData() async {
    var topicsData = await apiClient.getTopics(page: 1);
    var topicsData2 = await apiClient.getTopics(page: 2);
    var topicsData3 = await apiClient.getTopics(page: 3);
    var topicsData4 = await apiClient.getTopics(page: 4);
    var topicsData5 = await apiClient.getTopics(page: 5);
    var topicsData6 = await apiClient.getTopics(page: 6);
    var topicsData7 = await apiClient.getTopics(page: 7);
    // print(topicsData);
    TopicModel topics = TopicModel.fromJson(topicsData);
    topics.data.addAll(TopicModel.fromJson(topicsData2).data);
    topics.data.addAll(TopicModel.fromJson(topicsData3).data);
    topics.data.addAll(TopicModel.fromJson(topicsData4).data);
    topics.data.addAll(TopicModel.fromJson(topicsData5).data);
    topics.data.addAll(TopicModel.fromJson(topicsData6).data);
    topics.data.addAll(TopicModel.fromJson(topicsData7).data);
    // print('topicsData=======>${topicsData}');
    return topics;
  }

  Future _getAcitivitiesData() async {
    var activitiesData = await apiClient.getActivities(page: 1);

    ActivityModel activities = ActivityModel.fromJson(activitiesData);
    // print("activitiesData==========>$activitiesData");
    return activities;
  }

  //获取首页数据并解析
  Future _getHomePageData() async {
    var formData = {
      'banner': await _getBannerData(),
      'topics': await _getTopicsData(),
      'activities': await _getAcitivitiesData()
    };
    // print(formData);
    setState(() {
      this.formData = formData;
    });
  }
}
