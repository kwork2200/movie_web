import 'dart:html' as html;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:movie_web/core/presentation/components/ads/html_ad_widget.dart';

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

  static Widget banner468x60Ads() {
    return const Center(child: HtmlAdWidget(viewType: 'banner-1-468x60', width: 468, height: 60));
  }

  static Widget banner300x250Ads() {
    return const Center(child: HtmlAdWidget(viewType: 'banner-2-300x250', width: 300, height: 250));
  }

  static Widget banner160x600Ads() {
    return const Center(child: HtmlAdWidget(viewType: 'banner-3-160x600', width: 160, height: 600));
  }

  static Widget banner160x300Ads() {
    return const Center(child: HtmlAdWidget(viewType: 'banner-4-160x300', width: 160, height: 300));
  }

  static Widget banner320x50Ads() {
    return const Center(child: HtmlAdWidget(viewType: 'banner-5-320x50', width: 320, height: 50));
  }

  static Widget banner728x90Ads() {
    return const Center(child: HtmlAdWidget(viewType: 'banner-6-728x90', width: 728, height: 90));
  }

  static Widget adSidebarLeft160x600Ads() {
    return const Center(child: HtmlAdWidget(viewType: 'ad-sidebar-left-160x600', width: 160, height: 600));
  }

  static Widget adSidebarRight160x600Ads() {
    return const Center(child: HtmlAdWidget(viewType: 'ad-sidebar-right-160x600', width: 160, height: 600));
  }

  static Widget adBottom468x60Ads() {
    return const Center(child: HtmlAdWidget(viewType: 'ad-bottom-468x60', width: 468, height: 60));
  }


}
