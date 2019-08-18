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

//返回首页
var rootHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return IndexPage();
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
