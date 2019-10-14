import 'package:finder/config/api_client.dart';

class TopicCommentsModel {
  List<TopicCommentsModelData> data;
  int totalPage;
  bool status;
  bool hasMore;

  TopicCommentsModel({this.data, this.totalPage, this.status, this.hasMore});

  TopicCommentsModel.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = new List<TopicCommentsModelData>();
      json['data'].forEach((v) {
        data.add(new TopicCommentsModelData.fromJson(v));
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

class TopicCommentsModelData {
  int id;
  Sender sender;
  String content;
  String replyTo;
  String rootComment;
  String hasReply;

  TopicCommentsModelData(
      {this.id,
      this.sender,
      this.content,
      this.replyTo,
      this.rootComment,
      this.hasReply});

  TopicCommentsModelData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    sender =
        json['sender'] != null ? new Sender.fromJson(json['sender']) : null;
    content = json['content'];
    replyTo = json['reply_to'];
    rootComment = json['root_comment'];
    hasReply = json['has_reply'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    if (this.sender != null) {
      data['sender'] = this.sender.toJson();
    }
    data['content'] = this.content;
    data['reply_to'] = this.replyTo;
    data['root_comment'] = this.rootComment;
    data['has_reply'] = this.hasReply;
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
    avatar = ApiClient.host + json['avatar'];
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
