import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:finder/config/api_client.dart';
import 'package:finder/models/message_model.dart';
import 'package:finder/plugin/avatar.dart';
import 'package:finder/routers/application.dart';
import 'package:finder/routers/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_easyrefresh/material_footer.dart';
import 'package:flutter_easyrefresh/material_header.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:finder/plugin/better_text.dart';

const double MessageHeight = 70;
const double AvatarHeight = 54;

class ChatRouter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    UserProfile other = ModalRoute.of(context).settings.arguments;
    MessageModel data = MessageModel();
    int id1;
    int id2;
    if(data.self == null){
      data.getSelf();
    }
    if (other.id < data.self.id) {
      id1 = other.id;
      id2 = data.self.id;
    } else {
      id1 = data.self.id;
      id2 = other.id;
    }
    String sessionId = "$id1-$id2";
    return Scaffold(
      appBar: AppBar(
        title: BetterText(other.nickname),
      ),
      backgroundColor: const Color.fromARGB(255, 247, 247, 247),
      body: ChatPage(sessionId, other),
    );
  }
}

class ChatPage extends StatefulWidget {
  ChatPage(this.sessionId, this.other);

  final UserProfile other;
  final String sessionId;

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  MessageModel data;
  List<UserMessageItem> messages;
  bool needSync = false;
  TextEditingController _textController;
  ScrollController _scrollController;
  FocusNode _focusNode;
  int sendKey;
  Dio dio = ApiClient.dio;
  bool open = false;
  EasyRefreshController _loadController;
  bool focus = false;

  void update() {
    data.readUserMessagesBySessionId(widget.sessionId);
    setState(() {});
  }

  Future<void> moveToBottom(
      {Duration duration: const Duration(milliseconds: 600)}) async {
    await _scrollController.animateTo(reversePage ? 0 : 400,
        duration: duration, curve: Curves.easeInOut);
  }

