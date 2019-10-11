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
  List<String> usersIndex = [];
  UserProfile loadUser;
  UserProfile self;
  Dio dio = ApiClient.dio;
  int systemsCount = 0;
  int tipsCount = 0;
  int usersCount = 0;
  int saysCount = 0;
  bool init = false;
  static int failCount = -1;

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
    init = true;
    getSelf().then((status) {
      if (status) {
        getData();
      }
    });
  }

  void reset() async {
    systems = [];
    tips = [];
    users = {};
    says = {};
    usersIndex = [];
    prefs.remove("messages");
    lastRequestTime = null;
    loadUser = self;
  }

  Future<bool> getSelf() async {
    var userData = await apiClient.getUserProfile();
    var user = userData['data'];
    self = UserProfile.fromJson(user);
    if (loadUser != null && loadUser != self) {
      reset();
      getData();
      return false;
    }
    return true;
  }

  void onChange() {
    for (VoidCallback callback in changeEvents) {
      callback();
    }
  }

  Future<void> getData() async {
    print("Try Get Messages.");
    if (lastRequestTime == null) {
      lastRequestTime = DateTime.now().add(Duration(days: -1));
    }
    DateTime reqTime = DateTime.now();
    await getMessages(lastRequestTime.millisecondsSinceEpoch ~/ 1000);
    lastRequestTime = reqTime;
  }

  Future<void> readUserMessagesBySessionId(String sessionId) async {
    if (!users.containsKey(sessionId)) return;
    bool value = true;
    users[sessionId].forEach((item) {
      value = value && item.isRead;
    });
    if (value) return;
    Response response = await dio.post('read_message_by_session/', data: {
      "sessionId": sessionId,
    });
    print(response.data);
    if (response.data["status"]) {
      users[sessionId].forEach((item) {
        item.isRead = true;
      });
      updateUsersCount();
      onChange();
    }
  }

  Future<void> readSayToHeMessagesBySessionId(String sessionId) async {
    if (!users.containsKey(sessionId)) return;
    bool value = true;
    says[sessionId].forEach((item) {
      value = value && item.isRead;
    });
    if (value) return;
    Response response = await dio.post('read_message_by_session/', data: {
      "sessionId": sessionId,
    });
    if (response.data["status"]) {
      says[sessionId].forEach((item) {
        item.isRead = true;
      });
      updateSaysCount();
      onChange();
    }
  }

  Future<void> readMessage(Item item) async {
    Response response = await dio.post('read_message/', data: {
      "id": item.id,
    });
    if (response.data["status"]) {
      item.isRead = true;
      updateTipsCount();
      updateSystemsCount();
      onChange();
    }
  }

  Future<void> readAll() async {
    Response response = await dio.post("read_all_messages/");
    if (response.data["status"]) {
      users.forEach((key, value) {
        value.forEach((item) {
          item.isRead = true;
        });
      });
      says.forEach((key, value) {
        value.forEach((item) {
          item.isRead = true;
        });
      });
      systems.forEach((item) {
        item.isRead = true;
      });
      tips.forEach((item) {
        item.isRead = true;
      });
      updateSystemsCount();
      updateTipsCount();
      updateSaysCount();
      updateUsersCount();
      onChange();
    }
  }

  Future<void> getHistoryUserMessages(String sessionId) async {
    if (!users.containsKey(sessionId)) return;
    List<UserMessageItem> messages = users[sessionId];
    DateTime endTime;
    if (messages.length == 0)
      endTime = DateTime.now();
    else {
      UserMessageItem first = messages[0];
      endTime = first.time;
    }
    int end = endTime.millisecondsSinceEpoch ~/ 1000;
    Map<String, dynamic> queryParameters = {
      "end": end,
      "sessionId": sessionId,
    };
    Response response =
    await dio.get("get_history_message/", queryParameters: queryParameters);
    Map<String, dynamic> data = response.data;
//    print(data);
    if (!data["status"]) {
      throw DioError(
          request: response.request,
          response: response,
          message: data["error"],
          type: DioErrorType.RESPONSE);
    } else
      addAll(
          List<Map<String, dynamic>>.generate(data["data"].length,
                  (index) => data["data"][data["data"].length - index - 1]),
          addFirst: true);
  }

  Future<void> getMessages(int start,
      {int end,
        bool isNotReadOnly,
        bool isReceiveOnly,
        String sessionId}) async {
    Map<String, dynamic> queryParameters = {
      "start": start,
    };
    if (isNotReadOnly != null) {
      queryParameters["isNotReadOnly"] = isNotReadOnly ? 1 : 0;
    }
    if (isReceiveOnly != null) {
      queryParameters["isReceiveOnly"] = isReceiveOnly ? 1 : 0;
    }
    if (sessionId != null) {
      queryParameters["sessionId"] = sessionId;
    }
    Response response =
    await dio.get("get_messages/", queryParameters: queryParameters);
    Map<String, dynamic> data = response.data;
//    print(data);
    if (!data["status"]) {
      throw DioError(
          request: response.request,
          response: response,
          message: data["error"],
          type: DioErrorType.RESPONSE);
    } else
      addAll(List<Map<String, dynamic>>.generate(
          data["data"].length, (index) => data["data"][index]));
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
    List<int> count = [];
    users.forEach((key, value) => count.add(unReadCount(value)));
    usersCount = _sum(count);
  }

  void updateSaysCount() {
    List<int> count = [];
    says.forEach((key, value) => count.add(unReadCount(value)));
    usersCount = _sum(count);
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

  void addAll(List<Map<String, dynamic>> data, {bool addFirst: false}) {
    bool change = false;
    for (var item in data) {
      bool res = add(item, changeNow: false, addFirst: addFirst);
      change = change || res;
    }
    if (change) {
      onChange();
    }
  }

  bool add(Map<String, dynamic> item,
      {bool changeNow: true, bool addFirst: false}) {
    bool change = false;
    switch (item["type"]) {
      case MessageType.UserToUser:
        UserMessageItem messageItem = UserMessageItem.fromJson(item);
        change = addUserToUser(messageItem, addFirst: addFirst);
        break;
      case MessageType.SystemMessage:
        SystemMessageItem messageItem = SystemMessageItem.fromJson(item);
        change = addSystemMessage(messageItem, addFirst: addFirst);
        break;
      case MessageType.SayToHe:
        SayToHeItem messageItem = SayToHeItem.fromJson(item);
        change = addSay(messageItem, addFirst: addFirst);
        break;
      case MessageType.Tips:
        TipItem messageItem = TipItem.fromJson(item);
        change = addTip(messageItem, addFirst: addFirst);
        break;
    }
    if (change && changeNow) {
      onChange();
    }
    return change;
  }

  bool addUserToUser(UserMessageItem messageItem, {bool addFirst: false}) {
    bool change = false;
    if (users.containsKey(messageItem.sessionId)) {
      if (!users[messageItem.sessionId].contains(messageItem)) {
        if (addFirst) {
          users[messageItem.sessionId].insert(0, messageItem);
        } else {
          users[messageItem.sessionId].add(messageItem);
          if (init) {
            usersIndex.remove(messageItem.sessionId);
            usersIndex.add(messageItem.sessionId);
          }
        }
        change = true;
      }
    } else {
      change = true;
      users[messageItem.sessionId] = [messageItem];
      if (!addFirst) {
        if (init) {
          usersIndex.add(messageItem.sessionId);
        }
      }
    }
    if (change) {
      updateUsersCount();
    }
    return change;
  }

  bool addSystemMessage(SystemMessageItem messageItem, {bool addFirst: false}) {
    bool change = false;
    if (!systems.contains(messageItem)) {
      //TODO 此写法没有优化, 可用二分查找优化
      if (addFirst)
        systems.insert(0, messageItem);
      else
        systems.add(messageItem);
      change = true;
    }
    if (change) {
      updateSystemsCount();
    }
    return change;
  }

  bool addTip(TipItem messageItem, {bool addFirst: false}) {
    bool change = false;
    if (!tips.contains(messageItem)) {
      //TODO 此写法没有优化, 可用二分查找优化
      if (addFirst)
        tips.insert(0, messageItem);
      else
        tips.add(messageItem);
      change = true;
    }
    if (change) {
      updateTipsCount();
    }
    return change;
  }

  bool addSay(SayToHeItem messageItem, {bool addFirst: false}) {
    bool change = false;
    if (says.containsKey(messageItem.sessionId)) {
      if (!says[messageItem.sessionId].contains(messageItem)) {
        //TODO 此写法没有优化, 可用二分查找优化
        if (addFirst)
          says[messageItem.sessionId].insert(0, messageItem);
        else
          says[messageItem.sessionId].add(messageItem);
        change = true;
      }
    } else {
      change = true;
      says[messageItem.sessionId] = [messageItem];
    }
    if (change) {
      updateSaysCount();
    }
    return change;
  }

  String toJson() {
    Map<String, dynamic> result = {
      'lastRequestTime': lastRequestTime?.millisecondsSinceEpoch,
      'systems': List<Map<String, dynamic>>.generate(
          systems.length, (index) => systems[index].toJson()),
      'tips': List<Map<String, dynamic>>.generate(
          tips.length, (index) => tips[index].toJson()),
      'users': users.map((key, value) =>
          MapEntry<String, List<Map<String, dynamic>>>(
              key,
              List<Map<String, dynamic>>.generate(
                  value.length, (index) => value[index].toJson()))),
      'says': says.map((key, value) =>
          MapEntry<String, List<Map<String, dynamic>>>(
              key,
              List<Map<String, dynamic>>.generate(
                  value.length, (index) => value[index].toJson()))),
      'user': self?.toJson(),
      'usersIndex': usersIndex
    };
    return json.encode(result);
  }

  void load() {
    if (prefs == null) return;
    var data = prefs.getString("messages");
    if (data == null) return;
    var map = json.decode(data);
    lastRequestTime =
        DateTime.fromMillisecondsSinceEpoch(map["lastRequestTime"]);
    systems = List<SystemMessageItem>.generate(map['system'].length,
            (index) => SystemMessageItem.fromJson(map['system'][index]));
    tips = List<TipItem>.generate(
        map['tips'].length, (index) => TipItem.fromJson(map['tips'][index]));
    users = Map<String, List<UserMessageItem>>.fromEntries(map['users']
        .entries
        .map((entity) =>
        MapEntry<String, List<UserMessageItem>>(
            entity.key,
            List<UserMessageItem>.generate(map['users'].length,
                    (index) =>
                    UserMessageItem.fromJson(entity.value[index])))));
    says = Map<String, List<SayToHeItem>>.fromEntries(map['says'].entries.map(
            (entity) =>
            MapEntry<String, List<SayToHeItem>>(
                entity.key,
                List<SayToHeItem>.generate(map['says'].length,
                        (index) =>
                        SayToHeItem.fromJson(entity.value[index])))));
    loadUser = UserProfile.fromJson(map["user"]);
    usersIndex = map['usersIndex'];
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
  Item(this.id, {this.isRead: true});

  bool isRead;

  int id;

  @override
  bool operator ==(other) {
    return (other.runtimeType == this.runtimeType) && (id == other.id);
  }

  @override
  int get hashCode {
    return id;
  }
}

class UserProfile extends Item implements ToJson {
  UserProfile({this.nickname, int id, this.avatar}) : super(id, isRead: false);
  static Map<int, UserProfile> users = {};

  factory UserProfile.fromJson(Map<String, dynamic> map) {
    String avatar = map["avatar"];
    if (!avatar.startsWith("http")) {
      avatar = ApiClient.host + avatar;
    }
    if (users.containsKey(map["id"])) {
      UserProfile user = users[map["id"]];
      user.avatar = avatar;
      return user;
    }
    UserProfile user =
    UserProfile(nickname: map['nickname'], id: map['id'], avatar: avatar);
    users[user.id] = user;
    return user;
  }

  final String nickname;
  String avatar;

  @override
  Map<String, dynamic> toJson() {
    return {'nickname': nickname, 'id': id, avatar: avatar};
  }
}

class UserMessageItem extends Item implements ToJson {
  UserMessageItem({this.time,
    this.sender,
    this.receiver,
    this.content,
    int id,
    bool isRead,
    this.sessionId,
    this.sending = false})
      : super(id, isRead: isRead);

  factory UserMessageItem.fromJson(Map<String, dynamic> map) {
    UserProfile receiver = UserProfile.fromJson(map['receiver']);
    return UserMessageItem(
        time: DateTime.fromMicrosecondsSinceEpoch(
            (map['time'] * 1000000).toInt()),
        sender: UserProfile.fromJson(map['sender']),
        receiver: receiver,
        content: map["content"],
        isRead: !(!map["isRead"] && receiver == DataObject().self),
        sessionId: map["sessionId"],
        id: map["id"]);
  }

  DateTime time;
  final UserProfile sender;
  final UserProfile receiver;
  final String content;
  final String sessionId;
  bool sending;
  bool fail = false;

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
  }) : super(id, isRead: isRead);

  factory SystemMessageItem.fromJson(Map<String, dynamic> map) {
    return SystemMessageItem(
        time: DateTime.fromMicrosecondsSinceEpoch(
            (map['time'] * 1000000).toInt()),
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
      "time": time.millisecondsSinceEpoch / 1000,
      "content": content,
      "isRead": isRead,
      "id": id,
      "isToAll": isToAll
    };
  }
}

class SayToHeItem extends Item implements ToJson {
  SayToHeItem({this.time,
    this.content,
    this.receiver,
    bool isRead,
    this.sessionId,
    int id,
    this.sender,
    this.isShowName})
      : super(id, isRead: isRead);

  factory SayToHeItem.fromJson(Map<String, dynamic> map) {
    return SayToHeItem(
      time:
      DateTime.fromMicrosecondsSinceEpoch((map['time'] * 1000000).toInt()),
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
  TipItem({int id, this.content, bool isRead, this.time, this.jump})
      : super(id, isRead: isRead);

  factory TipItem.fromJson(Map<String, dynamic> map) {
    return TipItem(
      time:
      DateTime.fromMicrosecondsSinceEpoch((map['time'] * 1000000).toInt()),
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
      "time": time.millisecondsSinceEpoch / 1000,
      "content": content,
      "isRead": isRead,
      "id": id,
      "jump": jump
    };
  }
}
