import 'package:flutter/material.dart';

class StudyPage extends StatefulWidget {
  @override
  _StudyPageState createState() => _StudyPageState();
}

class _StudyPageState extends State<StudyPage> {
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
