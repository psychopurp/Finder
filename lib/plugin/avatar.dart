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

  static String baseUrl = "https://image.finder-nk.com";
  static String style;

  static addPost() {
    if (style == null) {
      int memory = Global.totalMemory;
      if (memory == null) {
        style = "?x-oss-process=style/50zip";
      } else {
        if (memory < 3072) {
          baseUrl = "http://nogif.finder-nk.com";
          style = "?x-oss-process=style/30zip";
        } else if (memory < 5120) {
          style = "?x-oss-process=style/30zip";
        } else {
          style = "?x-oss-process=style/50zip";
        }
      }
    }
  }

  static String getImageUrl(String url) {
    // String baseUrl = ApiClient.host;
    // if (url == null) {
    //   return "/static/default.png";
    // }
    // if (url.startsWith("http")) {
    //   return url;
    // } else
    //   return baseUrl + url;
    addPost();
    String target;
    if (url == null) {
      return baseUrl + "/static/default.png" + style;
    }
    if (url.startsWith("http")) {
      target = url;
      if (!target.startsWith(baseUrl)) {
        return target;
      }
    } else if (url.startsWith("/media")) {
      target = baseUrl + url.substring(6);
    } else {
      target = baseUrl + url;
    }
    if (!target.endsWith(style) && !target.contains("x-oss-process=style")) {
      target = target + style;
    }
    return target;
  }
}
