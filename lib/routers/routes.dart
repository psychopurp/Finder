import 'package:finder/pages/settings_page.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'router_handler.dart';

class Routes {
  static String root = "/"; //首页
  static String serve = "/serve";
  static String login = '/login';
  static String settings = '/settings'; //设置

  //首页
  static String publishTopic = '/publishTopic'; //首页-- 发布话题
  static String publishTopicComment = '/publishTopicComment'; //首页-- 发布话题
  static String commentPage = '/commentPage'; //首页-- 话题评论回复
  static String publishActivity = '/publishActivity'; //首页 -- 发布活动
  static String moreTopics = '/home/moreTopics'; //首页 -- 更多话题
  static String moreActivities = '/home/moreActivities'; //首页 -- 更多活动
  static String topicDetail = '/home/topicDetail'; //首页 -- 话题详情
  static String activityDetail = '/home/activityDetail'; //首页 -- 活动详情
  //招募页
  static String recruitDetail = '/home/recruitDetail'; //首页 -- 活动详情
  static String recommendRecruitDetail =
      '/home/recommendRecruitDetail'; //首页 -- 活动详情

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
  static String internship = "/serve/internship"; //服务页面 -- 实习
  static String internshipCompany = "/serve/internship/company"; //服务页面 -- 实习 公司
  static String internshipDetail = "/serve/internship/detail"; //服务页面 -- 实习 公司
  static String recommendInternshipDetail =
      "/serve/internship/recommend"; //服务页面 -- 实习 公司
  //用户页
  static String userProfile = "/userProfile"; //个人详情页
  static String minePage = "/minePage"; //我的 页
  static String collectionPage = "/collectionPage"; //用户收藏页
  static String fansFollowPage = "/fansFollowPage"; //关注和粉丝页

  static String chat = "/message/chat";
  static String systemMessage = "/message/systemMessage";
  static String tips = "/message/tips";
  static String sayToHe = "/message/say_to_he";
  static String sayToHeChat = "/message/say_to_he_chat";

  static void configureRoutes(Router router) {
    router.notFoundHandler = Handler(
        handlerFunc: (BuildContext context, Map<String, List<String>> params) {
      print("ROUTE WAS NOT FOUND !!!");
      return Center(
        child: Text("ROUTE WAS NOT FOUND !!!"),
      );
    });
    router.define(root, handler: rootHandler);
    router.define(settings, handler: Handler(handlerFunc: (_, __) {
      return SettingsPage();
    }));

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
    router.define(commentPage,
        handler: commentPageHandler, transitionType: TransitionType.cupertino);

    //招募页 --导航
    router.define(recruitDetail,
        handler: recruitDetailHandler,
        transitionType: TransitionType.cupertino);
    router.define(recommendRecruitDetail,
        handler: recommendRecruitDetailHandler,
        transitionType: TransitionType.cupertino);

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
    router.define(internship,
        handler: internshipHandler, transitionType: TransitionType.cupertino);
    router.define(internshipCompany,
        handler: internshipCompanyHandler,
        transitionType: TransitionType.cupertino);
    router.define(internshipDetail,
        handler: internshipDetailHandler,
        transitionType: TransitionType.cupertino);
    router.define(recommendInternshipDetail,
        handler: recommendInternshipDetailHandler,
        transitionType: TransitionType.cupertino);

    //我的页
    router.define(userProfile,
        handler: userProfileHandler, transitionType: TransitionType.cupertino);
    router.define(minePage,
        handler: minePageHandler, transitionType: TransitionType.cupertino);
    router.define(chat,
        handler: chatPageHandle, transitionType: TransitionType.cupertino);
    router.define(systemMessage,
        handler: systemMessageHandle, transitionType: TransitionType.cupertino);
    router.define(tips,
        handler: tipsHandle, transitionType: TransitionType.cupertino);
    router.define(sayToHe,
        handler: sayToHeHandle, transitionType: TransitionType.cupertino);
    router.define(sayToHeChat,
        handler: sayToHeChatHandle, transitionType: TransitionType.cupertino);
    router.define(collectionPage,
        handler: collectionPageHandler,
        transitionType: TransitionType.cupertino);
    router.define(fansFollowPage,
        handler: fansFollowPageHandle,
        transitionType: TransitionType.cupertino);
  }
}
