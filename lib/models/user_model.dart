import 'package:finder/config/api_client.dart';
import 'package:finder/public.dart';

class UserModel {
  int id;
  String nickname;
  String phone;
  String avatar;
  String introduction;
  String birthday;
  String major;
  School school;
  int fanCount;
  int followCount;

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
      this.followCount});
  UserModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    nickname = json['nickname'];
    phone = json['phone'];
    avatar = Avatar.getImageUrl(json['avatar']);
    introduction = json['introduction'];
    birthday = json["birthday"];
    major = json['major'];
    fanCount = json['fan_count'];
    followCount = json['follow_count'];
    school =
        json['school'] != null ? new School.fromJson(json['school']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = new Map<String, dynamic>();
    json['nickname'] = this.nickname;
    json['phone'] = this.phone;
    json['avatar'] = this.avatar;
    json['introduction'] = this.introduction;
    json["birthday"] = this.birthday;
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

  School({this.id, this.name});

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
