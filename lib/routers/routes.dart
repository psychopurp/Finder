import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'router_handler.dart';

class Routes {
  static String root = "/"; //首页
  static String serve = "/serve";
  //服务页
  static String lostFound = "/serve/lostFound"; //服务页面 -- 失物招领
  static String heSays = "/serve/heSays"; //服务页面 -- 他·她·说
  static String heSaysPublish =
      "/serve/heSays/heSaysPublish"; //服务页面 -- 他·她·说 --发布页
  static String study = "/serve/study"; //服务页面 -- 一起学习
  static String selectCourse = "/serve/selectCourse"; //服务页面 -- 选课指南
  static String psychoTest = "/serve/psychoTest"; //服务页面 -- 心理测试
  static String treeHole = "/serve/treeHole"; //服务页面 -- 我·树洞

  static void configureRoutes(Router router) {
    router.notFoundHandler = Handler(
        handlerFunc: (BuildContext context, Map<String, List<String>> params) {
      print("ROUTE WAS NOT FOUND !!!");
    });
    router.define(root, handler: rootHandler);

    //服务页 --导航
    router.define(lostFound,
        handler: lostFoundHandler, transitionType: TransitionType.material);
    router.define(heSays,
        handler: heSaysHandler, transitionType: TransitionType.fadeIn);
    router.define(heSaysPublish,
        handler: heSaysPublishHandler, transitionType: TransitionType.fadeIn);
    router.define(study, handler: studyHandler);
    router.define(selectCourse, handler: selectCourseHandler);
    router.define(psychoTest, handler: psychoTestHandler);
    router.define(treeHole, handler: treeHoleHandler);
  }
}
