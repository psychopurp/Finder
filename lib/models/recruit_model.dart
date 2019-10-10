class RecruitModel {
  List<RecruitModelData> data;
  int totalPage;
  bool status;
  bool hasMore;

  RecruitModel({this.data, this.totalPage, this.status, this.hasMore});

  RecruitModel.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = new List<RecruitModelData>();
      json['data'].forEach((v) {
        data.add(new RecruitModelData.fromJson(v));
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

class RecruitModelData {
  Sender sender;
  num time;
  String title;
  String introduction;
  int id;

  RecruitModelData(
      {this.sender, this.time, this.title, this.introduction, this.id});

  RecruitModelData.fromJson(Map<String, dynamic> json) {
    sender =
        json['sender'] != null ? new Sender.fromJson(json['sender']) : null;
    time = json['time'];
    title = json['title'];
    introduction = json['introduction'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.sender != null) {
      data['sender'] = this.sender.toJson();
    }
    data['time'] = this.time;
    data['title'] = this.title;
    data['introduction'] = this.introduction;
    data['id'] = this.id;
    return data;
  }
}

class Sender {
  int id;
  String nickname;
  String avatar;

  Sender({this.id, this.nickname, this.avatar});

  Sender.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    nickname = json['nickname'];
    avatar = json['avatar'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['nickname'] = this.nickname;
    data['avatar'] = this.avatar;
    return data;
  }
}

///招募类型模型
class RecruitTypesModel {
  List<RecruitTypesModelData> data;
  bool status;

  RecruitTypesModel({this.data, this.status});

  RecruitTypesModel.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = new List<RecruitTypesModelData>();
      json['data'].forEach((v) {
        data.add(new RecruitTypesModelData.fromJson(v));
      });
    }
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data.map((v) => v.toJson()).toList();
    }
    data['status'] = this.status;
    return data;
  }
}

class RecruitTypesModelData {
  int id;
  String name;

  RecruitTypesModelData({this.id, this.name});

  RecruitTypesModelData.fromJson(Map<String, dynamic> json) {
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
