import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:dio/dio.dart';
import 'package:finder/config/api_client.dart';
import 'package:finder/config/global.dart';
import 'package:finder/pages/login_page.dart';
import 'package:finder/plugin/avatar.dart';
import 'package:finder/provider/user_provider.dart';
import 'package:finder/public.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MessageType {
  static const int UserToUser = 1;
  static const int SayToHe = 2;
  static const int SystemMessage = 3;
  static const int Tips = 4;
}

class MessageModel implements Listenable {
  static MessageModel instance;
  DateTime lastRequestTime;
  List<SystemMessageItem> systems = [];
  List<TipItem> tips = [];
  Map<String, List<UserMessageItem>> users = {};
  Map<String, List<SayToHeItem>> says = {};
  SharedPreferences prefs;
  List<VoidCallback> changeEvents;
  List<String> usersIndex = [];
  List<String> saysIndex = [];
  Set<String> noMoreHistory = Set<String>();
  bool noMoreHistoryMessage = false;
  UserProfile loadUser;
  UserProfile self;
  Dio dio = ApiClient.dio;
  int systemsCount = 0;
  int tipsCount = 0;
  int usersCount = 0;
  int saysCount = 0;
  bool init = false;
  Timer _timer;
  static int failCount = -1;
  BuildContext indexContext;

  factory MessageModel({VoidCallback onChange}) {
    if (instance == null) {
      instance = MessageModel._init();
    }
    if(instance.self == null){
      instance.getSelf();
    }
    return instance;
  }

  getDataInterval({Duration duration: const Duration(seconds: 8), bool faster =  false}) {
    if(faster){
      duration = const Duration(seconds: 3);
    }
    if (_timer != null) {
      cancelTimer();
    }
    _timer = Timer.periodic(duration, (t) {
      getData();
    });
  }

  cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }

  MessageModel._init() {
    changeEvents = [save];
    SharedPreferences.getInstance().then((value) {
      prefs = value;
      load();
      init = true;
      getSelf().then((status) {
        if (status) {
          getData();
        }
      });
      getDataInterval();
    });
  }

  Future<void> reset() async {
    systems = [];
    tips = [];
    users = {};
    says = {};
    usersIndex = [];
    saysIndex = [];
    noMoreHistory = Set();
    prefs.remove("messages");
    lastRequestTime = null;
    loadUser = self;
    noMoreHistoryMessage = false;
  }

   List<VoidCallback> clearInstance() {
    systems = [];
    tips = [];
    users = {};
    says = {};
    usersIndex = [];
    saysIndex = [];
    noMoreHistory = Set();
    lastRequestTime = null;
    loadUser = self;
    noMoreHistoryMessage = false;
    changeEvents.remove(save);
    return changeEvents;
  }

  Future<bool> getSelf() async {
    var userData = await apiClient.getUserProfile();
    if(userData == null){

    }
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
    DateTime old = lastRequestTime;
    try{
      DateTime reqTime = DateTime.now();
      int time;
      if (lastRequestTime != null) {
        time = lastRequestTime.millisecondsSinceEpoch ~/ 1000;
      }
      await getMessages(time);
      lastRequestTime = reqTime.subtract(Duration(seconds: 10));
    }on DioError catch(e){
      print(e);
      lastRequestTime = old;
    }
  }

  Future<void> readSaysMessagesBySessionId(String sessionId) async {
    if (!says.containsKey(sessionId)) return;
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
    if (response.data["status"]) {
      users[sessionId].forEach((item) {
        item.isRead = true;
      });
      updateUsersCount();
      onChange();
    }
  }

  Future<void> readSystemMessages() async {
    bool value = true;
    systems.forEach((item) {
      value = value && item.isRead;
    });
    if (value) return;
    Response response = await dio.post('read_system_messages/');
    if (response.data["status"]) {
      systems.forEach((item) {
        item.isRead = true;
      });
      updateSystemsCount();
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

  Future<void> readTips() async {
    Response response = await dio.post("read_tips/");
    if (response.data["status"]) {
      tips.forEach((item) {
        item.isRead = true;
      });
      updateTipsCount();
      onChange();
    }
  }

  Future<void> readSays() async {
    Response response = await dio.post("read_says/");
    if (response.data["status"]) {
      tips.forEach((item) {
        item.isRead = true;
      });
      updateTipsCount();
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

  Future<void> getHistorySystemMessage() async {
    if (noMoreHistoryMessage) return;
    List<SystemMessageItem> messages = systems;
    DateTime endTime;
    if (messages.length == 0)
      endTime = DateTime.now();
    else {
      SystemMessageItem first = messages[0];
      endTime = first.time;
    }
    int end = endTime.millisecondsSinceEpoch ~/ 1000;
    Map<String, dynamic> queryParameters = {
      "end": end,
    };
    Response response = await dio.get("get_history_system_message/",
        queryParameters: queryParameters);
    Map<String, dynamic> data = response.data;
    if (!data["status"]) {
      throw DioError(
          request: response.request,
          response: response,
//          message: data["error"],
          type: DioErrorType.RESPONSE);
    } else {
      if (data['data'].length == 0) {
        noMoreHistoryMessage = true;
      } else
        addAll(
            List<Map<String, dynamic>>.generate(data["data"].length,
                (index) => data["data"][data["data"].length - index - 1]),
            addFirst: true);
    }
  }

  Future<void> getHistoryUserMessages(String sessionId) async {
    if (noMoreHistory.contains(sessionId)) return;
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
    if (!data["status"]) {
      throw DioError(
          request: response.request,
          response: response,
//          message: data["error"],
          type: DioErrorType.RESPONSE);
    } else {
      if (data['data'].length == 0) {
        noMoreHistory.add(sessionId);
      } else
        addAll(
            List<Map<String, dynamic>>.generate(data["data"].length,
                (index) => data["data"][data["data"].length - index - 1]),
            addFirst: true);
    }
  }

  Future<void> getHistorySays(String sessionId) async {
    if (noMoreHistory.contains(sessionId)) return;
    List<SayToHeItem> messages = says[sessionId];
    DateTime endTime;
    if (messages.length == 0)
      endTime = DateTime.now();
    else {
      SayToHeItem first = messages[0];
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
    if (!data["status"]) {
      throw DioError(
          request: response.request,
          response: response,
//          message: data["error"],
          type: DioErrorType.RESPONSE);
    } else {
      if (data['data'].length == 0) {
        noMoreHistory.add(sessionId);
      } else
        addAll(
            List<Map<String, dynamic>>.generate(data["data"].length,
                    (index) => data["data"][data["data"].length - index - 1]),
            addFirst: true);
    }
  }


  toLogin() async {
    Global.isLogin = false;
    Global.token = "";
    await MessageModel().cancelTimer();
    await MessageModel().reset();
    ApiClient.dio.options.headers['token'] = "";
    var prefs = await SharedPreferences.getInstance();
    prefs.clear();
    MessageModel.instance = null;
    Provider.of<UserProvider>(indexContext).userInfo = null;
    Navigator.of(indexContext).pushAndRemoveUntil(
        new MaterialPageRoute(builder: (context) => LoginPage()),
            (route) => route == null);
  }

  Future<void> getMessages(int start,
      {int end,
      bool isNotReadOnly,
      bool isReceiveOnly,
      String sessionId}) async {
    Map<String, dynamic> queryParameters = {};
    if (start != null) {
      queryParameters["start"] = start;
    }
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
    if (!data["status"]) {
      BotToast.showText(
          text: "登录状态失效，请重新登录",
          align: Alignment(0, 0.8),
          contentColor: Color(0xff888888),
          duration: Duration(seconds: 5));
      toLogin();
    } else {
      addAll(List<Map<String, dynamic>>.generate(
          data["data"].length, (index) => data["data"][index]));
    }
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
    saysCount = _sum(count);
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
      readOne(i, updateNow: false);
    }
  }

  Future<void> readOne(Item item, {bool updateNow = true}) async {
    Response response = await dio.post('read_message/', data: {
      "id": item.id,
    });
    if (response.data["status"]) {
      item.isRead = true;
      if (updateNow) {
        updateTipsCount();
        updateSystemsCount();
        updateSaysCount();
        updateUsersCount();
      }
      onChange();
    }
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
      if (init) {
        usersIndex.add(messageItem.sessionId);
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
        if (addFirst) {
          says[messageItem.sessionId].insert(0, messageItem);
        } else {
          says[messageItem.sessionId].add(messageItem);
          if (init) {
            saysIndex.remove(messageItem.sessionId);
            saysIndex.add(messageItem.sessionId);
          }
        }
        change = true;
      }
    } else {
      change = true;
      says[messageItem.sessionId] = [messageItem];
      saysIndex.add(messageItem.sessionId);
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
      'usersIndex': usersIndex,
      'saysIndex': saysIndex,
      "noMoreHistory": noMoreHistory.toList(),
      "noMoreHistoryMessage": noMoreHistoryMessage
    };
    return json.encode(result);
  }

  void load() {
    if (prefs == null) return;
    var data = prefs.getString("messages");
    if (data == null) return;
    var map = json.decode(data);
    var time = map["lastRequestTime"];
    if (time != null)
      lastRequestTime = DateTime.fromMillisecondsSinceEpoch(time);
    systems = List<SystemMessageItem>.generate(map['systems']?.length ?? 0,
        (index) => SystemMessageItem.fromJson(map['systems'][index]));
    tips = List<TipItem>.generate(map['tips']?.length ?? 0,
        (index) => TipItem.fromJson(map['tips'][index]));
    users = Map<String, List<UserMessageItem>>.fromEntries(
        List<MapEntry<String, List<UserMessageItem>>>.generate(
            map['users']?.length ?? 0, (index) {
      MapEntry entity = map['users'].entries.elementAt(index);
      return MapEntry<String, List<UserMessageItem>>(
          entity.key,
          List<UserMessageItem>.generate(entity.value?.length ?? 0,
              (index) => UserMessageItem.fromJson(entity.value[index])));
    }));
    says = Map<String, List<SayToHeItem>>.fromEntries(
        List<MapEntry<String, List<SayToHeItem>>>.generate(
            map['says']?.length ?? 0, (index) {
      MapEntry entity = map['says'].entries.elementAt(index);
      return MapEntry<String, List<SayToHeItem>>(
          entity.key,
          List<SayToHeItem>.generate(entity.value?.length ?? 0,
              (index) => SayToHeItem.fromJson(entity.value[index])));
    }));
    loadUser = UserProfile.fromJson(map["user"]);
    usersIndex = List<String>.generate(
        map['usersIndex']?.length ?? 0, (index) => map['usersIndex'][index]);
    saysIndex = List<String>.generate(
        map['saysIndex']?.length ?? 0, (index) => map['saysIndex'][index]);
    noMoreHistory = List<String>.generate(map["noMoreHistory"]?.length ?? 0,
        (index) => map["noMoreHistory"][index]).toSet();
    noMoreHistoryMessage = map['noMoreHistoryMessage'] ?? false;
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
    String avatar = Avatar.getImageUrl(map["avatar"]);
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
    return {'nickname': nickname, 'id': id, "avatar": avatar};
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
      this.sessionId,
      this.fail = false,
      this.sending = false})
      : super(id, isRead: isRead);

  factory UserMessageItem.fromJson(Map<String, dynamic> map) {
    UserProfile receiver = UserProfile.fromJson(map['receiver']);
    return UserMessageItem(
      time:
          DateTime.fromMicrosecondsSinceEpoch((map['time'] * 1000000).toInt()),
      sender: UserProfile.fromJson(map['sender']),
      receiver: receiver,
      content: map["content"],
      isRead: !(!map["isRead"] && receiver == MessageModel().self),
      sessionId: map["sessionId"],
      id: map["id"],
      sending: map['sending'] ?? false,
      fail: map['fail'] ?? false,
    );
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
      "sending": sending,
      "fail": fail
    };
  }
}

