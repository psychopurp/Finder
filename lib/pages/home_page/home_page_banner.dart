import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:finder/models/banner_model.dart';
import 'package:finder/public.dart';
import 'package:flutter/cupertino.dart';

class HomePageBanner extends StatelessWidget {
  final BannerModel banner;
  HomePageBanner(this.banner);
  final double bannerHeight = 135;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 0),
      padding: EdgeInsets.symmetric(horizontal: 10.0),
      height: bannerHeight,
      width: ScreenUtil().setWidth(750),
      // color: Colors.amber,
      child: Swiper(
        // layout: SwiperLayout.CUSTOM,
        // autoplayDelay: 100,
        onTap: (index) {},
        // viewportFraction: 0.75,
        // scale: 0.7,
        pagination: SwiperPagination(
            margin: const EdgeInsets.only(
                top: 10.0, left: 10.0, right: 10.0, bottom: 5.0),
            alignment: Alignment.bottomCenter,
            builder: DotSwiperPaginationBuilder(
                size: 6,
                activeSize: 7,
                activeColor: Colors.white,
                color: Colors.white.withOpacity(0.5))),
        // itemWidth: 750,
        // itemHeight: 400,
        autoplay: true,
        itemCount: banner.data.length,
        itemBuilder: (context, index) {
          return _singleItem(context, banner.data[index]);
        },
      ),
    );
  }

  _singleItem(BuildContext context, BannerModelData item) {
    return CachedNetworkImage(
      imageUrl: item.image,
      imageBuilder: (context, imageProvider) => Container(
        decoration: BoxDecoration(
          // color: Colors.green,
          // borderRadius: BorderRadius.all(Radius.circular(3)),
          // border: Border.all(color: Colors.black, width: 2),
          image: DecorationImage(
            image: imageProvider,
            fit: BoxFit.fill,
            // colorFilter: ColorFilter.mode(Colors.red, BlendMode.colorBurn)
          ),
        ),
      ),
      // placeholder: (context, url) => CupertinoActivityIndicator(),
      errorWidget: (context, url, error) => Icon(Icons.error),
      // fadeOutDuration: new Duration(seconds: 1),
      // fadeInDuration: new Duration(seconds: 3),
    );
  }
}
