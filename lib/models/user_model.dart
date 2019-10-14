import 'package:finder/config/api_client.dart';

class UserModel {
  String nickname;
  String phone;
  String avatar;
  String introduction;
  String birthday;
  String major;
  School school;

  UserModel(
      {this.avatar,
      this.birthday,
      this.introduction,
      this.major,
      this.nickname,
      this.phone,
      this.school});
  UserModel.fromJson(Map<String, dynamic> json) {
    nickname = json['nickname'];
    phone = json['phone'];
    avatar = ApiClient.host + json['avatar'];
    introduction = json['introduction'];
    birthday = json["birthday"];
    major = json['major'];
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
