import 'package:flutter/material.dart';

class LostFoundPage extends StatefulWidget {
  @override
  _LostFoundPageState createState() => _LostFoundPageState();
}

class _LostFoundPageState extends State<LostFoundPage>
    with SingleTickerProviderStateMixin {
  TabController _tabController;

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void initState() {
    super.initState();
    _tabController = new TabController(vsync: this, length: 2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 8,
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 15),
            child: Icon(
              IconData(0xe63e, fontFamily: 'myIcon'),
              color: Colors.black,
            ),
          )
        ],
        title: Container(
          margin: EdgeInsets.only(right: 5),
          height: 30,
          // color: Colors.blue,
          // decoration: BoxDecoration(
          //     border: Border.all(width: 1),
          //     borderRadius: BorderRadius.circular(15)),
          child: TextField(
            onChanged: (text) {
              print(text);
            },
            onSubmitted: (text) {
              print(text + '  submit');
            },
            decoration: InputDecoration(
                // suffixIcon: Icon(
                //   Icons.cancel,
                //   color: Colors.black,
                // ),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.black,
                ),
                contentPadding:
                    EdgeInsets.only(top: 10.0, left: 10, right: 10, bottom: -5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                )),
          ),
        ),
        elevation: 1,
        centerTitle: true,
        bottom: new TabBar(
          isScrollable: true,
          labelColor: Color(0xff333333),
          tabs: <Widget>[
            new Tab(
              child: Text('     寻物      '),
            ),
            new Tab(
              child: Text('     招领      '),
            ),
          ],
          controller: _tabController,
        ),
      ),
      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.95),
      body: new TabBarView(
        controller: _tabController,
        children: <Widget>[
          new Center(child: new Text('自行车')),
          new Center(child: new Text('船')),
          // new Center(child: new Text('巴士')),
        ],
      ),
    );
  }
}
