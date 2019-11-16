import 'package:flutter/material.dart';
import 'package:finder/plugin/better_text.dart';

class TreeHolePage extends StatefulWidget {
  @override
  _TreeHolePageState createState() => _TreeHolePageState();
}

class _TreeHolePageState extends State<TreeHolePage> {
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
