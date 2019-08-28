import 'package:finder/config/api_client.dart';

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
  String position;

  ActivityModelData(
      {this.id,
      this.title,
      this.senderId,
      this.sponsor,
      this.startTime,
      this.endTime,
      this.place,
      this.poster,
      this.description,
      this.position});

  ActivityModelData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    senderId = json['sender_id'];
    sponsor = json['sponsor'];
    startTime = json['start_time'];
    endTime = json['end_time'];
    place = json['place'];
    poster = (json['poster'][0] == '/')
        ? ApiClient.host + json['poster']
        : ApiClient.host + '/' + json['poster'];
    description = json['description'];
    position = json['position'];
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
    data['position'] = this.position;
    return data;
  }
}
