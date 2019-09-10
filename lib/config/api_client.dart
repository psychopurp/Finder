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
      print('获得首页轮播图成功....');
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
      return response.data['url'];
    } catch (e) {
      print('上传图片错误==========>$e');
    }
  }

  //获取城市列表
  Future getCities({int provinceId}) async {
    var formData = {'province_id': provinceId};
    try {
      Response response = await dio.get(
        'get_cities/',
        queryParameters: formData,
      );
      return response.data;
    } catch (e) {
      print('获取城市列表错误==========>$e');
    }
  }

  //获取省份
  Future getProvinces() async {
    try {
      Response response = await dio.get(
        'get_provinces/',
      );
      return response.data;
    } catch (e) {
      print('获取省份错误==========>$e');
    }
  }

  //获取学校列表
  Future getSchools({int id, int cityId}) async {
    /*
    获取一个学校时输入id
    获取列表时输入city
    */
    var formData =
        (id != null) ? {'city_id': cityId, 'id': id} : {'city_id': cityId};
    try {
      Response response = await dio.get(
        'get_schools/',
        queryParameters: formData,
      );
      return response.data;
    } catch (e) {
      print('获取学校列表错误==========>$e');
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
      // print('获得话题成功....');
      return response.data;
    } catch (e) {
      print('获取话题错误==========>$e');
    }
  }

  //获取话题评论
  Future getTopicComments(
      {int topicId, String query = '', int page = 0, int rootId, token}) async {
    /**
    topic_id: int
    query: str
    page: int
    root_id(传了就是回复，不传是评论): int
       */
    var formData = {'topic_id': topicId, 'query': query, 'page': page};
    try {
      Response response = await dio.get('get_topic_comments/',
          queryParameters: formData,
          options: Options(headers: {"token": token}));
      print('获得话题评论成功....${response.data}');
      return response.data;
    } catch (e) {
      print('获取话题评论错误==========>$e');
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
      print('获得活动成功....');
      return response.data;
    } catch (e) {
      print('获取活动错误==========>$e');
    }
  }

  //用户发布话题
  Future addTopic(String title, List<String> tags, String image, token,
      {int schoolId}) async {
    var formData = (schoolId != null)
        ? {'title': title, 'tags': tags, 'image': image, 'school_id': schoolId}
        : {
            'title': title,
            'tags': tags,
            'image': image,
          };
    print(jsonEncode(formData));
    try {
      Response response = await dio.post('add_topic/',
          data: jsonEncode(formData),
          options: Options(headers: {"token": token}));
      print('发布话题成功==========>${response.data}');
      return response.data;
    } catch (e) {
      print('发布话题错误==========>$e');
    }
  }

  //获取用户关注的用户列表
  Future getFollowUsers({String query = "", int page = 1, token}) async {
    var formData = {'query': query, 'page': page};
    print(token);
    try {
      Response response = await dio.get('get_follow_users/',
          queryParameters: formData,
          options: Options(headers: {"token": token}));

      return response.data;
    } catch (e) {
      print('获取用户关注的用户列表错误==========>$e');
    }
  }

  //获取招募列表
  Future getRecruits({int page = 1, int typeId}) async {
    var formData = (typeId != null)
        ? {'page': page, 'type_id': typeId}
        : {
            'page': page,
          };
    // print(formData);
    try {
      Response response = await dio.get(
        'get_recruits/',
        queryParameters: formData,
      );
      return response.data;
    } catch (e) {
      print('获取招募列表错误==========>$e');
    }
  }

  //获取招募类型列表
  Future getRecruitTypes(token) async {
    try {
      Response response = await dio.get('get_recruit_types/',
          options: Options(headers: {"token": token}));
      return response.data;
    } catch (e) {
      print('获取招募类型列表错误==========>$e');
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
