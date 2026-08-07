import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:ui_web' as ui_web;
import 'dart:html' as html;
import 'package:movie_web/core/services/firebase_ad_config_service.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

/// Generic reusable widget for ANY iframe-based banner ad (Adsterra /
/// BigotComet "atOptions" style). One widget handles every size —
/// you just pass a different `viewType` + width/height per placement.
class HtmlAdWidget extends StatelessWidget {
  final String viewType;
  final double width;
  final double height;

  const HtmlAdWidget({
    super.key,
    required this.viewType,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) return const SizedBox.shrink();
    return SizedBox(
      width: width,
      height: height,
      child: HtmlElementView(viewType: viewType),
    );
  }
}

/// Call this ONCE (e.g. in main() before runApp, or in initState of your
/// root widget) — guarded by kIsWeb. Registers a platform view factory for
/// every ad placement so HtmlAdWidget can just reference it by viewType.
///
/// Now fetches ad keys from Firebase Remote Config instead of hardcoded values.
/// Make sure to call FirebaseAdConfigService().initialize() before this.
void registerAllAdViews() {
  if (!kIsWeb) return;

  final adConfigService = FirebaseAdConfigService();
  print('=== Firebase Ad Keys from Remote Config ===');
  Map<String, String> allAdKeys = adConfigService.getAllAdKeys();
  allAdKeys.forEach((placement, key) {
    print('$placement: $key');
  });
  print('Total keys fetched: ${allAdKeys.length}');
  print('============================================\n');

  final ads = {
    'banner-1-468x60': {
      'key': adConfigService.getAdKey('banner-1-468x60'),
      'w': 468,
      'h': 60,
    },
    'banner-728x90': {
      'key': adConfigService.getAdKey('banner-728x90'),
      'w': 728,
      'h': 90,
    },
    'banner-2-300x250': {
      'key': adConfigService.getAdKey('banner-2-300x250'),
      'w': 300,
      'h': 250,
    },
    'banner-3-160x600': {
      'key': adConfigService.getAdKey('banner-3-160x600'),
      'w': 160,
      'h': 600,
    },
    'banner-4-160x300': {
      'key': adConfigService.getAdKey('banner-4-160x300'),
      'w': 160,
      'h': 300,
    },
    'banner-5-320x50': {
      'key': adConfigService.getAdKey('banner-5-320x50'),
      'w': 320,
      'h': 50,
    },
    'banner-6-728x90': {
      'key': adConfigService.getAdKey('banner-6-728x90'),
      'w': 728,
      'h': 90,
    },
    'ad-sidebar-left-160x600': {
      'key': adConfigService.getAdKey('ad-sidebar-left-160x600'),
      'w': 160,
      'h': 600,
    },
    'ad-sidebar-right-160x600': {
      'key': adConfigService.getAdKey('ad-sidebar-right-160x600'),
      'w': 160,
      'h': 600,
    },
    'ad-bottom-468x60': {
      'key': adConfigService.getAdKey('ad-bottom-468x60'),
      'w': 468,
      'h': 60,
    },
  };

  ads.forEach((viewType, config) {
    ui_web.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
      final adKey = config['key'] as String;
      final w = config['w'] as int;
      final h = config['h'] as int;

      if (adKey.isEmpty) {

          print('⚠️ Ad key not found for $viewType');

        return html.DivElement()..innerText = 'Ad unavailable';
      }

      final srcDoc = '''
        <!DOCTYPE html>
        <html>
          <head>
            <style>
              html, body { margin:0; padding:0; overflow:hidden; background:transparent; }
            </style>
          </head>
          <body>
            <script>
              atOptions = {
                'key' : '$adKey',
                'format' : 'iframe',
                'height' : $h,
                'width' : $w,
                'params' : {}
              };
            </script>
            <script src="https://bigotcomet.com/$adKey/invoke.js"></script>
          </body>
        </html>
      ''';
      final iframe = html.IFrameElement()
        ..style.width = '${w}px'
        ..style.height = '${h}px'
        ..style.border = 'none'
        ..srcdoc = srcDoc;
      return iframe;
    });
  });
}
