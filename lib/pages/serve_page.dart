import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:finder/routers/application.dart';

class ServePage extends StatefulWidget {
  @override
  _ServePageState createState() => _ServePageState();
}

class _ServePageState extends State<ServePage> {
  List serviceItemList = [
    {
      'name': '失物招领',
      'preIcon': IconData(0xe62e, fontFamily: 'myIcon'),
      'backIcon': IconData(0xe63a, fontFamily: 'myIcon'),
      'color': Colors.yellow,
    },
    {
      'name': '他·她·说',
      'preIcon': IconData(0xe627, fontFamily: 'myIcon'),
      'backIcon': IconData(0xe63a, fontFamily: 'myIcon'),
      'color': Colors.pink[200],
    },
    {
      'name': '一起学习',
      'preIcon': IconData(0xe668, fontFamily: 'myIcon'),
      'backIcon': IconData(0xe63a, fontFamily: 'myIcon'),
      'color': Colors.orange,
    },
    {
      'name': '选课指南',
      'preIcon': IconData(0xe635, fontFamily: 'myIcon'),
      'backIcon': IconData(0xe63a, fontFamily: 'myIcon'),
      'color': Colors.cyan,
    },
    {
      'name': '心理测试',
      'preIcon': IconData(0xe6bd, fontFamily: 'myIcon'),
      'backIcon': IconData(0xe63a, fontFamily: 'myIcon'),
      'color': Colors.blue,
    },
    {
      'name': '我·树洞',
      'preIcon': IconData(0xe60b, fontFamily: 'myIcon'),
      'backIcon': IconData(0xe63a, fontFamily: 'myIcon'),
      'color': Colors.green,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('服务'),
        elevation: 0,
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
            var name = serviceItemList[index]['name'];
            switch (name) {
              case '失物招领':
                Application.router.navigateTo(context, '/serve/lostFound');
                break;
              case '他·她·说':
                Application.router.navigateTo(context, '/serve/heSays');
                break;
              case '一起学习':
                Application.router.navigateTo(context, '/serve/study');
                break;
              case '选课指南':
                Application.router.navigateTo(context, '/serve/selectCourse');
                break;
              case '心理测试':
                Application.router.navigateTo(context, '/serve/psychoTest');
                break;
              case '我·树洞':
                Application.router.navigateTo(context, '/serve/treeHole');
                break;
              default:
                print('done');
            }
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

  void onTapHandler(index) {
    var name = serviceItemList[index]['name'];
    switch (name) {
      case '失物招领':
        Application.router.navigateTo(context, '/serve/lostFound');
        break;
      case '他·她·说':
        Application.router.navigateTo(context, '/serve/heSays');
        break;
      case '一起学习':
        Application.router.navigateTo(context, '/serve/study');
        break;
      case '选课指南':
        Application.router.navigateTo(context, '/serve/selectCourse');
        break;
      case '心理测试':
        Application.router.navigateTo(context, '/serve/psychoTest');
        break;
      case '我·树洞':
        Application.router.navigateTo(context, '/serve/treeHole');
        break;
      default:
        print('done');
    }
  }
}
