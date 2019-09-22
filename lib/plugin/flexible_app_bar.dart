import 'package:flutter/material.dart';

class FlexibleAppBar extends StatelessWidget {
  ///content of bar
  ///scroll with the parent scrollView
  final Widget content;

  ///the background of bar
  ///scroll in parallax
  final Widget background;

  final Widget Function(BuildContext context) builder;

  const FlexibleAppBar(
      {Key key,
      @required this.content,
      @required this.background,
      this.builder})
      : assert(content != null, "content cant be null,elyar..."),
        assert(background != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final FlexibleSpaceBarSettings settings =
        context.inheritFromWidgetOfExactType(FlexibleSpaceBarSettings);

    final List<Widget> children = [];
    final double deltaExtent = settings.maxExtent - settings.minExtent;
    final double t =
        (1.0 - (settings.currentExtent - settings.minExtent) / deltaExtent)
            .clamp(0.0, 1.0);

    children.add(Positioned(
      // height: settings.maxExtent,
      top: -Tween<double>(begin: 0.0, end: deltaExtent / 4.0).transform(t),
      // left: 0,
      // right: 0,
      // height: settings.maxExtent,
      child: background,
    ));
    print(settings.currentExtent);

    //为content 添加 底部的 padding

    children.add(
      Positioned(
        left: 0,
        right: 0,
        top: settings.currentExtent - settings.maxExtent,
        child: Opacity(
          opacity: 1 - t,
          child: Material(
            child: content,
            color: Colors.transparent,
            elevation: 0,
          ),
        ),
      ),
    );

    if (builder != null) {
      children.add(Column(
        children: <Widget>[builder(context)],
      ));
    }

    return _FlexibleDetail(
      child: ClipRect(
        child: DefaultTextStyle(
          style: Theme.of(context).primaryTextTheme.body1,
          child: Stack(
            children: children,
            fit: StackFit.expand,
          ),
        ),
      ),
    );
  }
}

class _FlexibleDetail extends InheritedWidget {
  _FlexibleDetail({Key key, this.child}) : super(key: key, child: child);

  final Widget child;

  static _FlexibleDetail of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(_FlexibleDetail)
        as _FlexibleDetail);
  }

  @override
  bool updateShouldNotify(_FlexibleDetail oldWidget) {
    return true;
  }
}
