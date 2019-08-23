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
    nickname = json['data']['nickname'];
    phone = json['data']['phone'];
    avatar = json['data']['avatar'];
    introduction = json['data']['introduction'];
    birthday = json['data']["birthday"];
    major = json['data']['major'];
    school = json['data']['school'];
  }

  UserModel.toJson() {
    final Map<String, dynamic> json = new Map<String, dynamic>();
    json['data']['nickname'] = this.nickname;
    json['data']['phone'] = this.phone;
    json['data']['avatar'] = this.avatar;
    json['data']['introduction'] = this.introduction;
    json['data']["birthday"] = this.birthday;
    json['data']['major'] = this.major;
    json['data']['school'] = this.school;
  }
}
