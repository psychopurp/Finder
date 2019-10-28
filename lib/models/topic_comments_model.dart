import 'package:finder/public.dart';

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
  ReplyTo replyTo;
  RootComment rootComment;
  int likes;
  int replyCount;
  DateTime time;
  bool isLike;
  bool isCollected;
  bool hasReply;

  TopicCommentsModelData(
      {this.id,
      this.sender,
      this.content,
      this.replyTo,
      this.rootComment,
      this.likes,
      this.isLike,
      this.time,
      this.replyCount,
      this.isCollected,
      this.hasReply});

  TopicCommentsModelData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    sender =
        json['sender'] != null ? new Sender.fromJson(json['sender']) : null;
    content = json['content'];
    replyTo = json['reply_to'] != null
        ? new ReplyTo.fromJson(json['reply_to'])
        : null;
    time = DateTime.fromMillisecondsSinceEpoch((json['time'] * 1000).toInt());

    // rootComment = json['root_comment'] != "None"
    //     ? new RootComment.fromJson(json['root_comment'])
    //     : null;
    replyCount = json['reply_count'];
    likes = json['likes'];
    isLike = json['is_like'];
    isCollected = json['is_collected'];

    hasReply = json['has_reply'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    if (this.sender != null) {
      data['sender'] = this.sender.toJson();
    }
    data['content'] = this.content;
    if (this.replyTo != null) {
      data['reply_to'] = this.replyTo.toJson();
    }
    if (this.rootComment != null) {
      data['root_comment'] = this.rootComment.toJson();
    }
    data['likes'] = this.likes;
    data['is_like'] = this.isLike;
    data['is_collected'] = this.isCollected;
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
    avatar = Avatar.getImageUrl(json['avatar']);
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

class RootComment {
  int id;
  int topicId;
  int rootCommentId;
  String replyToId;
  String time;
  int senderId;
  String content;

  RootComment(
      {this.id,
      this.topicId,
      this.rootCommentId,
      this.replyToId,
      this.time,
      this.senderId,
      this.content});

  RootComment.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    topicId = json['topic_id'];
    rootCommentId = json['root_comment_id'];
    replyToId = json['reply_to_id'];
    time = json['time'];
    senderId = json['sender_id'];
    content = json['content'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['topic_id'] = this.topicId;
    data['root_comment_id'] = this.rootCommentId;
    data['reply_to_id'] = this.replyToId;
    data['time'] = this.time;
    data['sender_id'] = this.senderId;
    data['content'] = this.content;
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
