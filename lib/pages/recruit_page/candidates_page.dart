import 'package:dio/dio.dart';
import 'package:finder/config/api_client.dart';
import 'package:finder/models/recruit_model.dart';
import 'package:flutter/material.dart';

class CandidatesRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    int id = ModalRoute.of(context).settings.arguments;
    return CandidatesPage(id);
  }
}

class CandidatesPage extends StatefulWidget {
  CandidatesPage(this.id);

  final int id;

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
      Response response = await dio.get(url, queryParameters: {"recruit_id": widget.id});
      Map<String, dynamic> result = response.data;
      print(response.request.queryParameters);
      print(result);
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
          return Container(
            child: Text(item.user.nickname),
          );
        },
        itemCount: data?.length ?? 0,
      ),
    );
  }
}
