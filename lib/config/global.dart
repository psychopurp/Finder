import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:finder/config/api_client.dart';
import 'package:finder/models/user_model.dart';

///**
///  全局信息类
///
///**

class Global {
  static SharedPreferences _prefs;
  static String token = '';
  static UserModel userInfo = new UserModel(
      nickname: '未登录',
      avatar:
          'https://ss2.bdstatic.com/70cFvnSh_Q1YnxGkpoWK1HF6hhy/it/u=883611357,2149035107&fm=26&gp=0.jpg');
  static bool isLogin = false;

  // 是否为release版
  static bool get isRelease => bool.fromEnvironment("dart.vm.product");

  //初始化全局信息，会在APP启动时执行
  //返回 isLogin
  static Future init() async {
    print('...正在进行Global初始化...');
    _prefs = await SharedPreferences.getInstance();
    if (_prefs.getString('userToken') != null) {
      Global.token = _prefs.getString("userToken");
    }

    //初始化网络请求相关配置
    //给请求头加上token
    ApiClient.init();

    //能获得用户信息说明token有效
    var data = await apiClient.getUserProfile();
    if (data['status'] == true) {
      Global.userInfo = UserModel.fromJson(data['data']);
      Global.isLogin = true;
    }
    return data['status'];
  }

  //本地保存用户信息
  static saveUserInfo() =>
      _prefs.setString('userInfo', jsonEncode(userInfo.toJson()));

  //本地保存token
  static saveToken({newToken}) {
    if (newToken != null) {
      Global.token = newToken;
    }
    _prefs.setString('userToken', token);
  }
}
