import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:finder/config/global.dart';
import 'package:finder/models/user_model.dart';

class ApiClient {
  // static const host = "http://47.94.247.8";
  // static const baseURL = "http://47.94.247.8/api/";
  static const host = "https://www.finder-nk.com";
  static const baseURL = "https://www.finder-nk.com/api/";

  static Dio dio = new Dio(BaseOptions(baseUrl: baseURL));

  static const int ACTIVITY = 1;
  static const int TOPIC = 2;
  static const int COMMENT = 3;
  static const int RECRUIT = 4;

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
  Future login(String phone, String password) async {
    var formData = {'phone': phone, 'password': password};
    var data = jsonEncode(formData);
    try {
      Response response = await dio.post('login/', data: data);
      if (response.data['status'] == true) {
        //登陆后给请求头加上token
        dio.options.headers['token'] = response.data['token'];
        //全局保存token
        Global.saveToken(newToken: response.data['token']);
      }
      return response.data;
    } catch (e) {
      print('登陆错误==========>$e');
    }
  }

  //获取用户信息
  Future getUserProfile() async {
    try {
      Response response = await dio.get(
        'get_user_profile/',
      );
      return response.data;
    } catch (e) {
      print('获取用户信息错误==========>$e');
    }
  }

  //修改个人信息
  Future upLoadUserProfile(UserModel userINfo) async {
    var data = jsonEncode(userINfo.toJson());
    // print(data);
    try {
      Response response = await dio.post('modify_profile/', data: data);
      print('修改个人信息成功=====${response.data}');
      return response.data;
    } catch (e) {
      print('修改个人信息错误==========>$e');
    }
  }

