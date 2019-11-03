import 'package:finder/public.dart';

class EngageTopicCommentModel {
  bool status;
  List<EngageTopicCommentModelData> data;
  int totalPage;
  bool hasMore;

  EngageTopicCommentModel(
      {this.status, this.data, this.totalPage, this.hasMore});

  EngageTopicCommentModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['data'] != null) {
      data = new List<EngageTopicCommentModelData>();
      json['data'].forEach((v) {
        data.add(new EngageTopicCommentModelData.fromJson(v));
      });
    }
    totalPage = json['total_page'];
    hasMore = json['has_more'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    if (this.data != null) {
      data['data'] = this.data.map((v) => v.toJson()).toList();
    }
    data['total_page'] = this.totalPage;
    data['has_more'] = this.hasMore;
    return data;
  }
}

class EngageTopicCommentModelData {
  int id;
  DateTime time;
  Sender sender;
  String content;
  ReplyTo replyTo;
  int type;

  EngageTopicCommentModelData(
      {this.id, this.time, this.sender, this.content, this.replyTo, this.type});

  EngageTopicCommentModelData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    time = json['time'] != null ? timestampToDateTime(json["time"]) : null;
    sender =
        json['sender'] != null ? new Sender.fromJson(json['sender']) : null;
    content = json['content'];
    replyTo = json['reply_to'] != null
        ? new ReplyTo.fromJson(json['reply_to'])
        : null;
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data["time"] = getTime(dateTime: this.time);
    if (this.sender != null) {
      data['sender'] = this.sender.toJson();
    }
    data['content'] = this.content;
    if (this.replyTo != null) {
      data['reply_to'] = this.replyTo.toJson();
    }
    data['type'] = this.type;
    return data;
  }
}

class Sender {
  String nickname;
  String avatar;
  int id;

  Sender({this.nickname, this.avatar, this.id});

  Sender.fromJson(Map<String, dynamic> json) {
    nickname = json['nickname'];
    avatar = json['avatar'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['nickname'] = this.nickname;
    data['avatar'] = this.avatar;
    data['id'] = this.id;
    return data;
  }
}

class ReplyTo {
  int id;
  Sender sender;

  ReplyTo({this.id, this.sender});

  ReplyTo.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    sender =
        json['sender'] != null ? new Sender.fromJson(json['sender']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    if (this.sender != null) {
      data['sender'] = this.sender.toJson();
    }
    return data;
  }
}
