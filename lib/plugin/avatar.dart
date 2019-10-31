
import 'package:cached_network_image/cached_network_image.dart';
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
//    String baseUrl = ApiClient.host;
//    if(url == null){
//      return "/static/default.png";
//    }
//    if (url.startsWith("http")) {
//      return url;
//    } else
//      return baseUrl + url;
    String baseUrl = "https://image.finder-nk.com";
    String target;
    if (url == null) {
      return baseUrl + "/static/default.png?x-oss-process=style/50zip";
    }
    if (url.startsWith("http")) {
      target = url;
      if(!target.startsWith(baseUrl)) {
        return target;
      }
    } else if (url.startsWith("/media")) {
      target = baseUrl + url.substring(6);
    } else {
      target = baseUrl + url;
    }
    if(!target.endsWith("gif") && !target.endsWith("50zip")) {
      target = target + "?x-oss-process=style/50zip";
    }
    return target;
  }
}
