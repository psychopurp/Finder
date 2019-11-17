import 'package:bot_toast/bot_toast.dart';
import 'package:finder/routers/application.dart';
import 'package:finder/routers/routes.dart';
import 'package:flutter/rendering.dart';
import 'package:extended_text/extended_text.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class BetterText extends StatefulWidget {
  BetterText(
    this.text, {
    Key key,
    this.onTap,
    this.enableSelection = false,
    this.urlStyle,
    this.style,
    this.strutStyle,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.overflow,
    this.textScaleFactor,
    this.maxLines,
    this.semanticsLabel,
    this.textWidthBasis,
  }) : super(key: key);
  final TextStyle style;
  final StrutStyle strutStyle;
  final TextAlign textAlign;
  final TextDirection textDirection;
  final Locale locale;
  final bool softWrap;
  final TextOverflow overflow;
  final double textScaleFactor;
  final int maxLines;
  final String semanticsLabel;
  final TextWidthBasis textWidthBasis;
  final TextStyle urlStyle;
  final String text;
  final VoidCallback onTap;
  final bool enableSelection;

  @override
  _BetterTextState createState() => _BetterTextState();
}

class _BetterTextState extends State<BetterText> {
  static final RegExp urlReg =
      RegExp(r"https?://[-A-Za-z0-9+&@#/%?=~_|!:,.;]+[-A-Za-z0-9+&@#/%=~_|]");
  List<_TextItem> texts = [];

  @override
  void initState() {
    super.initState();
    splitText(widget.text);
  }

  void splitText(String text) {
    if (text.length == 1) {
      texts.add(_TextItem(text, false));
      return;
    }
    var matches = urlReg.allMatches(text);
    int start = 0;
    for (var match in matches) {
      int matchStart = match.start;
      texts.add(_TextItem(text.substring(start, matchStart), false));
      texts.add(_TextItem(match.group(0), true));
      start = match.end;
    }
    if (start != text.length - 1)
      texts.add(_TextItem(text.substring(start), false));
  }

  @override
  Widget build(BuildContext context) {
    return ExtendedText.rich(
      TextSpan(
          children: List<InlineSpan>.generate(
              texts.length,
              (index) => !texts[index].type
                  ? TextSpan(text: texts[index].text)
                  : TextSpan(
                      text: texts[index].text,
                      style: widget.urlStyle ??
                          const TextStyle(color: Colors.blue),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () async {
                          String url = texts[index].text;
                          url = Uri.encodeComponent(url);
                          Application.router.navigateTo(
                              context, "${Routes.webViewPage}?url=$url");
//                          if (await canLaunch(texts[index].text)) {
//                            launch(texts[index].text);
//                          }
                        }))),
      onTap: widget.onTap,
      textSelectionControls: MyExtendedMaterialTextSelectionControls(),
      selectionEnabled: widget.enableSelection,
      style: widget.style,
      textAlign: widget.textAlign,
      maxLines: widget.maxLines,
      overflow: widget.overflow,
      semanticsLabel: widget.semanticsLabel,
      locale: widget.locale,
      softWrap: widget.softWrap,
      strutStyle: widget.strutStyle,
      textDirection: widget.textDirection,
      textScaleFactor: widget.textScaleFactor,
      textWidthBasis: widget.textWidthBasis,
    );
  }

  @override
  void didUpdateWidget(BetterText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      texts = [];
      splitText(widget.text);
    }
  }
}

class _TextItem {
  _TextItem(this.text, this.type);

  final String text;
  final bool type;
}

const double _kToolbarScreenPadding = 8.0;
const double _kToolbarHeight = 44.0;

class MyExtendedMaterialTextSelectionControls
    extends MaterialExtendedTextSelectionControls {
  MyExtendedMaterialTextSelectionControls();

  @override
  Widget buildToolbar(
    BuildContext context,
    Rect globalEditableRegion,
    double textLineHeight,
    Offset position,
    List<TextSelectionPoint> endpoints,
    TextSelectionDelegate delegate,
  ) {
    assert(debugCheckHasMediaQuery(context));
    assert(debugCheckHasMaterialLocalizations(context));

    final TextSelectionPoint startTextSelectionPoint = endpoints[0];
    final TextSelectionPoint endTextSelectionPoint =
        (endpoints.length > 1) ? endpoints[1] : null;
    final double x = (endTextSelectionPoint == null)
        ? startTextSelectionPoint.point.dx
        : (startTextSelectionPoint.point.dx + endTextSelectionPoint.point.dx) /
            2.0;
    final double availableHeight = globalEditableRegion.top -
        MediaQuery.of(context).padding.top -
        _kToolbarScreenPadding;
    final double y = (availableHeight < _kToolbarHeight)
        ? startTextSelectionPoint.point.dy +
            globalEditableRegion.height +
            _kToolbarHeight +
            _kToolbarScreenPadding
        : startTextSelectionPoint.point.dy - textLineHeight * 2.0;
    final Offset preciseMidpoint = Offset(x, y);

    return ConstrainedBox(
      constraints: BoxConstraints.tight(globalEditableRegion.size),
      child: CustomSingleChildLayout(
        delegate: MaterialExtendedTextSelectionToolbarLayout(
          MediaQuery.of(context).size,
          globalEditableRegion,
          preciseMidpoint,
        ),
        child: _TextSelectionToolbar(
          handleCut: canCut(delegate) ? () => handleCut(delegate) : null,
          handleCopy: canCopy(delegate)
              ? () => (delegate) {
                    handleCopy(delegate);
                    BotToast.showText(text: "复制成功", align: Alignment(0, 0.8));
                  }(delegate)
              : null,
          handlePaste: canPaste(delegate) ? () => handlePaste(delegate) : null,
          handleSelectAll:
              canSelectAll(delegate) ? () => handleSelectAll(delegate) : null,
        ),
      ),
    );
  }
}

/// Manages a copy/paste text selection toolbar.
class _TextSelectionToolbar extends StatelessWidget {
  const _TextSelectionToolbar({
    Key key,
    this.handleCopy,
    this.handleSelectAll,
    this.handleCut,
    this.handlePaste,
  }) : super(key: key);

  final VoidCallback handleCut;
  final VoidCallback handleCopy;
  final VoidCallback handlePaste;
  final VoidCallback handleSelectAll;

  @override
  Widget build(BuildContext context) {
    final List<Widget> items = <Widget>[];

    if (handleCut != null) items.add(createButton("剪切", handleCut));
    if (handleCopy != null) items.add(createButton("复制", handleCopy));
    if (handlePaste != null) items.add(createButton("粘贴", handlePaste));
    if (handleSelectAll != null) items.add(createButton("全选", handleSelectAll));
    // If there is no option available, build an empty widget.
    if (items.isEmpty) {
      return Container(width: 0.0, height: 0.0);
    }

    return Material(
      elevation: 1.0,
      child: Wrap(children: items),
      borderRadius: BorderRadius.all(Radius.circular(10.0)),
    );
  }

  Widget createButton(String text, VoidCallback onTrigger) {
    return Container(
      child: FlatButton(
        child: Text(text),
        onPressed: onTrigger,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
    );
  }
}
