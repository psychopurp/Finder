import 'dart:convert';
import 'dart:ui';
import 'package:dio/dio.dart';
import 'package:finder/config/api_client.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MessageType {
  static const int UserToUser = 1;
  static const int SayToHe = 2;
  static const int SystemMessage = 3;
  static const int Tips = 4;
}

class DataObject implements Listenable {
  static DataObject instance;
  DateTime lastRequestTime;
  List<SystemMessageItem> systems = [];
  List<TipItem> tips = [];
  Map<String, List<UserMessageItem>> users = {};
  Map<String, List<SayToHeItem>> says = {};
  SharedPreferences prefs;
  List<VoidCallback> changeEvents;
  Dio dio = ApiClient.dio;
  int systemsCount = 0;
  int tipsCount = 0;
  int usersCount = 0;
  int saysCount = 0;

  factory DataObject({VoidCallback onChange}) {
    if (instance == null) {
      instance = DataObject._init();
    }
    return instance;
  }

  DataObject._init() {
    changeEvents = [save];
    SharedPreferences.getInstance().then((value) {
      prefs = value;
    });
    load();
  }

  void onChange() {
    for (VoidCallback callback in changeEvents) {
      callback();
    }
  }

  void getData() {
    if (lastRequestTime == null) {
      lastRequestTime = DateTime.now().add(Duration(days: -1));
    }
  }

  void getMessages(int start,
      {int end,
      bool isNotReadOnly,
      bool isReceiveOnly = false,
      String sessionId}) async {
    Response response = await dio.get("get_messages/", queryParameters: {
      "start": start,
      "end": end,
      "is_not_read_only": isNotReadOnly as int,
      "is_receive_only": isReceiveOnly as int,
      "session_id": sessionId
    });
    Map<String, dynamic> data = response.data;
    if (data["status"]) {
      throw DioError(
          request: response.request,
          response: response,
          message: data["error"],
          type: DioErrorType.RESPONSE);
    } else
      addAll(data["data"]);
  }

  int get allUnReadCount {
    return saysCount + tipsCount + usersCount + systemsCount;
  }

  void updateSystemsCount() {
    systemsCount = unReadCount(systems);
  }

  void updateTipsCount() {
    tipsCount = unReadCount(tips);
  }

  void updateUsersCount() {
    usersCount = _sum(users.entries.map(
        (MapEntry<String, List<UserMessageItem>> item) =>
            unReadCount(item.value)));
  }

  void updateSaysCount() {
    saysCount = _sum(says.entries.map(
        (MapEntry<String, List<SayToHeItem>> item) => unReadCount(item.value)));
  }

  int _sum(List<int> list) {
    int sum = 0;
    for (int i in list) {
      sum += i;
    }
    return sum;
  }

  void read<T extends Item>(List<T> list) {
    for (Item i in list) {
      readOne(i);
    }
  }

  void readOne(Item item) {
    //TODO Implement read request
    item.isRead = true;
  }

  int unReadCount<T extends Item>(List<T> list) {
    int count = 0;
    for (Item i in list) {
      if (!i.isRead) {
        count++;
      }
    }
    return count;
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
    if(change){
      updateUsersCount();
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
    if(change){
      updateSystemsCount();
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
    if(change){
      updateTipsCount();
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
    if(change){
      updateSaysCount();
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
    var data = prefs.getString("messages");
    if(data == null) return;
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

  @override
  void addListener(listener) {
    changeEvents.add(listener);
  }

  @override
  void removeListener(listener) {
    changeEvents.remove(listener);
  }
}

abstract class ToJson {
  Map<String, dynamic> toJson();
}

class Item {
  Item(this.id, this.isRead);

  bool isRead;

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
  UserProfile({this.nickname, int id, this.avatar}) : super(id, false);

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
      bool isRead,
      this.sessionId})
      : super(id, isRead);

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
  final String sessionId;

  @override
  Map<String, dynamic> toJson() {
    return {
      "time": time.millisecondsSinceEpoch / 1000.0,
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
  SystemMessageItem({
    int id,
    this.time,
    this.content,
    this.isToAll,
    bool isRead,
  }) : super(id, isRead);

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
  final bool isToAll;

  @override
  Map<String, dynamic> toJson() {
    return {
      "time": time.millisecondsSinceEpoch / 1000.0,
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
      bool isRead,
      this.sessionId,
      int id,
      this.sender,
      this.isShowName})
      : super(id, isRead);

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
  final bool isShowName;
  final String sessionId;

  @override
  Map<String, dynamic> toJson() {
    return {
      "time": time.millisecondsSinceEpoch / 1000.0,
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
  TipItem({int id, this.content, bool isRead, this.time, this.jump})
      : super(id, isRead);

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
  final String jump;

  @override
  Map<String, dynamic> toJson() {
    return {
      "time": time.millisecondsSinceEpoch / 1000.0,
      "content": content,
      "isRead": isRead,
      "id": id,
      "jump": jump
    };
  }
}
