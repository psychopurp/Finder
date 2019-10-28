import 'package:finder/models/message_model.dart';
import 'package:finder/models/tag_model.dart';
import 'package:finder/models/topic_comments_model.dart';
import 'package:finder/plugin/avatar.dart';

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
  DateTime time;
  String title;
  String introduction;
  int id;
  List<RecruitTypesModelData> types;
  List<TagModel> tags;
  String image;

  RecruitModelData(
      {this.sender,
      this.time,
      this.title,
      this.introduction,
      this.id,
      this.tags,
      this.types,
      this.image});

  RecruitModelData.fromJson(Map<String, dynamic> json) {
    sender =
        json['sender'] != null ? new Sender.fromJson(json['sender']) : null;
    time = DateTime.fromMillisecondsSinceEpoch((json['time'] * 1000).toInt());
    title = json['title'];
    introduction = json['introduction'];
    id = json['id'];
    if (json['types'] != null) {
      types = new List<RecruitTypesModelData>();
      json['types'].forEach((v) {
        types.add(new RecruitTypesModelData.fromJson(v));
      });
    }
    if (json['tags'] != null) {
      tags = new List<TagModel>();
      json['tags'].forEach((v) {
        tags.add(new TagModel.fromJson(v));
      });
    }
  }

  RecruitModelData.fromRecommend(Map<String, dynamic> map) {
    image = Avatar.getImageUrl(map['image']);
    var json = map['recruit'];
    sender =
        json['sender'] != null ? new Sender.fromJson(json['sender']) : null;
    time = DateTime.fromMillisecondsSinceEpoch((json['time'] * 1000).toInt());
    title = json['title'];
    introduction = json['introduction'];
    id = json['id'];
    if (json['types'] != null) {
      types = new List<RecruitTypesModelData>();
      json['types'].forEach((v) {
        types.add(new RecruitTypesModelData.fromJson(v));
      });
    }
    if (json['tags'] != null) {
      tags = new List<TagModel>();
      json['tags'].forEach((v) {
        tags.add(new TagModel.fromJson(v));
      });
    }
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
    if (this.types != null) {
      data['types'] = this.types.map((v) => v.toJson()).toList();
    }
    if (this.tags != null) {
      data['tags'] = this.tags.map((v) => v.toJson()).toList();
    }
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

class CandidateItem {
  CandidateItem({this.id, this.status, this.time, this.information, this.user});
  static final int reject = 0;
  static final int waiting = 1;
  static final int accept = 2;

  factory CandidateItem.fromJson(Map<String, dynamic> map) {
    return CandidateItem(
        user: UserProfile.fromJson(map["user"]),
        time: DateTime.fromMicrosecondsSinceEpoch(
            (map['time'] * 1000000).toInt()),
        information: map["information"],
        status: map["status"],
        id: map["id"]);
  }

  final UserProfile user;
  final DateTime time;
  final String information;
  int status;
  final int id;
}
