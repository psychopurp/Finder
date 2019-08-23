import 'package:flutter/material.dart';
import 'package:finder/model/user_model.dart';
import 'package:finder/config/api_client.dart';

class UserProvider with ChangeNotifier {
  UserModel userInfo;
  String token;
  int tokenExpireIn = 0;
  bool isLogIn = false;

  //登陆
  Future<bool> login(
      {@required String phone, @required String password}) async {
    var data = await apiClient.logIn(phone, password);
    if (data['status'] == true) {
      print(data);
      token = data['token'].toString();
      isLogIn = true;
      var userData = await apiClient.getUserProfile(token);
      userInfo = UserModel.fromJson(userData);
      print(userData);
      print(userInfo.nickname);
      notifyListeners();
      return true;
    } else {
      return false;
    }
  }

  //获取用户信息
  // Future getUserProfile() async {
  //   notifyListeners();
  // }
}
