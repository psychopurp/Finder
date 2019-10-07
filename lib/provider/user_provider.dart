import 'dart:io';

import 'package:flutter/material.dart';
import 'package:finder/models/user_model.dart';
import 'package:finder/config/api_client.dart';
import 'package:finder/config/global.dart';

class UserProvider with ChangeNotifier {
  UserModel userInfo = Global.userInfo;
  int tokenExpireIn = 0;
  bool isLogIn = Global.isLogin;
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

  ///用户发布活动
  Future addActivity(
      {String sponser,
      String title,
      String place,
      String poster,
      List<String> categories,
      String startTime,
      String endTime,
      String description}) async {
    var data = await apiClient.addActivity(
        sponser: sponser,
        title: title,
        place: place,
        poster: poster,
        categories: categories,
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
