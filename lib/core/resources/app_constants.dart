import 'dart:html' as html;
import 'package:flutter/foundation.dart' show kIsWeb;

class AppConstants {
  AppConstants._();

  static const int carouselSliderItemsCount = 4;
  
  static const String smartLinkUrl =
      'https://bigotcomet.com/hmr4f43865?key=f1f00a35cf8e26a32e7e8cad972db50d';
  
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
}
