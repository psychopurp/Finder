import 'dart:ui';

import 'package:finder/public.dart';
import 'package:flutter/material.dart';

class UserModel {
  int id;
  String nickname;
  String avatar;
  String introduction;
  String major;
  School school;
  int fanCount;
  String realName;
  String studentId;
  int followCount;

  /// 用户自己特有属性
  DateTime birthday;
  String phone;

  ///用于其他用户页信息
  bool isFollowed;
  bool isBothFollowed;

  ///我加的
  List<Color> backGround;

  UserModel(
      {this.avatar,
      this.id,
      this.birthday,
      this.realName,
      this.introduction,
      this.major,
      this.nickname,
      this.phone,
      this.studentId,
      this.school,
      this.fanCount,
      this.followCount});

  UserModel.fromJson(Map<String, dynamic> json) {
    // print(json['real_name'].runtimeType);
    id = json['id'];
    nickname = json['nickname'];
    avatar = Avatar.getImageUrl(json['avatar']);
    introduction = json['introduction'];
    major = json['major'];
    fanCount = json['fan_count'];
    followCount = json['follow_count'];
    studentId = json["student_id"];
    realName = json['real_name'] != null ? json['real_name'] : "";
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
    json['avatar'] = this.avatar.substring(this.avatar.indexOf('/s') == -1
        ? this.avatar.indexOf("/1")
        : this.avatar.indexOf('/s'));
    json['introduction'] = this.introduction;
    json['real_name'] = realName;
    json["student_id"] = studentId;
    json["birthday"] = getTime(dateTime: this.birthday);
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
