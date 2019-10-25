import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:finder/config/api_client.dart';
import 'package:finder/pages/serve_page/internship_page.dart';
import 'package:flutter/material.dart';

class CompanyRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    InternshipItem item = ModalRoute.of(context).settings.arguments;
    return CompanyPage(item);
  }
}

class CompanyPage extends StatefulWidget {
  CompanyPage(this.item) : company = item.company;

  final CompanyItem company;
  final InternshipItem item;

  @override
  _CompanyPageState createState() => _CompanyPageState();
}

class _CompanyPageState extends State<CompanyPage> {

  CompanyDetail company;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        brightness: Brightness.dark,
        elevation: 0,
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(20),
          ),
          Row(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(30),
              ),
              Container(
                width: 74,
                height: 74,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(37)),
                  color: Colors.white,
                ),
                child: Hero(
                  tag: "${widget.company.name}-${widget.item.id}",
                  child: CachedNetworkImage(
                    placeholder: (context, url) {
                      return Container(
                        padding: EdgeInsets.all(10),
                        child: CircularProgressIndicator(),
                      );
                    },
                    imageUrl: widget.company.image,
                    errorWidget: (context, url, err) {
                      return Container(
                        child: Icon(
                          Icons.cancel,
                          size: 70,
                          color: Colors.grey,
                        ),
                      );
                    },
                    imageBuilder: (context, imageProvider) {
                      return Padding(
                        padding: EdgeInsets.all(2),
                        child: Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(35)),
                            image: DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 20),
                child: Text(
                  widget.company.name,
                  style: TextStyle(
                    fontSize: 17,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> getDetail() async {
    String url = 'get_companies/';
    try {
      Dio dio = ApiClient.dio;
      Response response = await dio.get(url, queryParameters: {'company_id': widget.company.id});
      Map<String, dynamic> result = response.data;
      if (result["status"]) {
        setState(() {
          company = CompanyDetail.fromJson(result['data'][0]);
        });
      }
    } on DioError catch (e) {
      print(e);
      print(url);
    }
  }
}

class CompanyDetail {
  CompanyDetail(
      {this.id,
      this.name,
      this.briefIntroduction,
      this.tags,
      this.address,
      this.introduction,
      this.size,
      this.types,
      this.website,
      this.city,
      this.province});

  factory CompanyDetail.fromJson(Map<String, dynamic> map) {
    return CompanyDetail(
      id: map['id'],
      name: map['name'],
      briefIntroduction: map['brief_introduction'],
      introduction: map['introduction'],
      city: map['city']['name'],
      province: map['city']['province'],
      address: map['address'],
      website: map['website'],
      size: map['size'],
    );
  }

  final int id;
  final String name;
  final String briefIntroduction;
  final String introduction;
  final String city;
  final String province;
  final String address;
  final String website;
  final String size;
  final List<InternshipBigType> types;
  final List<InternshipTag> tags;
}
