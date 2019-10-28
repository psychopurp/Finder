import 'package:finder/config/api_client.dart';
import 'package:finder/public.dart';

class UserModel {
  int id;
  String nickname;
  String avatar;
  String introduction;
  String major;
  School school;
  int fanCount;
  int followCount;

  /// 用户自己特有属性
  DateTime birthday;
  String phone;

  ///用于其他用户页信息
  bool isFollowed;
  bool isBothFollowed;

  UserModel(
      {this.avatar,
      this.id,
      this.birthday,
      this.introduction,
      this.major,
      this.nickname,
      this.phone,
      this.school,
      this.fanCount,
      this.followCount,
      this.isBothFollowed,
      this.isFollowed});
  UserModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    nickname = json['nickname'];
    avatar = Avatar.getImageUrl(json['avatar']);
    introduction = json['introduction'];
    major = json['major'];
    fanCount = json['fan_count'];
    followCount = json['follow_count'];

    isFollowed = json['is_followed'] != null ? json['is_followed'] : null;
    isBothFollowed =
        json['is_both_followed'] != null ? json['is_both_followed'] : null;
    birthday =
        json['birthday'] != null ? timestampToDateTime(json["birthday"]) : null;
    // print(birthday);
    school =
        json['school'] != null ? new School.fromJson(json['school']) : null;
    phone = json['phone'] != null ? json['phone'] : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = new Map<String, dynamic>();
    json['nickname'] = this.nickname;
    json['phone'] = this.phone;
    json['avatar'] = this.avatar.substring(this.avatar.indexOf('/m'));
    json['introduction'] = this.introduction;
    json["birthday"] = getTime(dateTime: this.birthday);
    // print(json['birthday']);
    json['major'] = this.major;
    json['id'] = this.id;
    json['follow_count'] = this.followCount;
    json['fan_count'] = this.fanCount;
    if (this.school != null) {
      json['school'] = this.school.toJson();
    }
    return json;
  }
}

class School {
  int id;
  String name;

  School({this.id, this.name = ""});

  School.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    return data;
  }
}
