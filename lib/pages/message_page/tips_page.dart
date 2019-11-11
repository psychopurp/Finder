import 'package:dio/dio.dart';
import 'package:finder/config/api_client.dart';
import 'package:finder/models/collections_model.dart';
import 'package:finder/models/he_says_item.dart';
import 'package:finder/models/recruit_model.dart';
import 'package:finder/models/topic_comments_model.dart';
import 'package:finder/models/topic_model.dart';
import 'package:finder/routers/application.dart';
import 'package:finder/routers/routes.dart';
import 'package:flutter/material.dart';
import '../../models/message_model.dart';

const double MessageHeight = 70;
const double AvatarHeight = 54;

class TipsPage extends StatefulWidget {
  @override
  _TipsPageState createState() => _TipsPageState();
}

class _TipsPageState extends State<TipsPage> {
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
        title: Text("提醒"),
        elevation: 0,
        centerTitle: true,
        actions: <Widget>[
          MaterialButton(
            minWidth: 10,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            child: Icon(IconData(0xe609, fontFamily: 'clear'),
                color: Colors.white),
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
        return _generateTip(data.tips.length - index - 1);
      },
      itemCount: data.tips.length,
    );
  }

  Widget _withBottomBorder(Widget child) {
    return Column(
      children: <Widget>[
        Container(width: double.infinity, height: MessageHeight, child: child),
        Padding(
          padding: EdgeInsets.only(right: 10, left: 10),
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                getTimeString(item.time),
              ),
              Padding(
                padding: EdgeInsets.all(8),
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
          jumpHandler(jump);
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

  Future<void> jumpHandler(String jump) async {
    List<String> jumpPara = jump.split(":");
    String page = jumpPara[0];
    int id = int.parse(jumpPara[1]);
    switch (page) {
      case "recruit":
        var data = await getRecruitData(id);
        if (data != null) {
          Navigator.of(context)
              .pushNamed(Routes.recruitDetail, arguments: data);
        }
        break;
      case "topic":
        var item = await getTopic(id);
        print(
            "topic  ${item.title}  ============================================");
        if (item != null) {
          Application.router.navigateTo(context,
              '/home/topicDetail?id=${item.id.toString()}&title=${Uri.encodeComponent(item.title)}&image=${Uri.encodeComponent(item.image)}');
        }
        break;
      case "topic_comment":
        var item = await getTopicCommentData(id);

        print("formData ${item} ============================================");
        Navigator.pushNamed(context, Routes.topicCommentDetail,
            arguments: item);
        break;
      case "lead_say":
        var data = await getLeadHeSheSays(id);
        if (data != null) {
          Navigator.of(context).pushNamed(Routes.heSaysDetail, arguments: data);
        }
        break;
      case "he_she_say":
        Navigator.of(context).pushNamed(Routes.heSays);
        break;
      case "user":
        Application.router.navigateTo(
            context, "${Routes.userProfile}?senderId=$id&heroTag=user:$id");
    }
  }

  Future<TopicCommentsModelData> getTopicCommentData(int id) async {
    try {
      Dio dio = ApiClient.dio;
      Response response = await dio
          .get('get_topic_comment/', queryParameters: {"comment_id": id});
      Map<String, dynamic> result = response.data;
      print(result['data']);
      if (result["status"]) {
        return TopicCommentsModelData.fromJson(result["data"]);
      }
    } on DioError catch (e) {
      print(e);
    }
    return null;
  }

  Future<RecruitModelData> getRecruitData(int id) async {
    var data;
    Map<String, dynamic> query = {'recruit_id': id};
    data = await apiClient.getRecruits(query);
    RecruitModel recruits = RecruitModel.fromJson(data);
    if (recruits.status) {
      return recruits.data[0];
    }
    return null;
  }

  Future<HeSheSayItem> getLeadHeSheSays(int id) async {
    try {
      Dio dio = ApiClient.dio;
      Response response =
          await dio.get('get_lead_he_she_say/', queryParameters: {"id": id});
      Map<String, dynamic> result = response.data;

      if (result["status"]) {
        return HeSheSayItem.fromJson(result["data"][0]);
      }
    } on DioError catch (e) {
      print(e);
    }
    return null;
  }

  Future<TopicModelData> getTopic(int id) async {
    try {
      Dio dio = ApiClient.dio;
      Response response =
          await dio.get('get_topics/', queryParameters: {"topic_id": id});
      Map<String, dynamic> result = response.data;
      if (result["status"]) {
        return TopicModelData.fromJson(result["data"][0]);
      }
    } on DioError catch (e) {
      print(e);
    }
    return null;
  }

  String _addZero(int value) => value < 10 ? "0$value" : "$value";
}