  @override
  void initState() {
    super.initState();
    data = MessageModel();
    data.addListener(update);
    data.getDataInterval(faster: true);
    if (!data.users.containsKey(widget.sessionId)) {
      messages = [];
      needSync = true;
    } else {
      messages = data.users[widget.sessionId];
      data.readUserMessagesBySessionId(widget.sessionId);
    }
    _textController = TextEditingController();
    _focusNode = FocusNode();
    sendKey = DateTime.now().millisecondsSinceEpoch;
    _scrollController = ScrollController();
    _loadController = EasyRefreshController();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        open = true;
      }
      setState(() {
        focus = _focusNode.hasFocus;
      });
      Future.delayed(Duration(seconds: 2), () {
        open = false;
      });
      Future.delayed(Duration(milliseconds: 500), () {
        moveToBottom();
      });
    });
  }

  @override
  void dispose() {
    data.removeListener(update);
    _textController.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    data.getDataInterval();
    super.dispose();
  }

  Future<bool> sendMessage() async {
    String text = _textController.value.text;
    if (text == null || text == "") return false;
    data.getData();
    UserMessageItem item = UserMessageItem(
        sessionId: widget.sessionId,
        content: text,
        sender: data.self,
        receiver: widget.other,
        sending: true,
        time: DateTime.now(),
        id: null,
        isRead: true);
    setState(() {
      messages.add(item);
      if (needSync) {
        data.users[widget.sessionId] = messages;
        needSync = false;
      }
    });
    _textController.clear();
    moveToBottom();
    try {
      Response response = await dio.post('send_user_message/',
          data: json.encode({"receiver": widget.other.id, "content": text}));
      var resData = response.data;
      if (resData["status"]) {
        setState(() {
          item.id = resData["id"];
          item.sending = false;
          item.time = DateTime.fromMicrosecondsSinceEpoch(
              (resData['time'] * 1000000).toInt());
          messages.remove(item);
          data.addUserToUser(item);
        });
        return true;
      } else {
        setState(() {
          item.sending = false;
          item.fail = true;
          item.id = MessageModel.failCount--;
        });
        return false;
      }
    } on DioError catch (e) {
      print(e);
      setState(() {
        item.sending = false;
        item.fail = true;
        item.id = MessageModel.failCount--;
      });
      return false;
    }
  }

  Future<bool> reSend(UserMessageItem item) async {
    setState(() {
      item.sending = true;
      item.fail = false;
    });
    try {
      await data.getData();
      Response response = await dio.post('send_user_message/',
          data: json
              .encode({"receiver": widget.other.id, "content": item.content}));
      var resData = response.data;
      if (resData["status"]) {
        setState(() {
          item.id = resData["id"];
          item.sending = false;
          item.time = DateTime.fromMicrosecondsSinceEpoch(
              (resData['time'] * 1000000).toInt());
          messages.remove(item);
          data.addUserToUser(item);
        });
        return true;
      } else {
        setState(() {
          item.sending = false;
          item.fail = true;
          item.id = MessageModel.failCount--;
        });
        return false;
      }
    } on DioError catch (e) {
      print(e);
      setState(() {
        item.sending = false;
        item.fail = true;
        item.id = MessageModel.failCount--;
      });
      return false;
    }
  }

  bool get reversePage {
    double height = ScreenUtil.screenHeight / ScreenUtil.pixelRatio;
    return messages.length * 90 >= height;
  }

  @override
  Widget build(BuildContext context) {
    Widget messagesList;
    if (!reversePage) {
      messagesList = RefreshIndicator(
          onRefresh: () async {
            await data.getData();
            await data.getHistoryUserMessages(widget.sessionId);
          },
          child: ListView.builder(
            physics: AlwaysScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              UserMessageItem item = messages[index];
              if (item.sender == data.self) {
                return timeDisplay(index, false, generateRightBubble(item));
              } else {
                return timeDisplay(index, false, generateLeftBubble(item));
              }
            },
            itemCount: messages.length,
            controller: _scrollController,
          ));
    } else {
      messagesList = EasyRefresh(
          header: MaterialHeader(),
          footer: MaterialFooter(),
          controller: _loadController,
          enableControlFinishLoad: true,
          headerIndex: 0,
          child: ListView.builder(
            physics: AlwaysScrollableScrollPhysics(),
            reverse: true,
            itemBuilder: (context, index) {
              UserMessageItem item = messages[messages.length - 1 - index];
              if (item.sender == data.self) {
                return timeDisplay(index, true, generateRightBubble(item));
              } else {
                return timeDisplay(index, true, generateLeftBubble(item));
              }
            },
            itemCount: messages.length,
            controller: _scrollController,
          ),
          onRefresh: () async {
            await data.getData();
          },
          onLoad: () async {
            await data.getHistoryUserMessages(widget.sessionId);
            _loadController.finishLoad(
                success: true,
                noMore: (data.noMoreHistory.contains(widget.sessionId)));
          });
    }
    return Column(
      children: <Widget>[
        Expanded(
            flex: 1,
            child: NotificationListener(
                onNotification: (notification) {
                  if (!open) _focusNode.unfocus();
                  return false;
                },
                child: messagesList)),
        Container(
          width: double.infinity,
          height: focus ? 100 : 55,
          color: Colors.white,
          child: Row(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                  child: TextField(
                    expands: true,
                    maxLines: null,
                    minLines: null,
                    focusNode: _focusNode,
                    controller: _textController,
                    decoration: InputDecoration(
                      filled: true,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      fillColor: Color.fromARGB(255, 245, 241, 241),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ),
              AnimatedSwitcher(
                transitionBuilder: (child, animation) {
                  return ScaleTransition(
                    child: child,
                    scale: animation,
                  );
                },
                duration: Duration(milliseconds: 200),
                child: MaterialButton(
                  key: ValueKey(sendKey),
                  onPressed: () {
                    _focusNode.unfocus();
                    setState(() {
                      sendKey = DateTime.now().millisecondsSinceEpoch;
                    });
                    sendMessage();
                    moveToBottom();
                  },
                  minWidth: 10,
                  splashColor: Color.fromARGB(88, 239, 239, 239),
                  highlightColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  child: Icon(
                    Icons.send,
                    color: Color.fromARGB(255, 99, 99, 99),
                  ),
                ),
              )
            ],
          ),
        )
      ],
    );
  }

  Widget timeDisplay(int index, bool reverse, Widget child) {
    int last;
    if (reverse) {
      index = messages.length - 1 - index;
    }
    Widget text = BetterText(
      getTimeString(messages[index].time),
      style: TextStyle(
        color: Color(0xFF999999),
        fontSize: 11.3,
      ),
    );
    if (index == 0) {
      return Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(5),
          ),
          text,
          child,
        ],
      );
    } else {
      last = index - 1;
      UserMessageItem lastItem = messages[last];
      UserMessageItem item = messages[index];
      if (item.time.difference(lastItem.time).compareTo(Duration(minutes: 3)) >
          0) {
        return Column(
          children: <Widget>[
            text,
            child,
          ],
        );
      }
    }
    return child;
  }

  Widget generateLeftBubble(UserMessageItem item) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: 70),
      alignment: Alignment.centerLeft,
      child: Row(
        children: <Widget>[
          MaterialButton(
            minWidth: 0,
            padding: EdgeInsets.all(0),
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            child: Container(
              margin: EdgeInsets.only(left: 10),
              width: AvatarHeight,
              height: AvatarHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AvatarHeight / 2),
              ),
              child: Avatar(
                url: item.sender.avatar,
                avatarHeight: AvatarHeight,
              ),
            ),
            onPressed: () async {
              Application.router.navigateTo(context,
                  "${Routes.userProfile}?senderId=${item.sender.id}&heroTag=user:${item.sender.id}-${item.id}");
            },
          ),
          Bubble(text: item.content),
        ],
      ),
    );
  }

  Widget generateRightBubble(UserMessageItem item) {
    Widget prefix = Container();
    if (item.sending) {
      prefix = Container(
        margin: EdgeInsets.only(right: 15),
        width: 15,
        height: 15,
        child: CircularProgressIndicator(),
      );
    }
    if (item.fail) {
      prefix = Builder(builder: (context) {
        return MaterialButton(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          minWidth: 0,
          padding: EdgeInsets.all(0),
          onPressed: () {
            reSend(item);
          },
          child: Container(
            width: 25,
            height: 25,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(7.5)),
            child: Icon(
              Icons.error,
              size: 25,
              color: Theme.of(context).primaryColor,
            ),
          ),
        );
      });
    }
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: 50),
      margin: EdgeInsets.symmetric(vertical: 12),
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          prefix,
          Bubble(
            text: item.content,
            fromRight: true,
          ),
          Container(
            margin: EdgeInsets.only(right: 10),
            width: AvatarHeight,
            height: AvatarHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AvatarHeight / 2),
            ),
            child: Avatar(
              url: item.sender.avatar,
              avatarHeight: AvatarHeight,
            ),
          ),
        ],
      ),
    );
  }

  String getTimeString(DateTime time) {
    Map<int, String> weekdayMap = {
      1: "星期一  ${_addZero(time.hour)}:${_addZero(time.minute)}",
      2: "星期二  ${_addZero(time.hour)}:${_addZero(time.minute)}",
      3: "星期三  ${_addZero(time.hour)}:${_addZero(time.minute)}",
      4: "星期四  ${_addZero(time.hour)}:${_addZero(time.minute)}",
      5: "星期五  ${_addZero(time.hour)}:${_addZero(time.minute)}",
      6: "星期六  ${_addZero(time.hour)}:${_addZero(time.minute)}",
      7: "星期日  ${_addZero(time.hour)}:${_addZero(time.minute)}"
    };
    DateTime now = DateTime.now();
    if (now.year != time.year) {
      return "${time.year}-${time.month}-${time.day} ${_addZero(time.hour)}:${_addZero(time.minute)}";
    }
    Duration month = Duration(days: 7);
    Duration diff = now.difference(time);
    if (diff.compareTo(month) > 0) {
      return "${time.year}-${_addZero(time.month)}-${_addZero(time.day)}";
    }
    if (now.day == time.day) {
      return "${_addZero(time.hour)}:${_addZero(time.minute)}";
    }
    if (now.add(Duration(days: -1)).day == time.day) {
      return "昨天  ${_addZero(time.hour)}:${_addZero(time.minute)}";
    }
    if (now.add(Duration(days: -2)).day == time.day) {
      return "前天  ${_addZero(time.hour)}:${_addZero(time.minute)}";
    }
    return weekdayMap[time.weekday];
  }

  String _addZero(int value) => value < 10 ? "0$value" : "$value";
}

