import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:finder/config/api_client.dart';
import 'package:finder/pages/serve_page/internship_page.dart';
import 'package:finder/public.dart';
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
  bool loading = true;

  @override
  void initState() {
    super.initState();
    getDetail();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        body: Column(
          children: <Widget>[
            CompanyPageHeader(
              company: company,
              companyMainInfo: widget.company,
              loading: loading,
              selected: 0,
            ),
          ],
        ));
  }

  Future<void> getDetail() async {
    String url = 'get_companies/';
    try {
      Dio dio = ApiClient.dio;
      Response response = await dio
          .get(url, queryParameters: {'company_id': widget.company.id});
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
    setState(() {
      loading = false;
    });
  }
}

class CompanyPageHeader extends StatelessWidget {
  CompanyPageHeader(
      {@required this.selected,
      @required this.loading,
      @required this.companyMainInfo,
      @required this.company,
      this.tabs = const ["公司详情", "现有职位"]});

  final CompanyDetail company;
  final CompanyItem companyMainInfo;
  final bool loading;
  final int selected;
  final List<String> tabs;

  @override
  Widget build(BuildContext context) {
    double textTop = 80;
    double textLeft = 60;
    TextStyle unSelectedStyle = TextStyle(
      fontSize: 15,
      color: Color(0xff555555),
    );
    TextStyle selectedStyle = TextStyle(
      fontSize: 15,
      color: Theme.of(context).primaryColor.withOpacity(0.8),
    );
    List<Widget> tabsWidgets = List<Widget>.generate(
        tabs.length,
        (index) => Text(
              tabs[index],
              style: index == selected ? selectedStyle : unSelectedStyle,
            ));
    for (int i = 0; i < tabsWidgets.length - 1; i += 2) {
      tabsWidgets.insert(
          i + 1,
          Padding(
            padding: EdgeInsets.all(20),
          ));
    }
    return Container(
      width: ScreenUtil.screenWidthDp,
      height: 330,
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      child: Stack(
        children: <Widget>[
          Positioned(
            left: 0,
            child: MaterialButton(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              child: Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          Positioned(
            top: textTop,
            left: textLeft,
            child: Row(
              children: <Widget>[
                Container(
                  width: 74,
                  height: 74,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(37)),
                    color: Colors.white,
                  ),
                  child: Hero(
                    tag: "${companyMainInfo.name}-${companyMainInfo.id}",
                    child: CachedNetworkImage(
                      placeholder: (context, url) {
                        return Container(
                          padding: EdgeInsets.all(10),
                          child: CircularProgressIndicator(),
                        );
                      },
                      imageUrl: companyMainInfo.image,
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
                              borderRadius:
                                  BorderRadius.all(Radius.circular(35)),
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
                  padding: EdgeInsets.only(left: 25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        companyMainInfo.name,
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        loading ? "" : company.briefIntroduction,
                        style:
                            TextStyle(color: Color(0xffeeeeee), fontSize: 12),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
              bottom: 0,
              child: Stack(
                children: <Widget>[
                  Container(
                    width: ScreenUtil.screenWidthDp,
                    height: 90,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30)),
                  ),
                  Positioned(
                    bottom: 0,
                    child: Container(
                      width: ScreenUtil.screenWidthDp,
                      height: 60,
                      color: Colors.white,
                      child: Stack(
                        alignment: Alignment.center,
                        children: <Widget>[
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: tabsWidgets,
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ))
        ],
      ),
    );
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