  //上传图片
  Future uploadImage(File image) async {
    String path = image.path;
    var name = path.substring(path.lastIndexOf('/') + 1);
    print('图片名===========>$name');
    var formData = new FormData.from({
      'image': new UploadFileInfo(image, name,
          contentType: ContentType.parse('multipart/form-data'))
    });
    try {
      Response response = await dio.post('upload_image/', data: formData,
          onSendProgress: (sent, total) {
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
      {int topicId, String query = '', int page = 1, int rootId}) async {
    /**
    topic_id: int
    query: str
    page: int
    root_id(传了就是回复，不传是评论): int
       */
    var formData = {'topic_id': topicId, 'query': query, 'page': page};
    if (rootId != null) {
      formData.addAll({'root_id': rootId});
    }
    print(formData);

    try {
      Response response =
          await dio.get('get_topic_comments/', queryParameters: formData);
      // print('获得话题评论成功....${response.data}');
      return response.data;
    } catch (e) {
      print('获取话题评论错误==========>$e');
    }
  }

  //获取活动
  Future getActivities(
      {String query = "", int page = 1, int activityId}) async {
    var formData = {'query': query, 'page': page};
    if (activityId != null) formData = {'activity_id': activityId};
    try {
      Response response = await dio.get(
        'get_activities/',
        queryParameters: formData,
      );
      // print(dio.options.headers['token']);
      print('获得活动成功....');
      return response.data;
    } catch (e) {
      print('获取活动错误==========>$e');
    }
  }

  //用户发布话题
  Future addTopic(String title, List<String> tags, String image,
      {int schoolId}) async {
    image = image.split("/")[2];
    var formData = (schoolId != null)
        ? {'title': title, 'tags': tags, 'image': image, 'school_id': schoolId}
        : {
            'title': title,
            'tags': tags,
            'image': image,
          };
    print(jsonEncode(formData));
    try {
      Response response =
          await dio.post('add_topic/', data: jsonEncode(formData));
      print('发布话题成功==========>${response.data}');
      return response.data;
    } catch (e) {
      print('发布话题错误==========>$e');
    }
  }

  ///用户发布话题评论
  Future addTopicComment(
      {int topicId, String content, int referComment}) async {
    /**
     * description: 
    评论不写refer_comment，回复要写
     topic: int
    content: str
    refer_comment_id: int
     */
    var formData = {"topic_id": topicId, "content": content};
    if (referComment != null) {
      formData.addAll({"refer_comment_id": referComment});
    }
    print(jsonEncode(formData));
    try {
      Response response =
          await dio.post('add_topic_comment/', data: jsonEncode(formData));
      // print('发布话题评论成功==========>${response.data}');
      return response.data;
    } catch (e) {
      print('发布话题评论错误==========>$e');
    }
  }

  ///删除话题评论/回复
  Future deleteTopicComment({int commentId}) async {
    /**
     * description: 
    评论不写refer_comment，回复要写
     topic: int
    content: str
    refer_comment_id: int
     */
    var formData = {"comment_id": commentId};

    try {
      Response response =
          await dio.post('delete_topic_comment/', data: jsonEncode(formData));
      // print('发布话题评论成功==========>${response.data}');
      return response.data;
    } catch (e) {
      print('删除题评论错误==========>$e');
    }
  }

  ///点赞话题评论/取消点赞话题评论
  Future likeTopicComment({int topicCommentId}) async {
    var formData = {'topic_comment_id': topicCommentId};
    try {
      Response response =
          await dio.post('like_topic_comment/', data: jsonEncode(formData));
      // print('点赞话题评论成功....${response.data}');
      return response.data;
    } catch (e) {
      print('点赞话题评论错误==========>$e');
    }
  }

  ///获取他人个人页信息
  Future getOtherProfile({int userId}) async {
    var formData = {'user_id': userId};
    try {
      Response response =
          await dio.get('get_other_profile/', queryParameters: formData);
      // print('点赞话题评论成功....${response.data}');
      return response.data;
    } catch (e) {
      print('获取他人个人页信息错误==========>$e');
    }
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
      List<int> typeId,
      String description,
      int associationId}) async {
    /**
    sponsor: str
    association_id可以不给 给了是社团活动
    title: str
    place: str
    poster: str
    start_time: timestamp(str)
    end_time: timestamp(str)
    description: str
    categories: list
    type:int 是活动类型
         */

    var formData = {
      'title': title,
      'place': place,
      'poster': poster,
      'start_time': startTime,
      'end_time': endTime,
      'description': description,
      'tags': tags,
      'type_ids': typeId,
      'sponsor': sponsor
    };
    if (associationId != null) {
      formData.addAll({'association_id': associationId});
    }
    print(jsonEncode(formData));
    try {
      Response response =
          await dio.post('add_activity/', data: jsonEncode(formData));
      print('发布活动成功==========>${response.data}');
      return response.data;
    } catch (e) {
      print('发布活动错误==========>$e');
    }
  }

  ///删除活动
  Future deleteActivity({int activityId}) async {
    var formData = {'activity_id': activityId};
    try {
      Response response =
          await dio.get('delete_activity/', queryParameters: formData);
      print(response.data);
      return response.data;
    } catch (e) {
      print('删除活动错误==========>$e');
    }
  }

  //获取用户关注/粉丝的用户列表
  Future getFollowers({int userId, bool isFan, int page}) async {
    var formData = {'user_id': userId, 'is_fan': isFan ? 1 : 0, 'page': page};
    try {
      Response response =
          await dio.get('get_followers/', queryParameters: formData);
      // print(response.data);
      return response.data;
    } catch (e) {
      print('获取用户关注/粉丝的用户列表错误==========>$e');
    }
  }

  ///关注一个用户
  Future addFollowUser({int userId}) async {
    var formData = {'user_id': userId};
    try {
      Response response =
          await dio.post('add_follow_user/', data: jsonEncode(formData));
      // print(response.data);
      return response.data;
    } catch (e) {
      print('关注用户错误==========>$e');
    }
  }

  //获取招募列表
  Future getRecruits(Map<String, dynamic> formData) async {
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
  Future getRecruitTypes() async {
    try {
      Response response = await dio.get(
        'get_recruit_types/',
      );
      return response.data;
    } catch (e) {
      print('获取招募类型列表错误==========>$e');
    }
  }

  //获取用户收藏列表
  Future getCollections({String query = "", int page = 1}) async {
    /**
     *  data 里面包括四个种类的收藏 
    基本结构：
    {
    id：int
    time：
    type:int(活动、话题、话题评论、招募、分别是1，2，3，4)
*/
    var formData = {'query': query, 'page': page};
    // print(formData);
    try {
      Response response =
          await dio.get('get_collections/', queryParameters: formData);
      // print('用户收藏列表==========>${response.data}');
      return response.data;
    } catch (e) {
      print('获取用户收藏列表错误==========>$e');
    }
  }

  ///用户收藏某个
  Future addCollection({int type, int id}) async {
    /**
     *   type1234分别对应：
    活动，话题，话题评论，招募
    id是对应的被收藏东西的id
     */

    var formData = {'type': type, 'id': id};
    print(formData);
    try {
      Response response =
          await dio.post('add_collection/', data: jsonEncode(formData));
      print('用户收藏成功==========>${response.data}');
      return response.data;
    } catch (e) {
      print('用户收藏错误==========>$e');
    }
  }

  ///删除收藏
  Future deleteCollection({int collectionId, int type, int modelId}) async {
    var formData;
    if (collectionId != null) {
      formData = {'collection_id': collectionId};
    } else if (type != null && modelId != null) {
      formData = {'type': type, 'model_id': modelId};
    }
    try {
      Response response =
          await dio.post('delete_collection/', data: jsonEncode(formData));
      print('用户删除收藏成功==========>${response.data}');
      return response.data;
    } catch (e) {
      print('用户删除收藏错误==========>$e');
    }
  }

  ///获取评论点赞列表
  Future getTopicCommentLikeUsers({int topicCommentId, int page = 1}) async {
    var formData = {'topic_comment_id': topicCommentId, "page": page};
    try {
      Response response = await dio.get('get_topic_comment_like_users/',
          queryParameters: formData);
      print('获取用户点赞成功==========>${response.data}');
      return response.data;
    } catch (e) {
      print('获取用户点赞错误==========>$e');
    }
  }

  //接口初始化
  static void init() {
    //初始化时带上默认token
    dio.options.headers['token'] = Global.token;
  }
}

ApiClient apiClient = ApiClient();
