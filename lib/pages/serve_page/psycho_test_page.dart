import 'package:flutter/material.dart';
import 'package:finder/plugin/better_text.dart';

class PsychoTestPage extends StatefulWidget {
  @override
  _PsychoTestPageState createState() => _PsychoTestPageState();
}

class _PsychoTestPageState extends State<PsychoTestPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: BetterText('Finders'),
          elevation: 0,
          centerTitle: true,
        ),
        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.95),
        body: Center(
          child: BetterText('home page'),
        ));
  }
}
