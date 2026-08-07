import 'dart:html' as html;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:movie_web/core/presentation/components/ads/html_ad_widget.dart';
import 'package:movie_web/core/presentation/widget/popup_ad_banner.dart';

class AppConstants {
  AppConstants._();

  static const int carouselSliderItemsCount = 4;
  
  static const String smartLinkUrl =
      'https://bigotcomet.com/ndtn3xatmz?key=4615b0f3696e6dfd4ecd1209d18af85c';
      // 'https://bigotcomet.com/hmr4f43865?key=f1f00a35cf8e26a32e7e8cad972db50d';

  /// Opens the SmartLink ad in a new tab/window
  static Future<void> openSmartLink() async {
    try {
      if (kIsWeb) {
        html.window.open(smartLinkUrl, '_blank');
      } else {
        // For mobile apps, you can use url_launcher
        print('SmartLink opening: $smartLinkUrl');
      }
    } catch (e) {
      print('Error opening smartlink: $e');
    }
  }

  /// Shows the popup ad banner dialog
  static void showPopupAdBanner(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      builder: (context) => const PopupAdBanner(bannerWidth: 468, bannerHeight: 340),
    );
  }


}
