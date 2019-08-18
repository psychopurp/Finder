import 'package:flutter/material.dart';
import 'package:finder/routers/application.dart';

class HeSaysPage extends StatefulWidget {
  @override
  _HeSaysPageState createState() => _HeSaysPageState();
}

class _HeSaysPageState extends State<HeSaysPage> {
  var _time;
  @override
  void initState() {
    DateTime time = new DateTime.now();
    _time = time.year.toString() +
        '—' +
        time.month.toString() +
        '—' +
        time.day.toString() +
        '▼';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: <Widget>[
            MaterialButton(
              highlightColor: Colors.white,
              splashColor: Colors.white,
              child: Icon(
                IconData(0xe609, fontFamily: 'myIcon'),
                color: Colors.black,
              ),
              onPressed: () {
                Application.router
                    .navigateTo(context, '/serve/heSays/heSaysPublish');
              },
            ),
          ],
          title: MaterialButton(
              highlightColor: Colors.white,
              splashColor: Colors.white,
              child: Text(_time),
              onPressed: () {
                showDatePicker(
                        locale: Locale('zh'),
                        context: context,
                        initialDate: new DateTime.now(),
                        firstDate: new DateTime.now()
                            .subtract(new Duration(days: 30)), // 减 30 天
                        lastDate: new DateTime.now())
                    .then((time) {
                  setState(() {
                    _time = time.year.toString() +
                        '—' +
                        time.month.toString() +
                        '—' +
                        time.day.toString() +
                        '▼';
                  });
                });
              }),
          elevation: 0,
          centerTitle: true,
        ),
        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.95),
        body: Center(
          child: Text('home page'),
        ));
  }
}
