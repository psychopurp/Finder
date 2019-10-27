import 'package:flutter/material.dart';
import '../../models/message_model.dart';

const double MessageHeight = 70;
const double AvatarHeight = 54;

class TipsPage extends StatefulWidget {
  @override
  _TipsPageState createState() => _TipsPageState();
}

class _TipsPageState extends State<TipsPage> {
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
        title: Text("提醒"),
        elevation: 0,
        centerTitle: true,
        actions: <Widget>[
          MaterialButton(
            minWidth: 10,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            child: Icon(Icons.clear_all, color: Colors.white),
            onPressed: () {
              data.readTips();
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

  Widget get pop => Builder(builder: (context) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: Theme.of(context).primaryColor),
        );
      });

  Widget get body {
    return ListView.builder(
      itemBuilder: (context, index) {
        return _generateTip(index);
      },
      itemCount: data.tips.length,
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

  Widget _generateTip(int index) {
    TipItem item = data.tips[index];
    Widget child = _withBottomBorder(
      Row(
        children: <Widget>[
          Container(
            width: AvatarHeight,
            height: AvatarHeight,
            decoration: BoxDecoration(
              color: Color(0xFFFF9933),
              borderRadius: BorderRadius.circular(AvatarHeight / 2),
            ),
            child: Icon(
              Icons.error,
              color: Colors.white,
              size: 30,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10),
          ),
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
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
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Text(
                getTimeString(item.time),
              ),
              Padding(
                padding: EdgeInsets.only(right: 10, top: 13, bottom: 5),
                child: Text(
                  getTimeString(item.time),
                  style: TextStyle(fontSize: 12),
                ),
              ),
              item.isRead ? Container() : pop
            ],
          ),
        ],
      ),
    );
    String jump = item.jump;
    return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          data.readOne(item);
          Navigator.pushNamed(context, jump);
        },
        child: Dismissible(
          key: ValueKey(item.id),
          child: child,
          onDismissed: (direction) {
            setState(() {
              data.tips.remove(item);
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
