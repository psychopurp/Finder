import 'package:finder/config/api_client.dart';

//首页轮播图模型
class BannerModel {
  List<BannerModelData> data;
  bool status;

  BannerModel({this.data, this.status});

  BannerModel.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = new List<BannerModelData>();
      json['data'].forEach((v) {
        data.add(new BannerModelData.fromJson(v));
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

class BannerModelData {
  int id;
  String image;
  String location;

  BannerModelData({this.id, this.image, this.location});

  BannerModelData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    image = ApiClient.host + json['image'];
    location = json['location'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['image'] = this.image;
    data['location'] = this.location;
    return data;
  }
}
