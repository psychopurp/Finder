import 'package:finder/models/topic_comments_model.dart';
import 'package:finder/models/topic_model.dart';
import 'package:finder/public.dart';

class EngageTopicCommentModel {
  bool status;
  // List<EngageTopicCommentModelData> data;
  int totalPage;
  bool hasMore;
  List<TopicModelData> topics;
  List<TopicCommentsModelData> topicComments;
  List<TopicCommentsModelData> topicReplies;

  EngageTopicCommentModel(
      {this.status,
      // this.data,
      this.totalPage,
      this.hasMore,
      this.topicComments,
      this.topicReplies,
      this.topics});

  EngageTopicCommentModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['data'] != null) {
      // data = new List<EngageTopicCommentModelData>();
      topics = new List<TopicModelData>();
      topicComments = new List<TopicCommentsModelData>();
      topicReplies = new List<TopicCommentsModelData>();
      json['data'].forEach((v) {
        switch (v['type']) {
          case 2:
            topics.add(new TopicModelData.fromJson(v));
            break;
          case 3:
            if (v['reply_to'] == null) {
              topicComments.add(new TopicCommentsModelData.fromJson(v));
            } else {
              topicReplies.add(new TopicCommentsModelData.fromJson(v));
            }
            break;
          default:
        }
      });
    }
    totalPage = json['total_page'];
    hasMore = json['has_more'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    // if (this.data != null) {
    //   data['data'] = this.data.map((v) => v.toJson()).toList();
    // }
    data['total_page'] = this.totalPage;
    data['has_more'] = this.hasMore;
    return data;
  }
}
