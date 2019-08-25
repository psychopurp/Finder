import 'package:finder/pages/home_page/home_page_banner.dart';
import 'package:finder/pages/home_page/home_page_topics.dart';

import 'package:flutter/material.dart';
import 'package:finder/config/api_client.dart';
import 'package:flutter/cupertino.dart';
//data model
import 'package:finder/model/banner_model.dart';
import 'package:finder/model/topic_model.dart';

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
                    HomePageTopics(snapshot.data['topics'])
                  ],
                );
              } else {
                return Center(child: CupertinoActivityIndicator());
              }
            }));
  }

  //获取首页数据并解析
  Future _getHomePageData() async {
    var bannerData = await apiClient.getHomePageBanner();
    print(bannerData);
    var topicsData = await apiClient.getTopics();
    print(topicsData);
    BannerModel banner = BannerModel.fromJson(bannerData);
    TopicModel topics = TopicModel.fromJson(topicsData);
    var formData = {'banner': banner, 'topics': topics};

    return formData;
  }
}
