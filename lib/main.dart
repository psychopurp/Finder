import 'package:flutter/material.dart';
import 'pages/index_page.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
// import 'package:provide/provide.dart';
// import 'public.dart';
import 'routers/application.dart';
import 'package:fluro/fluro.dart';
import 'routers/routes.dart';
// import 'package:movie_pro/provide/movie_provide.dart';
// import 'dart:io';
// import 'package:flutter/services.dart';

void main() {
  // final providers = Providers();
  // var movieProvide = MovieProvide();

  // providers..provide(Provider<MovieProvide>.value(movieProvide));

  // runApp(ProviderNode(child: MyApp(), providers: providers));

  // if (Platform.isAndroid) {
  //   // 以下两行 设置android状态栏为透明的沉浸。写在组件渲染之后，是为了在渲染后进行set赋值，覆盖状态栏，写在渲染之前MaterialApp组件会覆盖掉这个值。
  //   SystemUiOverlayStyle systemUiOverlayStyle =
  //       SystemUiOverlayStyle(statusBarColor: Colors.transparent);
  //   SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  // }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp() {
    final router = Router();
    Routes.configureRoutes(router);
    Application.router = router;
  }

  @override
  Widget build(BuildContext context) {
    // Provide.value<MovieProvide>(context).getAllData();
    return MaterialApp(
      localizationsDelegates: [
        //此处
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        //此处
        const Locale('zh', 'CH'),
        const Locale('en', 'US'),
      ],
      onGenerateRoute: Application.router.generator,
      theme: ThemeData(primaryColor: Colors.white),
      title: 'Finder',
      debugShowCheckedModeBanner: false,
      home: IndexPage(),
    );
  }
}
