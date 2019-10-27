import 'package:finder/models/message_model.dart';
import 'package:finder/plugin/avatar.dart';
import 'package:finder/routers/routes.dart';
import 'package:flutter/material.dart';

const double MessageHeight = 70;
const double AvatarHeight = 54;

class MessagePage extends StatefulWidget {
  @override
  _MessagePageState createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  DataObject data = DataObject();

  void update() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    data.addListener(update);
  }

  @override
  void dispose() {
    super.dispose();
    data.removeListener(update);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("消息"),
        centerTitle: true,
        actions: <Widget>[
          MaterialButton(
            minWidth: 10,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            child: Icon(Icons.clear_all, color: Colors.white),
            onPressed: () {
              data.readAll();
            },
          )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.only(left: 13, right: 13, top: 10),
        child: RefreshIndicator(
          onRefresh: () async {
            data.lastRequestTime = null;
            data.reset();
            data.getData();
          },
          child: body,
        ),
      ),
    );
  }

  Widget get body {
    return ListView.builder(
      itemBuilder: (context, index) {
        if (index == 0) {
          return _generateOtherMessagePage(
              "系统消息", Icons.computer, data.systemsCount,
              data: data.systems.length == 0 ? "" : data.systems.last.content,
              background: Color(0xFF0099FF),
              url: Routes.systemMessage);
        } else if (index == 1) {
          return _generateOtherMessagePage("提醒", Icons.error, data.tipsCount,
              data: data.tips.length == 0 ? "" : data.tips.last.content,
              background: Color(0xFFFF9933),
              url: Routes.tips);
        } else if (index == 2) {
          return _generateOtherMessagePage("对Ta说", Icons.person, data.saysCount,
              background: Color(0xFFFF6666), url: Routes.sayToHe);
        }
        return _generateUserMessage(index - 3);
      },
      itemCount: data.users.length + 3,
    );
  }

  Widget get pop => Builder(builder: (context) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: Theme.of(context).primaryColor),
        );
      });

  Widget _generateOtherMessagePage(String title, IconData icon, int unReadCount,
      {Color background = Colors.orange,
      String data,
      VoidCallback onPress,
      String url}) {
    Widget titleWidget = Text(
      title,
      style: TextStyle(
        fontSize: 16,
      ),
      textAlign: TextAlign.left,
    );

    Widget child = _withBottomBorder(
      Row(
        children: <Widget>[
          Container(
            width: AvatarHeight,
            height: AvatarHeight,
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(AvatarHeight / 2),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 30,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10),
          ),
          Expanded(
            flex: 1,
            child: data != null && data != ""
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      titleWidget,
                      Padding(
                        padding: EdgeInsets.all(3),
                      ),
                      Text(
                        data,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: Color(0xFF777777),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )
                    ],
                  )
                : titleWidget,
          ),
          unReadCount != 0
              ? Stack(
                  children: <Widget>[
                    Icon(
                      Icons.chevron_right,
                      color: Color(0xBBBBBBBB),
                      size: 30,
                    ),
                    Positioned(
                      right: 1,
                      top: 1,
                      child: pop,
                    )
                  ],
                )
              : Icon(
                  Icons.chevron_right,
                  color: Color(0xBBBBBBBB),
                  size: 30,
                ),
        ],
      ),
    );
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Navigator.pushNamed(context, url);
      },
      child: child,
    );
  }

  Widget _withBottomBorder(Widget child) {
    return Column(
      children: <Widget>[
        Container(width: double.infinity, height: MessageHeight, child: child),
        Padding(
          padding: EdgeInsets.only(right: 10, left: 70),
          child: Container(
            color: Color(0xEEEEEEEE),
            height: 1,
            width: double.infinity,
          ),
        ),
      ],
    );
  }

  Widget _generateUserMessage(int index) {
    List<UserMessageItem> items =
        data.users[data.usersIndex[data.usersIndex.length - index - 1]];
    UserMessageItem item = items.last;
    int unReadCount = data.unReadCount(items);
    UserProfile other;
    if (item.sender == data.self) {
      other = item.receiver;
    } else {
      other = item.sender;
    }
    Widget tips = Container(
      width: unReadCount < 10 ? 20 : 24,
      height: 20,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: Text(
        unReadCount < 100 ? "$unReadCount" : "99",
        style: TextStyle(
          color: Colors.white,
          fontSize: 14,
        ),
      ),
    );
    Widget child = _withBottomBorder(
      Row(
        children: <Widget>[
          Container(
              width: AvatarHeight,
              height: AvatarHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AvatarHeight / 2),
              ),
              child: Avatar(
                url: other.avatar,
                avatarHeight: AvatarHeight,
              )),
          Padding(
            padding: EdgeInsets.all(10),
          ),
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(other.nickname),
                Padding(
                  padding: EdgeInsets.all(3),
                ),
                Text(
                  item.content,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: Color(0xFF777777),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )
              ],
            ),
          ),
          Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(right: 10, top: 13, bottom: 5),
                child: Text(
                  getTimeString(item.time),
                  style: TextStyle(fontSize: 12),
                ),
              ),
              unReadCount == 0 ? Container() : tips
            ],
          ),
        ],
      ),
    );
    return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          Navigator.pushNamed(context, Routes.chat, arguments: other);
        },
        child: Dismissible(
          key: ValueKey(data.usersIndex[data.usersIndex.length - index - 1]),
          child: child,
          onDismissed: (direction) {
            setState(() {
              data.users
                  .remove(data.usersIndex[data.usersIndex.length - 1 - index]);
              data.usersIndex.removeAt(data.usersIndex.length - index - 1);
            });
          },
        ));
  }

  String getTimeString(DateTime time) {
    Map<int, String> weekdayMap = {
      1: "星期一",
      2: "星期二",
      3: "星期三",
      4: "星期四",
      5: "星期五",
      6: "星期六",
      7: "星期日"
    };
    DateTime now = DateTime.now();
    if (now.year != time.year) {
      return "${time.year}-${time.month}-${time.day}";
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
      return "昨天";
    }
    if (now.add(Duration(days: -2)).day == time.day) {
      return "前天";
    }
    return weekdayMap[time.weekday];
  }

  String _addZero(int value) => value < 10 ? "0$value" : "$value";
}
