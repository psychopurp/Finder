import 'package:finder/pages/serve_page/internship_page.dart';
import 'package:flutter/material.dart';

class CompanyRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    CompanyItem company = ModalRoute.of(context).settings.arguments;
    return CompanyPage(company);
  }
}

class CompanyPage extends StatefulWidget {
  CompanyPage(this.company);

  final CompanyItem company;

  @override
  _CompanyPageState createState() => _CompanyPageState();
}

class _CompanyPageState extends State<CompanyPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.dark,
      ),
    );
  }
}
