import 'package:flutter/material.dart';

///用来更改页面主题
class AccentColorOverride extends StatelessWidget {
  const AccentColorOverride({this.color, this.child});

  final Color color;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(accentColor: color),
      child: child,
    );
  }
}
