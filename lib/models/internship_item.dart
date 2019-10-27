import 'package:finder/plugin/avatar.dart';

class InternshipItem {
  InternshipItem(
      {this.id,
        this.image,
        this.company,
        this.types,
        this.salaryRange,
        this.tags,
        this.title,
        this.time,
        this.introduction});

  factory InternshipItem.fromJson(Map<String, dynamic> map) {
    return InternshipItem(
        id: map['id'],
        company: CompanyItem.fromJson(map['company']),
        types: List<InternshipSmallType>.generate((map['types'] ?? []).length,
                (index) => InternshipSmallType.fromJson(map['types'][index])),
        tags: List<InternshipTag>.generate((map['tags'] ?? []).length,
                (index) => InternshipTag.fromJson(map['tags'][index])),
        salaryRange: map['salary_range'],
        title: map['title'],
        time: DateTime.fromMillisecondsSinceEpoch((map['time'] * 1000).toInt()),
        introduction: map["introduction"]);
  }

  factory InternshipItem.recommend(Map<String, dynamic> json) {
    Map<String, dynamic> map = json["internship"];
    return InternshipItem(
      id: map['id'],
      image: Avatar.getImageUrl(json['image']),
      company: CompanyItem.fromJson(map['company']),
      types: List<InternshipSmallType>.generate((map['types'] ?? []).length,
              (index) => InternshipSmallType.fromJson(map['types'][index])),
      tags: List<InternshipTag>.generate((map['tags'] ?? []).length,
              (index) => InternshipTag.fromJson(map['tags'][index])),
      salaryRange: map['salary_range'],
      title: map['title'],
      time: DateTime.fromMillisecondsSinceEpoch((map['time'] * 1000).toInt()),
      introduction: map["introduction"],
    );
  }

  final int id;
  final String title;
  final String image;
  final CompanyItem company;
  final List<InternshipSmallType> types;
  final List<InternshipTag> tags;
  final String salaryRange;
  final DateTime time;
  final String introduction;
}

class CompanyItem {
  CompanyItem({this.id, this.name, this.image});

  factory CompanyItem.fromJson(Map<String, dynamic> map) {
    if (map == null) return null;
    return CompanyItem(
        id: map["id"],
        name: map["name"],
        image: Avatar.getImageUrl(map["image"]));
  }

  final int id;
  final String name;
  final String image;
}

class InternshipType {
  InternshipType({this.id, this.name});

  final int id;
  final String name;

  @override
  int get hashCode {
    if (runtimeType == InternshipSmallType) {
      return 1000000000 + id;
    } else {
      return 2000000000 + id;
    }
  }

  @override
  bool operator ==(other) {
    return other.runtimeType == runtimeType && other.id == this.id;
  }
}

class InternshipSmallType extends InternshipType {
  InternshipSmallType({int id, String name}) : super(id: id, name: name);

  factory InternshipSmallType.fromJson(Map<String, dynamic> map) {
    return InternshipSmallType(
      id: map["id"],
      name: map["name"],
    );
  }
}

class InternshipBigType extends InternshipType {
  InternshipBigType({int id, String name}) : super(id: id, name: name);

  factory InternshipBigType.fromJson(Map<String, dynamic> map) {
    return InternshipBigType(
      id: map["id"],
      name: map["name"],
    );
  }
}

class InternshipTag {
  InternshipTag({this.id, this.name});

  factory InternshipTag.fromJson(Map<String, dynamic> map) {
    return InternshipTag(
      id: map["id"],
      name: map["name"],
    );
  }

  final int id;
  final String name;
}