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
  String createTime;
  int schoolId;

  TopicModelData(
      {this.id, this.title, this.image, this.createTime, this.schoolId});

  TopicModelData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    image = json['image'];
    createTime = json['create_time'];
    schoolId = json['school_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['image'] = this.image;
    data['create_time'] = this.createTime;
    data['school_id'] = this.schoolId;
    return data;
  }
}
