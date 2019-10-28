import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:finder/config/api_client.dart';
import 'package:finder/models/message_model.dart';
import 'package:finder/models/recruit_model.dart';
import 'package:finder/routers/application.dart';
import 'package:finder/routers/routes.dart';
import 'package:flutter/material.dart';

import '../../public.dart';

class CandidatesRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    RecruitModelData item = ModalRoute.of(context).settings.arguments;
    return CandidatesPage(item);
  }
}

class CandidatesPage extends StatefulWidget {
  CandidatesPage(this.item);

  final RecruitModelData item;

  @override
  _CandidatesPageState createState() => _CandidatesPageState();
}

class _CandidatesPageState extends State<CandidatesPage> {
  List<CandidateItem> data = [];

  @override
  void initState() {
    super.initState();
    getCandidates();
  }

  Future<void> getCandidates() async {
    String url = 'get_candidates/';
    try {
      Dio dio = ApiClient.dio;
      Response response =
          await dio.get(url, queryParameters: {"recruit_id": widget.item.id});
      Map<String, dynamic> result = response.data;
      if (result["status"]) {
        setState(() {
          data = List<CandidateItem>.generate(result["data"].length,
              (index) => CandidateItem.fromJson(result["data"][index]));
        });
      }
    } on DioError catch (e) {
      print(e);
      print(url);
      setState(() {
        data = [];
      });
    }
  }

  Future<void> postData(CandidateItem item, bool isPass) async {
    String url = 'set_recruit_result/';
    try {
      Dio dio = ApiClient.dio;
      Response response = await dio.post(url,
          data: json.encode({"candidate_id": item.id, "is_pass": isPass}));
      Map<String, dynamic> result = response.data;
      if (result["status"]) {
        setState(() {
          item.status = isPass ? CandidateItem.accept : CandidateItem.reject;
        });
      }
    } on DioError catch (e) {
      print(e);
      print(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    var appBarColor = Color.fromARGB(255, 95, 95, 95);
    var appBarIconColor = Color.fromARGB(255, 155, 155, 155);
    return Scaffold(
      appBar: AppBar(
        leading: MaterialButton(
          child: Icon(
            Icons.arrow_back_ios,
            color: appBarIconColor,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        brightness: Brightness.light,
        backgroundColor: Colors.white,
        title: Text(
          "应聘者",
          style: TextStyle(color: appBarColor, fontSize: 20),
        ),
      ),
      body: ListView.builder(
        itemBuilder: (context, index) {
          CandidateItem item = data[index];
          Widget status;
          if (item.status != CandidateItem.waiting) {
            status = Container(
              padding: EdgeInsets.only(left: 20),
              child: Text(
                "状态: ${item.status == CandidateItem.accept ? "接受" : "拒绝"}",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            );
          } else {
            if (MessageModel().self.id == widget.item.sender.id) {
              status = Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  MaterialButton(
                    child: Text(
                      "接受",
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                    onPressed: () {
                      postData(item, true);
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.all(10),
                  ),
                  MaterialButton(
                    child: Text("拒绝"),
                    onPressed: () {
                      postData(item, false);
                    },
                  ),
                ],
              );
            } else {
              status = Container(
                padding: EdgeInsets.only(left: 20),
                child: Text(
                  "状态: 等待",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              );
            }
          }
          return Container(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(5),
                    ),
                    MaterialButton(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onPressed: () async {
                        Application.router.navigateTo(context,
                            "${Routes.userProfile}?senderId=${item.user.id}&heroTag=user:${item.user.id}-${item.id}");
                      },
                      padding: EdgeInsets.all(0),
                      child: Row(
                        children: <Widget>[
                          Container(
                            width: 50,
                            height: 50,
                            child: Hero(
                              tag: "user:${item.user.id}-${item.id}",
                              child: CachedNetworkImage(
                                placeholder: (context, url) {
                                  return Container(
                                    padding: EdgeInsets.all(10),
                                    child: CircularProgressIndicator(),
                                  );
                                },
                                imageUrl: item.user.avatar,
                                errorWidget: (context, url, err) {
                                  return Container(
                                    child: Icon(
                                      Icons.cancel,
                                      size: 50,
                                      color: Colors.grey,
                                    ),
                                  );
                                },
                                imageBuilder: (context, imageProvider) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(25)),
                                      image: DecorationImage(
                                        image: imageProvider,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 20),
                            child: Text(
                              item.user.nickname,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 17,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(),
                    ),
                    Padding(
                      padding: EdgeInsets.only(right: 10),
                      child: Text(
                        getTimeString(item.time),
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                  width: ScreenUtil.screenWidthDp,
                  height: 1,
                  color: Color(0xffeeeeee),
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  child: Text(item.information),
                ),
                status,
                Container(
                  margin: EdgeInsets.symmetric(vertical: 30, horizontal: 15),
                  width: ScreenUtil.screenWidthDp,
                  height: 1,
                  color: Color(0xffeeeeee),
                ),
              ],
            ),
          );
        },
        itemCount: data?.length ?? 0,
      ),
    );
  }
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
    return "今天";
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
