import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:finder/model/user_model.dart';

class ApiClient {
  static const host = "http://47.94.247.8";
  static const baseURL = "http://47.94.247.8/api/";

  var dio = ApiClient.createDio();

  //获得首页轮播图
  Future getHomePageBanner() async {
    try {
      Response response = await dio.get(
        'get_recommend/',
      );
      return response.data;
    } catch (e) {
      print('获得首页轮播图错误==========>$e');
    }
  }

  //登陆
  Future logIn(String phone, String password) async {
    var formData = {'phone': phone, 'password': password};
    var data = jsonEncode(formData);
    try {
      Response response = await dio.post('login/', data: data);
      return response.data;
    } catch (e) {
      print('登陆错误==========>$e');
    }
  }

  //获取用户信息
  Future getUserProfile(token) async {
    try {
      Response response = await dio.get('get_user_profile/',
          options: Options(headers: {"token": token}));
      return response.data;
    } catch (e) {
      print('获取用户信息错误==========>$e');
    }
  }

  //修改个人信息
  Future upLoadUserProfile(UserModel userINfo, token) async {
    var data = jsonEncode(userINfo.toJson());
    try {
      Response response = await dio.post('modify_profile/',
          data: data, options: Options(headers: {"token": token}));
      print('修改个人信息成功=====${response.data}');
      return response.data;
    } catch (e) {
      print('修改个人信息错误==========>$e');
    }
  }

  //上传图片
  Future uploadImage(File image, token) async {
    String path = image.path;
    var name = path.substring(path.lastIndexOf('/') + 1);
    print('图片名===========>$name');
    var formData = new FormData.from({
      'image': new UploadFileInfo(image, name,
          contentType: ContentType.parse('multipart/form-data'))
    });
    try {
      Response response = await dio.post('upload_image/',
          options: Options(headers: {"token": token}),
          data: formData, onSendProgress: (sent, total) {
        print('$sent---$total');
      });
      print('上传图片成功==========>${response.data}');
      // print(ApiClient.host + response.data['url']);
      return ApiClient.host + response.data['url'];
    } catch (e) {
      print('上传图片错误==========>$e');
    }
  }

  //获取话题
  Future getTopics({String query = "", int page = 1}) async {
    var formData = {'query': query, 'page': page};

    try {
      Response response = await dio.get(
        'get_topics/',
        queryParameters: formData,
      );
      return response.data;
    } catch (e) {
      print('获取话题错误==========>$e');
    }
  }

  //获取活动
  Future getActivities({String query = "", int page = 1}) async {
    var formData = {'query': query, 'page': page};
    try {
      Response response = await dio.get(
        'get_activities/',
        queryParameters: formData,
      );
      return response.data;
    } catch (e) {
      print('获取活动错误==========>$e');
    }
  }

  //初始化 Dio 对象
  static Dio createDio() {
    var options = BaseOptions(
      baseUrl: baseURL,
    );
    return Dio(options);
  }
}

ApiClient apiClient = ApiClient();
