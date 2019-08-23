import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:finder/provider/test.dart';

class MinePage extends StatefulWidget {
  @override
  _MinePageState createState() => _MinePageState();
}

class _MinePageState extends State<MinePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('招募'),
          elevation: 0,
          centerTitle: true,
        ),
        backgroundColor: Color.fromRGBO(0, 0, 0, 0.03),
        body: Consumer<Counter>(
          builder: (context, counter, child) {
            return ListView(
              children: <Widget>[
                Text(counter.count.toString()),
                RaisedButton(
                  onPressed: counter.increment,
                )
              ],
            );
          },
        ));
  }
}
