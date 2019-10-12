library public;

import 'dart:convert';

//util
export 'package:flutter_screenutil/flutter_screenutil.dart';
export 'package:cached_network_image/cached_network_image.dart';
export 'package:image_picker/image_picker.dart';
export 'package:fluttertoast/fluttertoast.dart';

//日期转化成时间戳工具
String getTime({int year, int month, int day}) {
  double time = DateTime(year, month, day).millisecondsSinceEpoch.toDouble();
  time = time.toDouble() / 1000;
  var date = time.toInt().toString();
  return date;
}

///时间戳转换成日期
String timestampToDateTime(num time) {
  num temp = time * 1000;
  DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(temp.toInt());
  // print(dateTime);
  return dateTime.toString();
}

///content转换成html
String contentToHtml({List<String> images, String text}) {
  var formData = {'images': images, 'text': text};

  print(jsonEncode(formData));
  String content = "";
  String imagePart = "";

  return imagePart;
}

/**
 *  <div data-v-5388caba="" class="wb-item-wrap">
    <div data-v-5388caba="" class="wb-item">
        <div data-v-5388caba="" class="card m-panel card9 f-weibo">
            
            <article class="weibo-main">
                <div class="card-wrap">
                      <div class="weibo-og">
                          <div class="weibo-text">美国《华尔街日报》对内地NBA球迷的报道。。。 </div>
                          <div data-v-58545971="">
                              <div data-v-58545971="" class="weibo-media-wraps weibo-media f-media media-b">
                                  <ul data-v-58545971="" class="m-auto-list">
                                      <li data-v-58545971="" class="m-auto-box2">
                                          <div data-v-58545971="" class="m-img-box m-imghold-4-3">
                                              <!----><img data-v-58545971=""
                                                  src="https://wx2.sinaimg.cn/orj360/6148b630ly1g7vc3s8rl7j20c808fdha.jpg"
                                                  class="f-bg-img">
                                              <!---->
                                          </div>
                                      </li>
                                      <li data-v-58545971="" class="m-auto-box2">
                                          <div data-v-58545971="" class="m-img-box m-imghold-4-3">
                                              <!----><img data-v-58545971=""
                                                  src="https://wx2.sinaimg.cn/orj360/6148b630ly1g7vc3s7n8fj20u00kpdj7.jpg"
                                                  class="f-bg-img">
                                              <!---->
                                          </div>
                                      </li>
                                  </ul>
                              </div>
                              <!---->
                          </div>
                      </div>
                </div>
                <!---->
            </article>
           
        </div>
    </div>
</div>
 */
