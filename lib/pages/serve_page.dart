import 'package:finder/routers/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:finder/routers/application.dart';

class ServePage extends StatefulWidget {
  @override
  _ServePageState createState() => _ServePageState();
}

class _ServePageState extends State<ServePage> {
  List serviceItemList = [
//    {
//      'name': '失物招领',
//      'preIcon': IconData(0xe62e, fontFamily: 'myIcon'),
//      'backIcon': IconData(0xe63a, fontFamily: 'myIcon'),
//      'color': Colors.yellow,
//      'url': Routes.lostFound
//    },
    {
      'name': '他 · 她说',
      'preIcon': IconData(0xe627, fontFamily: 'myIcon'),
      'backIcon': IconData(0xe63a, fontFamily: 'myIcon'),
      'color': Colors.pink[200],
      'url': Routes.heSays
    },
//    {
//      'name': '一起学习',
//      'preIcon': IconData(0xe668, fontFamily: 'myIcon'),
//      'backIcon': IconData(0xe63a, fontFamily: 'myIcon'),
//      'color': Colors.orange,
//      'url': Routes.study
//    },
//    {
//      'name': '选课指南',
//      'preIcon': IconData(0xe635, fontFamily: 'myIcon'),
//      'backIcon': IconData(0xe63a, fontFamily: 'myIcon'),
//      'color': Colors.cyan,
//      'url': Routes.selectCourse
//    },
//    {
//      'name': '心理测试',
//      'preIcon': IconData(0xe6bd, fontFamily: 'myIcon'),
//      'backIcon': IconData(0xe63a, fontFamily: 'myIcon'),
//      'color': Colors.blue,
//      'url': Routes.psychoTest
//    },
//    {
//      'name': '我·树洞',
//      'preIcon': IconData(0xe60b, fontFamily: 'myIcon'),
//      'backIcon': IconData(0xe63a, fontFamily: 'myIcon'),
//      'color': Colors.green,
//      'url': Routes.treeHole
//    },
    {
      'name': '实习 · 工作',
      'preIcon': IconData(0xe6bd, fontFamily: 'myIcon'),
      'backIcon': IconData(0xe63a, fontFamily: 'myIcon'),
      'color': Colors.blue,
      'url': Routes.internship
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '服务',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      // backgroundColor: Color.fromRGBO(0, 0, 0, 0.03),
      body: Container(
        // color: Colors.white,
        child: ListView.builder(
          itemCount: serviceItemList.length,
          itemBuilder: (context, index) {
            return _getListTile(index);
          },
        ),
      ),
    );
  }

  Widget _getListTile(index) {
    return Material(
      color: Colors.white,
      child: Container(
        height: ScreenUtil().setHeight(110),
        child: ListTile(
          onTap: () {
            Application.router
                .navigateTo(context, serviceItemList[index]['url']);
          },
          title: Text(serviceItemList[index]['name']),
          leading: Icon(
            serviceItemList[index]['preIcon'],
            color: serviceItemList[index]['color'],
          ),
          trailing: Icon(serviceItemList[index]['backIcon']),
        ),
      ),
    );
  }
}
