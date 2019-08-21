import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:finder/model/banner_model.dart';

class HomePageBanner extends StatelessWidget {
  final BannerModel banner;
  HomePageBanner(this.banner);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 0),
      height: ScreenUtil().setHeight(400),
      width: ScreenUtil().setWidth(750),
      color: Colors.white,
      child: Swiper(
        onTap: (index) {},
        viewportFraction: 0.8,
        scale: 0.8,
        autoplay: true,
        itemCount: banner.data.length,
        itemBuilder: (context, index) {
          return _singleItem(context, banner.data[index]);
        },
      ),
    );
  }

  _singleItem(BuildContext context, BannerModelData item) {
    return Container(
      decoration: BoxDecoration(
          image: DecorationImage(
              image: NetworkImage(item.image), fit: BoxFit.fill),
          borderRadius: BorderRadius.all(Radius.circular(3))),
    );
  }
}
