import 'package:finder/models/topic_comments_model.dart';
import 'package:finder/public.dart';

class CollectionsModel {
  List<CollectionsModelData> data;
  int totalPage;
  bool status;
  bool hasMore;

  CollectionsModel({this.data, this.totalPage, this.status, this.hasMore});

  CollectionsModel.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = new List<CollectionsModelData>();
      json['data'].forEach((v) {
        data.add(new CollectionsModelData.fromJson(v));
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

class CollectionsModelData {
  int id;
  String time;
  int type;
  Activity activity;
  Topic topic;
  TopicComment topicComment;
  Null recruit;

  CollectionsModelData(
      {this.id,
      this.time,
      this.type,
      this.activity,
      this.topic,
      this.topicComment,
      this.recruit});

  CollectionsModelData.fromJson(Map<String, dynamic> json) {
    id = json['id'];

    if (json['time'].runtimeType == String) {
      time = json['time'];
    } else {
      num timeStamp = json['time'];
      time = timestampToDateTime(timeStamp).toString();
    }
    type = json['type'];
    activity = json['activity'] != null
        ? new Activity.fromJson(json['activity'])
        : null;
    topic = json['topic'] != null ? new Topic.fromJson(json['topic']) : null;
    topicComment = json['topic_comment'] != null
        ? new TopicComment.fromJson(json['topic_comment'])
        : null;
    recruit = json['recruit'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['time'] = this.time;
    data['type'] = this.type;
    if (this.activity != null) {
      data['activity'] = this.activity.toJson();
    }
    if (this.topic != null) {
      data['topic'] = this.topic.toJson();
    }
    if (this.topicComment != null) {
      data['topic_comment'] = this.topicComment.toJson();
    }
    data['recruit'] = this.recruit;
    return data;
  }
}

class Activity {
  int id;
  String title;
  Sender sender;
  String poster;

  Activity({this.id, this.title, this.sender, this.poster});

  Activity.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    sender =
        json['sender'] != null ? new Sender.fromJson(json['sender']) : null;
    poster = json['poster'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    if (this.sender != null) {
      data['sender'] = this.sender.toJson();
    }
    data['poster'] = this.poster;
    return data;
  }
}

class Topic {
  int id;
  String title;
  Sender sender;
  String image;

  Topic({this.id, this.title, this.sender, this.image});

  Topic.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    sender =
        json['sender'] != null ? new Sender.fromJson(json['sender']) : null;
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    if (this.sender != null) {
      data['sender'] = this.sender.toJson();
    }
    data['image'] = this.image;
    return data;
  }
}

class TopicComment {
  int id;
  Sender sender;
  String content;

  TopicComment({this.id, this.sender, this.content});

  TopicComment.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    sender =
        json['sender'] != null ? new Sender.fromJson(json['sender']) : null;
    content = json['content'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    if (this.sender != null) {
      data['sender'] = this.sender.toJson();
    }
    data['content'] = this.content;
    return data;
  }
}
