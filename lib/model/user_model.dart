class UserModel {
  String nickname;
  String phone;
  String avatar;
  String introduction;
  String birthday;
  String major;
  String school;

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
    avatar = json['avatar'];
    introduction = json['introduction'];
    birthday = json["birthday"];
    major = json['major'];
    school = json['school'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = new Map<String, dynamic>();
    json['nickname'] = this.nickname;
    json['phone'] = this.phone;
    json['avatar'] = this.avatar;
    json['introduction'] = this.introduction;
    json["birthday"] = this.birthday;
    json['major'] = this.major;
    json['school'] = this.school;
    return json;
  }
}
