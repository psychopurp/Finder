import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'home_page.dart';
import 'mine_page.dart';
import 'serve_page.dart';
import 'find_page.dart';

class IndexPage extends StatefulWidget {
  @override
  _IndexPageState createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
  int _selectIndex = 0;
  var pages = [HomePage(), FindPage(), ServePage(), MinePage()];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      primary: false,
      floatingActionButton: FloatingActionButton(
        mini: true,
        focusColor: Colors.blue,
        backgroundColor: Colors.white,
        onPressed: () {},
        child: Icon(
          Icons.add,
          color: Colors.black,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: pages[_selectIndex],
      bottomNavigationBar: BottomAppBar(
        // color: Colors.blue,
        notchMargin: 1,
        shape: CircularNotchedRectangle(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            IconButton(
              icon: Icon(
                IconData(0xe688, fontFamily: 'myIcon'),
                color: _selectIndex == 0 ? Colors.yellow : Colors.black,
              ),
              color: Colors.black,
              onPressed: () {
                setState(() {
                  _selectIndex = 0;
                });
              },
            ),
            IconButton(
              padding: const EdgeInsets.fromLTRB(8.0, 8.0, 80.0, 8.0),
              icon: Icon(
                IconData(0xe631, fontFamily: 'myIcon'),
                color: _selectIndex == 1 ? Colors.yellow : Colors.black,
              ),
              color: Colors.black,
              onPressed: () {
                setState(() {
                  _selectIndex = 1;
                });
              },
            ),
            IconButton(
              icon: Icon(
                IconData(0xe6b8, fontFamily: 'myIcon'),
                color: _selectIndex == 2 ? Colors.yellow : Colors.black,
              ),
              color: Colors.black,
              onPressed: () {
                setState(() {
                  _selectIndex = 2;
                });
              },
            ),
            IconButton(
              icon: Icon(
                IconData(0xe66d, fontFamily: 'myIcon'),
                color: _selectIndex == 3 ? Colors.yellow : Colors.black,
              ),
              color: Colors.black,
              onPressed: () {
                setState(() {
                  _selectIndex = 3;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
