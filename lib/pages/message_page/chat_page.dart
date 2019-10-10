import 'package:finder/pages/message_page/data_object.dart';
import 'package:finder/plugin/avatar.dart';
import 'package:flutter/material.dart';

const double MessageHeight = 70;
const double AvatarHeight = 54;

class ChatRouter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    UserProfile other = ModalRoute.of(context).settings.arguments;
    DataObject data = DataObject();
    int id1;
    int id2;
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
        title: Text(other.nickname),
      ),
      backgroundColor: Color.fromARGB(249, 249, 249, 249),
      body: ChatPage(sessionId),
    );
  }
}

class ChatPage extends StatefulWidget {
  ChatPage(this.sessionId);

  final String sessionId;

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  DataObject data;
  List<UserMessageItem> messages;
  bool needSync = false;
  TextEditingController _controller;
  FocusNode _focusNode;
  int sendKey;

  void update() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    data = DataObject();
    data.addListener(update);
    if (!data.users.containsKey(widget.sessionId)) {
      messages = [];
      needSync = true;
    } else {
      messages = data.users[widget.sessionId];
    }
    _controller = TextEditingController();
    _focusNode = FocusNode();
    sendKey = DateTime.now().millisecondsSinceEpoch;
  }

  @override
  void dispose() {
    super.dispose();
    data.removeListener(update);
    _controller.dispose();
    _focusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          flex: 1,
          child: NotificationListener(
            onNotification: (notification){
              _focusNode.unfocus();
              return false;
            },
            child: ListView.builder(
              itemBuilder: (context, index) {
                UserMessageItem item = messages[index];
                if (item.sender == data.self) {
                  return generateRightBubble(item);
                } else {
                  return generateLeftBubble(item);
                }
              },
              itemCount: messages.length,
            ),
          )
        ),
        Container(
          width: double.infinity,
          height: 55,
          color: Colors.white,
          child: Row(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                  child: TextField(
                    focusNode: _focusNode,
                    controller: _controller,
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
//                  child: TextField(
//                    decoration: InputDecoration(
//                      border: OutlineInputBorder(
//                        borderRadius: BorderRadius.all(Radius.circular(30)),
//                      ),
//                    ),
//                  ),
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

  Widget generateLeftBubble(UserMessageItem item) {
    return Container(
      width: double.infinity,
      height: 70,
      alignment: Alignment.centerLeft,
      child: Row(
        children: <Widget>[
          Container(
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
          Bubble(text: item.content),
        ],
      ),
    );
  }

  Widget generateRightBubble(UserMessageItem item) {
    return Container(
      width: double.infinity,
      height: 70,
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
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

  @override
  Widget build(BuildContext context) {
    Widget angle;
    if (!fromRight) {
      angle = Positioned(
        left: 5,
        top: 10,
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
        top: 10,
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
              ? EdgeInsets.only(right: 15)
              : EdgeInsets.only(left: 15),
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            text,
            style: style,
          ),
        )
      ],
    );
  }
}
