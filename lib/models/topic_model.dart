import 'package:finder/config/api_client.dart';

class TopicModel {
  List<TopicModelData> data;
  int totalPage;
  bool status;
  bool hasMore;

  TopicModel({this.data, this.totalPage, this.status, this.hasMore});

  TopicModel.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = new List<TopicModelData>();
      json['data'].forEach((v) {
        data.add(new TopicModelData.fromJson(v));
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

class TopicModelData {
  int id;
  String title;
  String image;
  double time;
  School school;

  TopicModelData({this.id, this.title, this.image, this.time, this.school});

  TopicModelData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    if (json['image'] == null) {
      json['image'] = 'null';
    }

    image = (json['image'][0] == '/')
        ? ApiClient.host + json['image']
        : ApiClient.host + '/' + json['image'];

    time = json['time'];
    school =
        json['school'] != null ? new School.fromJson(json['school']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['image'] = this.image;
    data['time'] = this.time;
    if (this.school != null) {
      data['school'] = this.school.toJson();
    }
    return data;
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
