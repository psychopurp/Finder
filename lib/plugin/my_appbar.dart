import 'package:finder/public.dart';
import 'package:flutter/material.dart';

class MyAppBar extends StatelessWidget {
  final Widget child;
  final PreferredSizeWidget appbar;
  MyAppBar({this.child, this.appbar});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        this.child,
        Positioned(left: 0, right: 0, child: this.appbar),
      ],
    );
  }
}
