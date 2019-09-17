import 'package:finder/models/topic_comments_model.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:finder/pages/serve_page/lost_found_page.dart';
import 'package:finder/pages/serve_page/psycho_test_page.dart';
import 'package:finder/pages/serve_page/select_course_page.dart';
import 'package:finder/pages/serve_page/study_page.dart';
import 'package:finder/pages/serve_page/tree_hole_page.dart';
import 'package:finder/pages/serve_page/he_says_page.dart';
import 'package:finder/pages/index_page.dart';
import 'package:finder/pages/serve_page/he_says_page/publish_page.dart';
import 'package:finder/pages/home_page/publish_topic_page.dart';
import 'package:finder/pages/home_page/publish_activity_page.dart';
import 'package:finder/pages/home_page/more_topics.dart';
import 'package:finder/pages/home_page/more_activities.dart';
import 'package:finder/pages/login_page.dart';
import 'package:finder/pages/home_page/topic_detail_page.dart';

//返回首页
var rootHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return IndexPage();
});

//登录页
var loginHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return LoginPage();
});

//首页 -- 更多话题
var moreTopicsHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return MoreTopics();
});

var topicDetailsHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  String topicId = params['id']?.first;
  String topicTitle = params['title']?.first;
  String topicImage = params['image']?.first;
  return TopicDetailPage(
      topicId: int.parse(topicId),
      topicImage: topicImage,
      topicTitle: topicTitle);
});

//首页 -- 更多活动
var moreActivitiesHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return MoreActivities();
});

//首页 -- 发布话题
var publishTopicHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return PublishTopicPage();
});

//首页 -- 发布活动
var publishActivityHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return PublishActivityPage();
});

//服务页面 -- 失物招领
var lostFoundHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return LostFoundPage();
});

//服务页面 -- 他·她·说
var heSaysHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return HeSaysPage();
});
//服务页面 -- 他·她·说 -- 发布页
var heSaysPublishHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return PublishPage();
});

//服务页面 -- 一起学习
var studyHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return StudyPage();
});

//服务页面 -- 选课指南
var selectCourseHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return SelectCoursePage();
});

//服务页面 -- 心理测试
var psychoTestHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return PsychoTestPage();
});

//服务页面 -- 我·树洞
var treeHoleHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return TreeHolePage();
});
