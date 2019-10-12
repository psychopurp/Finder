import 'dart:io';

import 'package:finder/public.dart';
import 'package:flutter/material.dart';
import 'package:zefyr/zefyr.dart';
import 'package:quill_delta/quill_delta.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  @override
  Widget build(BuildContext context) {
    return EditorPage();
  }
}

class EditorPage extends StatefulWidget {
  @override
  EditorPageState createState() => EditorPageState();
}

class EditorPageState extends State<EditorPage> {
  /// Allows to control the editor and the document.
  ZefyrController _controller;

  /// Zefyr editor like any other input field requires a focus node.
  FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    // Here we must load the document and pass it to Zefyr controller.
    final document = _loadDocument();
    _controller = ZefyrController(document);
    _focusNode = FocusNode();
  }

  @override
  Widget build(BuildContext context) {
    final editor = new ZefyrEditor(
      focusNode: _focusNode,
      controller: _controller,
      imageDelegate: MyAppZefyrImageDelegate(),
      toolbarDelegate: MyAppZefyrToolBarDelegate(),
    );

    // ... do more with this page's layout
    return ZefyrScaffold(
        child: Container(
      // ... customize
      child: editor,
    ));
  }

  /// Loads the document to be edited in Zefyr.
  NotusDocument _loadDocument() {
    // For simplicity we hardcode a simple document with one line of text
    // saying "Zefyr Quick Start".
    // (Note that delta must always end with newline.)
    final Delta delta = Delta()..insert("Zefyr Quick Start\n");
    return NotusDocument.fromDelta(delta);
  }
}

class MyAppZefyrImageDelegate implements ZefyrImageDelegate<ImageSource> {
  @override
  Future<String> pickImage(ImageSource source) async {
    final file = await ImagePicker.pickImage(source: source);
    if (file == null) return null;
    // We simply return the absolute path to selected file.
    return file.uri.toString();
  }

  @override
  Widget buildImage(BuildContext context, String key) {
    final file = File.fromUri(Uri.parse(key));

    /// Create standard [FileImage] provider. If [key] was an HTTP link
    /// we could use [NetworkImage] instead.
    final image = FileImage(file);
    return Container(
      height: ScreenUtil().setHeight(200),
      width: ScreenUtil().setWidth(200),
      decoration:
          BoxDecoration(image: DecorationImage(image: image, fit: BoxFit.fill)),
    );
  }

  @override
  ImageSource get cameraSource => ImageSource.camera;

  @override
  ImageSource get gallerySource => ImageSource.gallery;
}

class MyAppZefyrToolBarDelegate implements ZefyrToolbarDelegate {
  @override
  Widget buildButton(BuildContext context, ZefyrToolbarAction action,
      {onPressed}) {
    print(action);
    // switch () {
    //   case :

    //     break;
    //   default:
    // }
    return ButtonBar(
      children: <Widget>[
        IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              print(action.index);
            }),
      ],
    );
  }
}
