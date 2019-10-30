import 'dart:convert';

import 'package:finder/models/user_model.dart';
import 'package:finder/pages/check_code_login_page.dart';
import 'package:finder/pages/fans_follow_page.dart';
import 'package:finder/pages/home_page/comment_page.dart';
import 'package:finder/pages/message_page/chat_page.dart';
import 'package:finder/pages/home_page/publish_topic_comment.dart';
import 'package:finder/pages/message_page/say_to_he_chat_page.dart';
import 'package:finder/pages/message_page/say_to_he_list_page.dart';
import 'package:finder/pages/message_page/system_message_page.dart';
import 'package:finder/pages/message_page/tips_page.dart';
import 'package:finder/pages/mine_page.dart';
import 'package:finder/pages/mine_page/change_profile_page.dart';
import 'package:finder/pages/mine_page/collection_page.dart';
import 'package:finder/pages/mine_page/modify_info_page.dart';
import 'package:finder/pages/recruit_page/candidates_page.dart';
import 'package:finder/pages/recruit_page/engage_page.dart';
import 'package:finder/pages/recruit_page/publish_page.dart';
import 'package:finder/pages/recruit_page/recommend_recruit_detail_page.dart';
import 'package:finder/pages/recruit_page/recruit_detail_page.dart';
import 'package:finder/pages/serve_page/he_says_page/lead_say_detail_page.dart';
import 'package:finder/pages/serve_page/he_says_page/publish_say_to_he_only_page.dart';
import 'package:finder/pages/serve_page/internship_page.dart';
import 'package:finder/pages/serve_page/internship_page/company_page.dart';
import 'package:finder/pages/serve_page/internship_page/internship_detail_page.dart';
import 'package:finder/pages/serve_page/internship_page/recommend_internship_detail_page.dart';
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
import 'package:finder/pages/mine_page/user_profile_page.dart';
import 'package:finder/pages/home_page/activity_detail_page.dart';
import 'package:finder/pages/login_page/privacy.dart';
import 'package:finder/pages/login_page/serve_protocol.dart';

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
var checkCodeLoginHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return CheckCodeLoginPage();
});

//首页 -- 更多话题
var moreTopicsHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return MoreTopics();
});

//话题详情页
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

//活动详情页
var acitvityDetailsHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  String activityId = params['activityId']?.first;

  return ActivityDetailPage(
    activityId: int.parse(activityId),
  );
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

//首页 -- 发布话题评论
var publishTopicCommentHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  String topicId = params['topicId']?.first;
  String topicTitle = params['topicTitle']?.first;
  return PublishTopicCommentPage(
    topicId: int.parse(topicId),
    topicTitle: topicTitle,
  );
});

var commentPageHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  String topicCommentId = params['topicCommentId']?.first;
  String topicId = params['topicId']?.first;

  return CommentPage(
    topicCommentId: int.parse(topicCommentId),
    topicId: int.parse(topicId),
  );
});

//首页 -- 发布活动
var publishActivityHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return PublishActivityPage();
});

//招募页
var recruitDetailHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return RecruitDetailPage();
});
var recommendRecruitDetailHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return RecommendRecruitDetailPage();
});
var publishRecruitHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return RecruitPublishPage();
});
var engageRecruitHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return EngageRecruitRoute();
});

var candidatesHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return CandidatesRoute();
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
  return HeSaysPublishPage();
});
var sayToHePublishHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return SayToHePublishRoute();
});

var heSaysDetailHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return HeSaysDetail();
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
var internshipHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return InternshipPage();
});
var internshipCompanyHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return CompanyRoute();
});
var internshipDetailHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return InternshipDetailPage();
});
var recommendInternshipDetailHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return RecommendInternshipDetailPage();
});
//用户详情页
var userProfileHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  String senderId = params['senderId']?.first;
  String heroTag = params['heroTag']?.first;
  print("heroTag===>$heroTag");
  // print(senderId);
  return UserProfilePage(
    senderId: int.parse(senderId),
    heroTag: heroTag,
  );
});

var minePageHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return MinePage();
});

var chatPageHandle = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return ChatRouter();
});
var systemMessageHandle = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return SystemMessagePage();
});
var tipsHandle = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return TipsPage();
});
var sayToHeHandle = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return SayToHePage();
});
var sayToHeChatHandle = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return SayToHeChatRoute();
});
var modifyInfoPageHandle = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return ModifyInfoPage();
});

var collectionPageHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return CollectionPage();
});

var fansFollowPageHandle = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  String userId = params['userId']?.first;
  String isFollow = params['isFollow']?.first;

  return FansFollowPage(
    userId: int.parse(userId),
    isFollow: (isFollow == 'true') ? true : false,
  );
});

var changeUserProfilePageHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return ChangeProfilePage();
});
//条款
var privacyHandle = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params) {
      return PrivacyRoute();
    });
//条款
var serveProtocolHandle = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return ServeProtocolRoute();
});
