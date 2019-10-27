import 'package:finder/plugin/avatar.dart';

class HeSheSayItem {
  HeSheSayItem(
      {this.authorAvatar,
        this.authorId,
        this.authorName,
        this.content,
        this.image,
        this.isLike,
        this.likeCount,
        this.title,
        this.id,
        this.time});

  factory HeSheSayItem.fromJson(Map<String, dynamic> map) {
    Map<String, dynamic> author = map["author"];
    String authorAvatar = Avatar.getImageUrl(author["avatar"]);
    int authorId = author["id"];
    String authorName = author["nickname"];
    String title = map["title"];
    String content = map["content"];
    String image = Avatar.getImageUrl(map["image"]);
    int likeCount = map["like"];
    bool isLike = map["isLike"];
    int id = map["id"];
    DateTime time =
    DateTime.fromMicrosecondsSinceEpoch((map['time'] * 1000000).toInt());
    return HeSheSayItem(
        authorName: authorName,
        authorAvatar: authorAvatar,
        authorId: authorId,
        isLike: isLike,
        likeCount: likeCount,
        image: image,
        content: content,
        title: title,
        id: id,
        time: time);
  }

  final int id;
  final String authorName;
  final int authorId;
  String authorAvatar;
  final String content;
  final String title;
  bool isLike;
  int likeCount;
  String image;
  final DateTime time;
}