import 'dart:convert';
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
  Future<Map> login(
      {@required String phone, @required String password}) async {
    var data = await apiClient.login(phone, password);
    if (data['status'] == true) {
      this.isLogIn = true;
      var userData = await apiClient.getUserProfile();
      this.userInfo = UserModel.fromJson(userData['data']);

      notifyListeners();
      return {"status": true};
    } else {
      return {"status": false, "error": data["error"]};
    }
  }

  Future<void> loginWithToken(String token) async {
      ApiClient.dio.options.headers['token'] = token;
      Global.saveToken(newToken: token);
      this.isLogIn = true;
      var userData = await apiClient.getUserProfile();
      this.userInfo = UserModel.fromJson(userData['data']);
      notifyListeners();
  }

  Future<void> getData() async {
    var userData = await apiClient.getUserProfile();
    this.userInfo = UserModel.fromJson(userData['data']);
    notifyListeners();
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

  ///保存数据
  Future save() async {
    await Global.save("collection", jsonEncode(collection));
    print(jsonEncode(collection));
    await Global.save("like", jsonEncode(like));
  }

  @override
  void dispose() {
    // save();
    print("dispose provider....");
    super.dispose();
  }
}
