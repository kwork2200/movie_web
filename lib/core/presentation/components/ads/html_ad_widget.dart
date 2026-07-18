import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:ui_web' as ui_web;
import 'dart:html' as html;

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
/// Add/remove entries here as you add/remove ad placements. If your ad
/// network gives you the SAME key working at multiple sizes (like the
/// 492dba0b... key in your other project), reuse that key across entries.
/// If a size needs its own key from the dashboard, put that key here instead.
void registerAllAdViews() {
  if (!kIsWeb) return;

  final ads = {
    'banner-1-468x60': {
      'key': 'f92fd51462df13e93e1549f302a4f668',
      'w': 468,
      'h': 60,
    },
    'banner-728x90': {
      'key': '14c1219b6c6a21061e2795fa9dcef8e5',
      'w': 728,
      'h': 90,
    },
    'banner-2-300x250': {
      'key': '5cb6f6899f19690a46f7d9fb4692177a',
      'w': 300,
      'h': 250,
    },
    'banner-3-160x600': {
      'key': '9334562f34012e4dd1841f78d4c7d332',
      'w': 160,
      'h': 600,
    },
    'banner-4-160x300': {
      'key': '063c76c839f754d4f5f60c9988ad6e92',
      'w': 160,
      'h': 300,
    },
    'banner-5-320x50': {
      'key': 'dbeb85669fb7da87e9f90d8241f72b3c',
      'w': 320,
      'h': 50,
    },
    'banner-6-728x90': {
      'key': '14c1219b6c6a21061e2795fa9dcef8e5',
      'w': 728,
      'h': 90,
    },
    'ad-sidebar-left-160x600': {
      'key': '9334562f34012e4dd1841f78d4c7d332',
      'w': 160,
      'h': 600,
    },
    'ad-sidebar-right-160x600': {
      'key': '9334562f34012e4dd1841f78d4c7d332',
      'w': 160,
      'h': 600,
    },
    'ad-bottom-468x60': {
      'key': 'f92fd51462df13e93e1549f302a4f668',
      'w': 468,
      'h': 60,
    },
  };

  ads.forEach((viewType, config) {
    ui_web.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
      final adKey = config['key'] as String;
      final w = config['w'] as int;
      final h = config['h'] as int;
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
