import 'package:finder/pages/home_page/home_page_banner.dart';
import 'package:flutter/material.dart';
import 'package:finder/config/api_client.dart';
import 'package:flutter/cupertino.dart';
import 'package:finder/model/banner_model.dart';

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
                  children: <Widget>[HomePageBanner(snapshot.data['banner'])],
                );
              } else {
                return Center(child: CupertinoActivityIndicator());
              }
            }));
  }

  //获取首页数据并解析
  Future _getHomePageData() async {
    var data = await apiClient.getHomePageBanner();
    BannerModel banner = BannerModel.fromJson(data);
    var formData = {'banner': banner};
    return formData;
  }
}
