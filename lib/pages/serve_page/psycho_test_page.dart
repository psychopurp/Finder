import 'package:flutter/material.dart';

class PsychoTestPage extends StatefulWidget {
  @override
  _PsychoTestPageState createState() => _PsychoTestPageState();
}

class _PsychoTestPageState extends State<PsychoTestPage> {
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