class SystemMessageItem extends Item implements ToJson {
  SystemMessageItem(
      {int id,
      this.time,
      this.content,
      this.isToAll,
      bool isRead,
      this.fail = false,
      this.receive = true,
      this.sending = false})
      : super(id, isRead: isRead);

  factory SystemMessageItem.fromJson(Map<String, dynamic> map) {
    return SystemMessageItem(
      time:
          DateTime.fromMicrosecondsSinceEpoch((map['time'] * 1000000).toInt()),
      content: map["content"],
      isRead: map["isRead"],
      id: map["id"],
      isToAll: map["isToAll"],
      receive: map["receive"],
      sending: map['sending'] ?? false,
      fail: map['fail'] ?? false,
    );
  }

  DateTime time;
  final String content;
  final bool isToAll;
  final bool receive;
  bool sending;
  bool fail;

  @override
  Map<String, dynamic> toJson() {
    return {
      "time": time.millisecondsSinceEpoch / 1000,
      "content": content,
      "isRead": isRead,
      "id": id,
      "isToAll": isToAll,
      "receive": receive,
      "sending": sending,
      "fail": fail
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
      this.fail = false,
      this.sender,
      this.sending = false,
      this.isShowName})
      : super(id, isRead: isRead);

  factory SayToHeItem.fromJson(Map<String, dynamic> map) {
//    print(map);
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
      sending: map['sending'] ?? false,
      fail: map['fail'] ?? false,
    );
  }

  DateTime time;
  final UserProfile sender;
  final UserProfile receiver;
  final String content;
  final bool isShowName;
  final String sessionId;
  bool sending;
  bool fail = false;

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
      "isShowName": isShowName,
      "sending": sending,
      "fail": fail
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