class Bubble extends StatelessWidget {
  Bubble(
      {this.text,
      this.fromRight = false,
      this.style = const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      this.background = Colors.white});

  final String text;
  final TextStyle style;
  final Color background;
  final bool fromRight;
  final double bubbleWidth =
      ScreenUtil.screenWidth / ScreenUtil.pixelRatio - 140;

  @override
  Widget build(BuildContext context) {
    double lineWidth = (bubbleWidth - 15) / 14;
    int lines = text.length ~/ lineWidth + 1;
    Widget angle;
    if (!fromRight) {
      angle = Positioned(
        left: 5,
        top: (lines * 23 + 24) / 2,
        child: Container(
          height: 15,
          width: 15,
          child: Image.asset(
            "assets/bubble.png",
            color: background,
            colorBlendMode: BlendMode.xor,
          ),
        ),
      );
    } else {
      angle = Positioned(
        right: 5,
        top: (lines * 23 + 24) / 2,
        child: Container(
          height: 15,
          width: 15,
          child: Image.asset(
            "assets/bubble_right.png",
            color: background,
            colorBlendMode: BlendMode.xor,
          ),
        ),
      );
    }
    return Stack(
      children: <Widget>[
        angle,
        Container(
          margin: fromRight
              ? EdgeInsets.only(right: 15, top: 10, bottom: 10)
              : EdgeInsets.only(left: 15, top: 10, bottom: 10),
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(16),
          ),
          constraints: BoxConstraints(maxWidth: bubbleWidth),
          child: BetterText(
            text,
            style: style,
          ),
        )
      ],
    );
  }
}
