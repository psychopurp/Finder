import 'dart:io';

import 'package:flutter/material.dart';
import 'package:finder/model/user_model.dart';
import 'package:finder/config/api_client.dart';

class UserProvider with ChangeNotifier {
  UserModel userInfo = new UserModel(
      nickname: '未登录',
      avatar:
          'https://ss2.bdstatic.com/70cFvnSh_Q1YnxGkpoWK1HF6hhy/it/u=883611357,2149035107&fm=26&gp=0.jpg');
  String token;
  int tokenExpireIn = 0;
  bool isLogIn = false;

  //登陆
  Future<bool> login(
      {@required String phone, @required String password}) async {
    var data = await apiClient.logIn(phone, password);
    if (data['status'] == true) {
      // print(data);
      this.token = data['token'];
      this.isLogIn = true;
      var userData = await apiClient.getUserProfile(this.token);
      this.userInfo = UserModel.fromJson(userData['data']);
      print(userData['data']);
      print(userInfo.nickname);
      notifyListeners();
      return true;
    } else {
      return false;
    }
  }

  //修改用户信息
  Future upLoadUserProfile(UserModel userINfo) async {
    await apiClient.upLoadUserProfile(userINfo, this.token);
    getUserProfile();
  }

  //获取用户信息
  Future getUserProfile() async {
    var userData = await apiClient.getUserProfile(this.token);
    this.userInfo = UserModel.fromJson(userData['data']);
    notifyListeners();
  }

  //上传图片
  Future uploadImage(File image) async {
    String imagePath = await apiClient.uploadImage(image, this.token);
    return imagePath;
  }
}
