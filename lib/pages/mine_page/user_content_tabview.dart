import 'package:flutter/material.dart';
import 'package:finder/pages/mine_page/user_activity.dart';
import 'package:finder/pages/mine_page/user_topic.dart';
import 'package:finder/pages/mine_page/user_topic_comments.dart';

class TabView extends StatefulWidget {
  final int userId;
  TabView({this.userId});
  @override
  _TabViewState createState() => _TabViewState();
}

class _TabViewState extends State<TabView> with TickerProviderStateMixin {
  TabController tabController;
  List tabs;

  @override
  void initState() {
    tabs = [
      {'name': '我参与的话题', 'body': UserTopicCommentsPage(userId: widget.userId)},
      {'name': '我发布的话题', 'body': UserTopicPage(userId: widget.userId)},
      {'name': '我的活动', 'body': UserActivityPage(userId: widget.userId)},
      // {'name': '最近浏览', 'body': Container()},
    ];
    tabController = TabController(vsync: this, length: tabs.length);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: TabBar(
            isScrollable: true,
            labelColor: Theme.of(context).primaryColor,
            indicatorColor: Theme.of(context).primaryColor,
            indicatorWeight: 1,
            indicatorSize: TabBarIndicatorSize.label,
            // labelPadding: EdgeInsets.symmetric(horizontal: 25, vertical: 0),
            unselectedLabelColor: Color(0xff333333),
            controller: this.tabController,
            tabs: this.tabs.map((tab) {
              return Tab(
                text: tab['name'],
              );
            }).toList()),
        body: TabBarView(
          controller: this.tabController,
          children: this.tabs.map((tab) {
            Widget body = tab['body'];
            return body;
          }).toList(),
        ));
  }
}
