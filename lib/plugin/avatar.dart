import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:finder/config/api_client.dart';
import 'package:finder/config/global.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Avatar extends StatelessWidget {
  Avatar({@required this.url, this.avatarHeight = 50, this.iconSize = 30});

  final String url;
  final double avatarHeight;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      placeholder: (context, url) {
        return Container(
          width: avatarHeight,
          height: avatarHeight,
          alignment: Alignment.center,
          child: CupertinoActivityIndicator(),
        );
      },
      imageUrl: url,
      errorWidget: (context, url, err) {
        return Container(
          width: avatarHeight,
          height: avatarHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(avatarHeight / 2),
            color: Colors.grey,
          ),
          child: Icon(
            Icons.cancel,
            color: Colors.white,
            size: iconSize,
          ),
        );
      },
      imageBuilder: (context, imageProvider) {
        return Container(
          width: avatarHeight,
          height: avatarHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(avatarHeight / 2)),
            image: DecorationImage(
              image: imageProvider,
              fit: BoxFit.cover,
            ),
          ),
        );
      },
    );
  }

  static String getImageUrl(String url) {
<<<<<<< HEAD
//    String baseUrl = ApiClient.host;
//    if (url == null) {
//      return baseUrl + "/static/default.png";
=======
    String baseUrl = ApiClient.host;
    if(url == null){
      return "/static/default.png";
    }
    if (url.startsWith("http")) {
      return url;
    } else
      return baseUrl + url;
//    String baseUrl = "https://image.finder-nk.com";    if(url == null){
//      return "/static/default.jpg";
>>>>>>> 4efe1a026c4d865a17b84a25174fd0a58a8c054d
//    }
//    if (url.startsWith("http")) {
//      return url;
//    } else
//      return baseUrl + url;
      String baseUrl = "https://image.finder-nk.com";
      if (url == null) {
        return baseUrl + "/static/default.png";
      }
      if (url.startsWith("http")) {
        return url;
      } else if (url.startsWith("/media")) {
        return baseUrl + url.substring(6);
      } else {
        return baseUrl + url;
      }
  }
}
