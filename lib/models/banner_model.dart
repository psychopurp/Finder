import 'package:finder/config/api_client.dart';
import 'package:finder/plugin/avatar.dart';

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
  String type;

  BannerModelData({this.id, this.image, this.location, this.type});

  BannerModelData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    image = Avatar.getImageUrl(json["image"]);
    type = json['type'];
    location = json['location'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['image'] = this.image;
    data['type'] = this.type;
    data['location'] = this.location;
    return data;
  }
}
