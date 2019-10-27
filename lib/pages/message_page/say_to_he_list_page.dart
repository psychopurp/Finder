import 'package:finder/plugin/avatar.dart';
import 'package:finder/routers/routes.dart';
import 'package:flutter/material.dart';

import '../../models/message_model.dart';

const double MessageHeight = 70;
const double AvatarHeight = 54;

class SayToHePage extends StatefulWidget {
  @override
  _SayToHePageState createState() => _SayToHePageState();
}

class _SayToHePageState extends State<SayToHePage> {
  MessageModel data = MessageModel();

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
        title: Text("对Ta说"),
        elevation: 0,
        centerTitle: true,
        actions: <Widget>[
          MaterialButton(
            minWidth: 10,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            child: Icon(Icons.clear_all, color: Colors.white),
            onPressed: () {
              data.readSays();
            },
          )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.only(left: 13, right: 13, top: 10),
        child: RefreshIndicator(
          onRefresh: () async {
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
        return _generateSayToHe(index);
      },
      itemCount: data.says.length,
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

  Widget _generateSayToHe(int index) {
    List<SayToHeItem> items =
        data.says[data.saysIndex[data.saysIndex.length - index - 1]];
    SayToHeItem item = items.last;
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
          Navigator.pushNamed(context, Routes.sayToHeChat, arguments: {
            "other": other,
            "sessionId": data.saysIndex[data.saysIndex.length - 1 - index]
          });
        },
        child: Dismissible(
          key: ValueKey(data.saysIndex[data.saysIndex.length - index - 1]),
          child: child,
          onDismissed: (direction) {
            setState(() {
              data.says
                  .remove(data.saysIndex[data.saysIndex.length - 1 - index]);
              data.saysIndex.removeAt(data.saysIndex.length - index - 1);
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
