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
    Response response = await dio.get(
      'get_recommend/',
    );
    return response.data;
  }

  //登陆
  Future logIn(String phone, String password) async {
    var formData = {'phone': phone, 'password': password};
    var data = jsonEncode(formData);
    Response response = await dio.post('login/', data: data);
    return response.data;
  }

  //获取用户信息
  Future getUserProfile(token) async {
    Response response = await dio.get('get_user_profile/',
        options: Options(headers: {"token": token}));
    return response.data;
  }

  //修改个人信息
  Future upLoadUserProfile(UserModel userINfo, token) async {
    var data = jsonEncode(userINfo.toJson());
    Response response = await dio.post('modify_profile/',
        data: data, options: Options(headers: {"token": token}));
    print(response.data);
    return response.data;
  }

  //上传图片
  Future uploadImage(File image, token) async {
    String path = image.path;
    var name = path.substring(path.lastIndexOf('/') + 1);
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
      print(ApiClient.host + response.data['url']);
      return ApiClient.host + response.data['url'];
    } catch (e) {
      print('错误========$e');
    }
  }

  //获取话题
  Future getTopics({String query = "", int page = 0}) async {
    var formData = {'query': query, 'page': page};
    Response response = await dio.get(
      'get_topics/',
      queryParameters: formData,
    );
    return response.data;
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
