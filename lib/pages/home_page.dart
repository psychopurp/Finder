import 'dart:convert';

import 'package:finder/pages/home_page/home_page_banner.dart';
import 'package:finder/pages/home_page/home_page_topics.dart';
import 'package:finder/pages/home_page/home_page_activity.dart';

import 'package:flutter/material.dart';
import 'package:finder/config/api_client.dart';
import 'package:flutter/cupertino.dart';
//data model
import 'package:finder/model/banner_model.dart';
import 'package:finder/model/topic_model.dart';
import 'package:finder/model/activity_model.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Finders'),
        elevation: 0,
        centerTitle: true,
      ),
      backgroundColor: Color.fromRGBO(0, 0, 0, 0.03),
      body: FutureBuilder(
          future: _getHomePageData(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView(
                children: <Widget>[
                  HomePageBanner(snapshot.data['banner']),
                  HomePageTopics(snapshot.data['topics']),
                  HomePageActivities(snapshot.data['activities']),
                ],
              );
            } else {
              return Center(child: CupertinoActivityIndicator());
            }
          }),
    );
  }

  Future _getBannerData() async {
    var bannerData = await apiClient.getHomePageBanner();
    BannerModel banner = BannerModel.fromJson(bannerData);
    // print('bannerData=============>$bannerData');
    return banner;
  }

  Future _getTopicsData() async {
    var topicsData = await apiClient.getTopics();
    TopicModel topics = TopicModel.fromJson(topicsData);
    // print('topicsData=======>$topicsData');
    return topics;
  }

  Future _getAcitivitiesData() async {
    var activitiesData = await apiClient.getActivities();
    ActivityModel activities = ActivityModel.fromJson(activitiesData);
    // print("activitiesData==========>$activities");
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
    return formData;
  }
}
