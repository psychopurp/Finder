import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:clipboard_manager/clipboard_manager.dart';

class BetterText extends StatefulWidget {
  BetterText(
    this.text, {
    Key key,
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
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      child: Text.rich(
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
                            if (await canLaunch(texts[index].text)) {
                              launch(texts[index].text);
                            }
                          }))),
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
      ),
      onLongPress: () {
        ClipboardManager.copyToClipBoard(widget.text).then((result) {
          if (result) {
            BotToast.showText(text: "复制文本成功了哟~", align: Alignment(0, 0.8));
          } else {
            BotToast.showText(
                text: "复制失败, 请检查权限再试试吧~", align: Alignment(0, 0.8));
          }
        });
      },
    );
  }
}

class _TextItem {
  _TextItem(this.text, this.type);

  final String text;
  final bool type;
}
