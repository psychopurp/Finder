import 'package:finder/config/api_client.dart';
import 'package:finder/models/collections_model.dart';
import 'package:finder/provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CollectionPage extends StatefulWidget {
  @override
  _CollectionPageState createState() => _CollectionPageState();
}

class _CollectionPageState extends State<CollectionPage> {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context);
    // print(ApiClient.dio.options.headers['token']);
    getCollectionsData();
    return Scaffold(
      appBar: AppBar(),
      // body: ,
    );
  }

  Future getCollectionsData() async {
    var data = await apiClient.getCollections();
    CollectionsModel collectionsModel = CollectionsModel.fromJson(data);
    print(collectionsModel);
  }
}
