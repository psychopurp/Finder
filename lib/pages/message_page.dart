import 'dart:convert';

import 'package:finder/provider/store.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MessagePage extends StatefulWidget {
  @override
  _MessagePageState createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("消息"),
        elevation: 0,
        centerTitle: true,
      ),
      body: body,
    );
  }

  Widget get body {
//    return ListView.builder(itemBuilder: );
  }
}

class MessageType {
  static const int UserToUser = 1;
  static const int SayToHe = 2;
  static const int SystemMessage = 3;
  static const int Tips = 4;
}

class DataObject {
  static DataObject instance;
  VoidCallback onChange;
  DateTime lastRequestTime;
  List<SystemMessageItem> systems = [];
  List<TipItem> tips = [];
  Map<String, List<UserMessageItem>> users = {};
  Map<String, List<SayToHeItem>> says = {};
  SharedPreferences prefs;

  factory DataObject({VoidCallback onChange}) {
    VoidCallback change = () {
      onChange();
      instance.save();
    };
    if (instance != null) {
      instance.onChange = change;
    } else {
      instance = DataObject._init(change);
    }
    return instance;
  }

  DataObject._init(VoidCallback onChange) {
    this.onChange = onChange;
    SharedPreferences.getInstance().then((value) {
      prefs = value;
    });
  }

  void addAll(List<Map<String, dynamic>> data) {
    bool change = false;
    for (var item in data) {
      change = change || add(item, changeNow: false);
    }
    if (change) {
      onChange();
    }
  }

  bool add(Map<String, dynamic> item, {bool changeNow: true}) {
    bool change = false;
    switch (item["type"]) {
      case MessageType.UserToUser:
        UserMessageItem messageItem = UserMessageItem.fromJson(item);
        change = addUserToUser(messageItem);
        break;
      case MessageType.SystemMessage:
        SystemMessageItem messageItem = SystemMessageItem.fromJson(item);
        change = addSystemMessage(messageItem);
        break;
      case MessageType.SayToHe:
        SayToHeItem messageItem = SayToHeItem.fromJson(item);
        change = addSay(messageItem);
        break;
      case MessageType.Tips:
        TipItem messageItem = TipItem.fromJson(item);
        change = addTip(messageItem);
        break;
    }
    if (change && changeNow) {
      onChange();
    }
    return change;
  }

  bool addUserToUser(UserMessageItem messageItem) {
    bool change = false;
    if (users.containsKey(messageItem.sessionId)) {
      if (!users[messageItem.sessionId].contains(messageItem)) {
        //TODO 此写法没有优化, 可用二分查找优化
        users[messageItem.sessionId].add(messageItem);
        change = true;
      }
    } else {
      change = true;
      users[messageItem.sessionId] = [messageItem];
    }
    return change;
  }

  bool addSystemMessage(SystemMessageItem messageItem) {
    bool change = false;
    if (!systems.contains(messageItem)) {
      //TODO 此写法没有优化, 可用二分查找优化
      systems.add(messageItem);
      change = true;
    }
    return change;
  }

  bool addTip(TipItem messageItem) {
    bool change = false;
    if (!tips.contains(messageItem)) {
      //TODO 此写法没有优化, 可用二分查找优化
      tips.add(messageItem);
      change = true;
    }
    return change;
  }

  bool addSay(SayToHeItem messageItem) {
    bool change = false;
    if (says.containsKey(messageItem.sessionId)) {
      if (!says[messageItem.sessionId].contains(messageItem)) {
        //TODO 此写法没有优化, 可用二分查找优化
        says[messageItem.sessionId].add(messageItem);
        change = true;
      }
    } else {
      change = true;
      says[messageItem.sessionId] = [messageItem];
    }
    return change;
  }

  String toJson() {
    Map<String, dynamic> result = {
      'lastRequestTime': lastRequestTime.millisecondsSinceEpoch,
      'systems': systems.map((item) => item.toJson()),
      'tips': tips.map((item) => item.toJson()),
      'users': users.map(
          (key, value) => MapEntry(key, value.map((item) => item.toJson()))),
      'says': says.map(
          (key, value) => MapEntry(key, value.map((item) => item.toJson()))),
    };
    return json.encode(result);
  }

  void load() {
    if (prefs == null) return;
    says = {};
    var data = prefs.getString("messages");
    var map = json.decode(data);
    lastRequestTime =
        DateTime.fromMillisecondsSinceEpoch(map["lastRequestTime"]);
    systems = List<SystemMessageItem>.generate(map['system'].length,
        (index) => SystemMessageItem.fromJson(map['system'][index]));
    tips = List<TipItem>.generate(
        map['tips'].length, (index) => TipItem.fromJson(map['tips'][index]));
    users = Map<String, List<UserMessageItem>>.fromEntries(map['users']
        .entries
        .map((entity) => MapEntry<String, List<UserMessageItem>>(
            entity.key,
            List<UserMessageItem>.generate(map['users'].length,
                (index) => UserMessageItem.fromJson(entity.value[index])))));
    says = Map<String, List<SayToHeItem>>.fromEntries(map['says'].entries.map(
        (entity) => MapEntry<String, List<SayToHeItem>>(
            entity.key,
            List<SayToHeItem>.generate(map['says'].length,
                (index) => SayToHeItem.fromJson(entity.value[index])))));
  }

