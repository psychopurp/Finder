// import 'dart:io';

// import 'package:http/http.dart' as http;
// import 'package:html/dom.dart' as dom;
// import 'package:html/parser.dart' show parse;
// import 'package:dio/dio.dart';

// import 'package:movie_pro/model/movie_news.dart';

// class ApiClient {
//   static const apiKey = '0df993c66c0c636e29ecbb5344252a4a';
//   static const baseURL = "http://api.douban.com/v2/movie/";
//   static const webURL = "https://movie.douban.com/";
//   static const searchURL = "https://movie.douban.com/subject_search";
//   //影院热映
//   static const hotMovieURL =
//       'http://api.douban.com/v2/movie/nowplaying?apikey=';

//   var dio = ApiClient.createDio();

//   //获取首页新闻
//   Future getNewsList() async {
//     List<MovieNewsModel> news = [];
//     await http.get(webURL).then((response) {
//       var document = parse(response.body);
//       List<dom.Element> items =
//           document.getElementsByClassName('gallery-frame');
//       items.forEach((item) {
//         String cover = item.getElementsByTagName('img')[0].attributes['src'];
//         String title = item.getElementsByTagName('h3')[0].text.trim();
//         String summary = item.getElementsByTagName('p')[0].text.trim();
//         String link = item.getElementsByTagName('a')[0].attributes['href'];
//         MovieNewsModel tempNews = MovieNewsModel(
//             cover: cover, title: title, summary: summary, link: link);
//         news.add(tempNews);
//       });
//     });
//     return news;
//   }

//   //获取正在热映的电影
//   Future getNowPlayingMovieList({int start, int count}) async {
//     Response response = await dio
//         .get('in_theaters', queryParameters: {'start': start, 'count': count});
//     return response.data;
//   }

//   //获取即将上映的电影
//   Future getComingMovieList({int start, int count}) async {
//     Response response = await dio
//         .get('coming_soon', queryParameters: {'start': start, 'count': count});
//     return response.data;
//   }

//   //获取电影详情
//   Future getMovieDetail(String movieId) async {
//     Response response = await dio.get('subject/$movieId');
//     return response.data;
//   }

//   Future searchMovie(String name) async {
//     var formData = {'search_text': name, 'cat': 1002};
//     await dio.get(searchURL, queryParameters: formData).then((response) {
//       print(response.data);
//     });
//   }

//   //初始化 Dio 对象
//   static Dio createDio() {
//     var options = BaseOptions(
//         baseUrl: baseURL,
//         contentType: ContentType.json,
//         queryParameters: {'apikey': apiKey});
//     return Dio(options);
//   }
// }

// ApiClient apiClient = ApiClient();
