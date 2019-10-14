import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:extended_image/extended_image.dart';
import 'package:finder/public.dart';

///用于图片加载以及报错
Widget imageLoadStateChange(ExtendedImageState state) {
  switch (state.extendedImageLoadState) {
    case LoadState.loading:
      // _controller.reset();
      return CircularProgressIndicator();
      break;
    case LoadState.completed:
      // _controller.forward();
      return ExtendedRawImage(
        image: state.extendedImageInfo?.image,
      );
      break;
    case LoadState.failed:
      // _controller.reset();
      return GestureDetector(
        child: Container(
          child: Icon(
            Icons.error,
            color: Colors.white,
            size: 34,
          ),
        ),
        onTap: () {
          state.reLoadImage();
        },
      );
      break;
  }
}