  void save() {
    prefs.setString("messages", toJson());
  }
}

abstract class ToJson {
  Map<String, dynamic> toJson();
}

class Item {
  Item(this.id);

  final int id;

  @override
  bool operator ==(other) {
    return id == other.id;
  }

  @override
  int get hashCode {
    return id;
  }
}

class UserProfile extends Item implements ToJson {
  UserProfile({this.nickname, int id, this.avatar}) : super(id);

  factory UserProfile.fromJson(Map<String, dynamic> map) {
    return UserProfile(
        nickname: map['nickname'], id: map['id'], avatar: map['avatar']);
  }

  final String nickname;
  String avatar;

  @override
  Map<String, dynamic> toJson() {
    return {'nickname': nickname, 'id': id, avatar: avatar};
  }
}

class UserMessageItem extends Item implements ToJson {
  UserMessageItem(
      {this.time,
      this.sender,
      this.receiver,
      this.content,
      int id,
      this.isRead,
      this.sessionId})
      : super(id);

  factory UserMessageItem.fromJson(Map<String, dynamic> map) {
    return UserMessageItem(
        time: DateTime.fromMicrosecondsSinceEpoch(map['time']),
        sender: UserProfile.fromJson(map['sender']),
        receiver: UserProfile.fromJson(map['receiver']),
        content: map["content"],
        isRead: map["isRead"],
        sessionId: map["sessionId"],
        id: map["id"]);
  }

  final DateTime time;
  final UserProfile sender;
  final UserProfile receiver;
  final String content;
  bool isRead;
  final String sessionId;

  @override
  Map<String, dynamic> toJson() {
    return {
      "time": time.millisecondsSinceEpoch / 1000,
      "sender": sender.toJson(),
      "receiver": receiver.toJson(),
      "content": content,
      "isRead": isRead,
      "sessionId": sessionId,
      "id": id,
    };
  }
}

class SystemMessageItem extends Item implements ToJson {
  SystemMessageItem(
      {this.isRead, int id, this.time, this.content, this.isToAll})
      : super(id);

  factory SystemMessageItem.fromJson(Map<String, dynamic> map) {
    return SystemMessageItem(
        time: DateTime.fromMicrosecondsSinceEpoch(map['time'] * 1000),
        content: map["content"],
        isRead: map["isRead"],
        id: map["id"],
        isToAll: map["isToAll"]);
  }

  final DateTime time;
  final String content;
  bool isRead;
  final bool isToAll;

  @override
  Map<String, dynamic> toJson() {
    return {
      "time": time.millisecondsSinceEpoch / 1000,
      "content": content,
      "isRead": isRead,
      "id": id,
      "isToAll": isToAll
    };
  }
}

class SayToHeItem extends Item implements ToJson {
  SayToHeItem(
      {this.time,
      this.content,
      this.receiver,
      this.isRead,
      this.sessionId,
      int id,
      this.sender,
      this.isShowName})
      : super(id);

  factory SayToHeItem.fromJson(Map<String, dynamic> map) {
    return SayToHeItem(
      time: DateTime.fromMicrosecondsSinceEpoch(map['time'] * 1000),
      sender: UserProfile.fromJson(map['sender']),
      receiver: UserProfile.fromJson(map['receiver']),
      content: map["content"],
      isRead: map["isRead"],
      sessionId: map["sessionId"],
      id: map["id"],
      isShowName: map["isShowName"],
    );
  }

  final DateTime time;
  final UserProfile sender;
  final UserProfile receiver;
  final String content;
  bool isRead;
  final bool isShowName;
  final String sessionId;

  @override
  Map<String, dynamic> toJson() {
    return {
      "time": time.millisecondsSinceEpoch / 1000,
      "sender": sender.toJson(),
      "receiver": receiver.toJson(),
      "content": content,
      "isRead": isRead,
      "sessionId": sessionId,
      "id": id,
      "isShowName": isShowName
    };
  }
}

class TipItem extends Item implements ToJson {
  TipItem({int id, this.content, this.isRead, this.time, this.jump})
      : super(id);

  factory TipItem.fromJson(Map<String, dynamic> map) {
    return TipItem(
      time: DateTime.fromMicrosecondsSinceEpoch(map['time'] * 1000),
      content: map["content"],
      isRead: map["isRead"],
      id: map["id"],
      jump: map["jump"],
    );
  }

  final DateTime time;
  final String content;
  bool isRead;
  final String jump;

  @override
  Map<String, dynamic> toJson() {
    return {
      "time": time.millisecondsSinceEpoch / 1000,
      "content": content,
      "isRead": isRead,
      "id": id,
      "jump": jump
    };
  }
}
