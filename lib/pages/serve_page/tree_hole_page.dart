import 'package:flutter/material.dart';

class TreeHolePage extends StatefulWidget {
  @override
  _TreeHolePageState createState() => _TreeHolePageState();
}

class _TreeHolePageState extends State<TreeHolePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Finders'),
          elevation: 0,
          centerTitle: true,
        ),
        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.95),
        body: Center(
          child: Text('home page'),
        ));
  }
}
