import 'package:dio/dio.dart';

class ApiClient {
  static const host = "http://47.94.247.8";
  static const baseURL = "http://47.94.247.8/api/";

  var dio = ApiClient.createDio();

  //获得首页轮播图
  Future getHomePageBanner() async {
    Response response = await dio.get('get_recommend');
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
