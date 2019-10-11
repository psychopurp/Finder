import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'router_handler.dart';

class Routes {
  static String root = "/"; //首页
  static String serve = "/serve";
  static String login = '/login';

  //首页
  static String publishTopic = '/publishTopic'; //首页-- 发布话题
  static String publishTopicComment = '/publishTopicComment'; //首页-- 发布话题
  static String publishActivity = '/publishActivity'; //首页 -- 发布活动
  static String moreTopics = '/home/moreTopics'; //首页 -- 更多话题
  static String moreActivities = '/home/moreActivities'; //首页 -- 更多活动
  static String topicDetail = '/home/topicDetail'; //首页 -- 话题详情
  static String activityDetail = '/home/activityDetail'; //首页 -- 活动详情
  //服务页
  static String lostFound = "/serve/lostFound"; //服务页面 -- 失物招领
  static String heSays = "/serve/heSays"; //服务页面 -- 他·她·说
  static String heSaysPublish =
      "/serve/heSays/heSaysPublish"; //服务页面 -- 他·她·说 --发布页
  static String heSaysDetail =
      "/serve/heSays/heSaysDetail"; //服务页面 -- 他·她·说 --发布页
  static String study = "/serve/study"; //服务页面 -- 一起学习
  static String selectCourse = "/serve/selectCourse"; //服务页面 -- 选课指南
  static String psychoTest = "/serve/psychoTest"; //服务页面 -- 心理测试
  static String treeHole = "/serve/treeHole"; //服务页面 -- 我·树洞
  //用户页
  static String userProfile = "/mine/userProfile"; //服务页面 -- 我·树洞

  static String chat = "/message/chat";
  static String systemMessage = "/message/systemMessage";
  static String tips = "/message/tips";

  static void configureRoutes(Router router) {
    router.notFoundHandler = Handler(
        handlerFunc: (BuildContext context, Map<String, List<String>> params) {
      print("ROUTE WAS NOT FOUND !!!");
      return Center(
        child: Text("ROUTE WAS NOT FOUND !!!"),
      );
    });
    router.define(root, handler: rootHandler);

    //首页
    router.define(publishTopic,
        handler: publishTopicHandler, transitionType: TransitionType.material);
    router.define(publishTopicComment,
        handler: publishTopicCommentHandler,
        transitionType: TransitionType.material);
    router.define(publishActivity,
        handler: publishActivityHandler, transitionType: TransitionType.fadeIn);
    router.define(login,
        handler: loginHandler, transitionType: TransitionType.fadeIn);
    router.define(moreTopics,
        handler: moreTopicsHandler, transitionType: TransitionType.fadeIn);
    router.define(moreActivities,
        handler: moreActivitiesHandler, transitionType: TransitionType.fadeIn);
    router.define(topicDetail,
        handler: topicDetailsHandler, transitionType: TransitionType.fadeIn);
    router.define(activityDetail,
        handler: acitvityDetailsHandler, transitionType: TransitionType.fadeIn);

    //服务页 --导航
    router.define(lostFound,
        handler: lostFoundHandler, transitionType: TransitionType.material);
    router.define(heSays,
        handler: heSaysHandler, transitionType: TransitionType.fadeIn);
    router.define(heSaysPublish,
        handler: heSaysPublishHandler, transitionType: TransitionType.fadeIn);
    router.define(heSaysDetail,
        handler: heSaysDetailHandler, transitionType: TransitionType.fadeIn);
    router.define(study, handler: studyHandler);
    router.define(selectCourse, handler: selectCourseHandler);
    router.define(psychoTest, handler: psychoTestHandler);
    router.define(treeHole, handler: treeHoleHandler);

    //我的页
    router.define(userProfile,
        handler: userProfileHandler, transitionType: TransitionType.fadeIn);

    router.define(chat,
        handler: chatPageHandle, transitionType: TransitionType.cupertino);
  }
}
