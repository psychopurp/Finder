import 'package:dio/dio.dart';
import 'package:finder/config/api_client.dart';
import 'package:flutter/material.dart';

class InternshipPage extends StatefulWidget {
  @override
  _InternshipPageState createState() => _InternshipPageState();
}

class _InternshipPageState extends State<InternshipPage> {
  List<InternshipItem> bannerData = [];

  @override
  Widget build(BuildContext context) {
    var appBarColor = Color.fromARGB(255, 95, 95, 95);
    var appBarIconColor = Color.fromARGB(255, 155, 155, 155);
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.light,
        backgroundColor: Colors.white,
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
        title: Text(
          "招募 · 实习",
          style: TextStyle(
            color: appBarColor,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Text("State"),
    );
  }

  Future<void> getLeadHeSheSays({bool delay: false}) async {
    if (delay) {
      await Future.delayed(Duration(milliseconds: 100));
    }
    try {
      Dio dio = ApiClient.dio;
      Response response = await dio.get('get_lead_he_she_say/');
      Map<String, dynamic> result = response.data;
      if (result["status"]) {
        setState(() {
          bannerData = List.generate(result["data"].length,
              (index) => InternshipItem.fromJson(result["data"][index]));
        });
      }
    } on DioError catch (e) {
      print(e);
      setState(() {
        bannerData = [];
      });
    }
  }
}

class InternshipItem {
  factory InternshipItem.fromJson(Map<String, dynamic> map) {
    return null;
  }
}
