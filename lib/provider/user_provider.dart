import 'dart:io';

import 'package:flutter/material.dart';
import 'package:finder/models/user_model.dart';
import 'package:finder/config/api_client.dart';
import 'package:finder/config/global.dart';

class UserProvider with ChangeNotifier {
  UserModel userInfo = Global.userInfo;
  int tokenExpireIn = 0;
  bool isLogIn = Global.isLogin;

  ///收藏
  Map<String, Set<int>> collection = {
    "activity": Set(),
    "topic": Set(),
    "comment": Set(),
    "recruit": Set()
  };

  ///点赞
  Map<String, Set<int>> like = {"topicComment": Set()};

  //登陆
  Future<bool> login(
      {@required String phone, @required String password}) async {
    var data = await apiClient.login(phone, password);
    if (data['status'] == true) {
      this.isLogIn = true;
      var userData = await apiClient.getUserProfile();
      this.userInfo = UserModel.fromJson(userData['data']);

      notifyListeners();
      return true;
    } else {
      return false;
    }
  }

  //修改用户信息
  Future upLoadUserProfile(UserModel userINfo) async {
    await apiClient.upLoadUserProfile(userINfo);
    getUserProfile();
  }

  //获取用户信息
  Future getUserProfile() async {
    /*
    通过是否能获取到用户信息来判断token是否失效
    */
    var userData = await apiClient.getUserProfile();
    this.userInfo = UserModel.fromJson(userData['data']);
    print('========getUserProfile=======');
    this.isLogIn = true;
    notifyListeners();
  }

  //上传图片 --返回图片地址
  Future uploadImage(File image) async {
    String imagePath = await apiClient.uploadImage(image);
    return imagePath;
  }

  //用户发布话题
  Future addTopic(String title, List<String> tags, String image,
      {int schoolId}) async {
    var data = await apiClient.addTopic(title, tags, image, schoolId: schoolId);
    return data;
  }

  ///用户发布话题评论
  Future addTopicComment(
      {int topicId, String content, int referComment}) async {
    var data = await apiClient.addTopicComment(
        topicId: topicId, content: content, referComment: referComment);
    return data;
  }

  ///点赞话题评论/取消点赞话题评论
  Future likeTopicComment({int topicCommentId}) async {
    var data = await apiClient.likeTopicComment(topicCommentId: topicCommentId);
    return data;
  }

  ///用户发布活动
  Future addActivity(
      {String sponsor,
      String title,
      String place,
      String poster,
      List<String> tags,
      String startTime,
      String endTime,
      String description,
      List<int> typeId,
      int associationId}) async {
    var data = await apiClient.addActivity(
        sponsor: sponsor,
        title: title,
        place: place,
        poster: poster,
        tags: tags,
        typeId: typeId,
        associationId: associationId,
        startTime: startTime,
        endTime: endTime,
        description: description);
    return data;
  }

  ///获取用户关注的用户列表
  Future getFollowUsers({String query = "", int page = 1}) async {
    var data = await apiClient.getFollowUsers(query: query, page: page);
    return data;
  }
}
