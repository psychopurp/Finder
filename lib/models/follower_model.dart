import 'package:finder/plugin/avatar.dart';

class FollowerModel {
  List<FollowerModelData> data;
  int totalPage;
  bool status;
  bool hasMore;

  FollowerModel({this.data, this.totalPage, this.status, this.hasMore});

  FollowerModel.fromJson(Map<String, dynamic> json, bool isFollow) {
    if (json['data'] != null) {
      data = new List<FollowerModelData>();
      json['data'].forEach((v) {
        data.add(new FollowerModelData.fromJson(v, isFollow));
      });
    }
    totalPage = json['total_page'];
    status = json['status'];
    hasMore = json['has_more'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data.map((v) => v.toJson()).toList();
    }
    data['total_page'] = this.totalPage;
    data['status'] = this.status;
    data['has_more'] = this.hasMore;
    return data;
  }
}

class FollowerModelData {
  static const int FOLLOW = 0;
  static const int BOTHFOLLOW = 1;
  static const int FOLLOWED = 2;
  int id;
  String nickname;
  String avatar;
  String introduction;
  bool isBothFollowed;

  int status;

  FollowerModelData(
      {this.id,
      this.nickname,
      this.avatar,
      this.status,
      this.introduction,
      this.isBothFollowed});

  FollowerModelData.fromJson(Map<String, dynamic> json, bool isFollow) {
    id = json['id'];
    nickname = json['nickname'];
    avatar = Avatar.getImageUrl(json['avatar']);
    introduction = json['introduction'];
    isBothFollowed = json['is_both_followed'];

    if (isFollow) {
      if (isBothFollowed) {
        status = BOTHFOLLOW;
      } else {
        status = FOLLOWED;
      }
    } else {
      if (isBothFollowed) {
        this.status = BOTHFOLLOW;
      } else {
        this.status = FOLLOW;
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['nickname'] = this.nickname;
    data['avatar'] = this.avatar;
    data['introduction'] = this.introduction;
    data['is_both_followed'] = this.isBothFollowed;
    return data;
  }
}
