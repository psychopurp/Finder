import 'package:finder/config/api_client.dart';
import 'package:finder/models/tag_model.dart';
import 'package:finder/public.dart';

class ActivityModel {
  List<ActivityModelData> data;
  int totalPage;
  bool status;
  bool hasMore;

  ActivityModel({this.data, this.totalPage, this.status, this.hasMore});

  ActivityModel.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = new List<ActivityModelData>();
      json['data'].forEach((v) {
        data.add(new ActivityModelData.fromJson(v));
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

class ActivityModelData {
  int id;
  String title;
  int senderId;
  String sponsor;
  String startTime;
  String endTime;
  String place;
  String poster;
  String description;
  String signUpLocation;
  bool isCollected;

  String position;
  List<ActivityTypesModelData> types;
  List<TagModel> tags;

  ActivityModelData(
      {this.id,
      this.isCollected,
      this.title,
      this.senderId,
      this.sponsor,
      this.startTime,
      this.endTime,
      this.place,
      this.poster,
      this.description,
      this.signUpLocation,
      this.position,
      this.tags,
      this.types});

  ActivityModelData.fromJson(Map<String, dynamic> json) {
    isCollected = json['is_collected'];
    id = json['id'];
    title = json['title'];
    senderId = json['sender_id'];
    sponsor = json['sponsor'];
    if (json['start_time'].runtimeType == String) {
      startTime = json['start_time'];
      endTime = json['end_time'];
    } else {
      num time = json['start_time'];
      startTime = timestampToDateTime(time).toString();
      time = json['end_time'];
      endTime = timestampToDateTime(time).toString();
    }

    place = json['place'];

    poster = Avatar.getImageUrl(json['poster']);
    description = json['description'];
    signUpLocation = json['sign_up_location'];
    position = json['position'];
    if (json['types'] != null) {
      types = new List<ActivityTypesModelData>();
      json['types'].forEach((v) {
        types.add(new ActivityTypesModelData.fromJson(v));
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
    data['id'] = this.id;
    data['title'] = this.title;
    data['sender_id'] = this.senderId;
    data['sponsor'] = this.sponsor;
    data['start_time'] = this.startTime;
    data['end_time'] = this.endTime;
    data['place'] = this.place;
    data['poster'] = this.poster;
    data['description'] = this.description;
    data['sign_up_location'] = this.signUpLocation;
    data['position'] = this.position;
    if (this.types != null) {
      data['types'] = this.types.map((v) => v.toJson()).toList();
    }
    if (this.tags != null) {
      data['tags'] = this.tags.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ActivityTypesModel {
  List<ActivityTypesModelData> data;
  int totalPage;
  bool status;
  bool hasMore;

  ActivityTypesModel({this.data, this.totalPage, this.status, this.hasMore});

  ActivityTypesModel.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = new List<ActivityTypesModelData>();
      json['data'].forEach((v) {
        data.add(new ActivityTypesModelData.fromJson(v));
      });
    }

    ///data排序规则
    data.sort((a, b) => a.id.compareTo(b.id));
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

class ActivityTypesModelData {
  int id;
  String name;

  ActivityTypesModelData({this.id, this.name});

  ActivityTypesModelData.fromJson(Map<String, dynamic> json) {
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
