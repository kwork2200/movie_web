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
    'ad-sidebar-left-160x600': {
      'key': '492dba0b4aae99668228cff04108b8db',
      'w': 160,
      'h': 2500,
    },
    'ad-sidebar-right-160x600': {
      'key': '492dba0b4aae99668228cff04108b8db',
      'w': 160,
      'h': 2500,
    },
    'ad-bottom-468x60': {
      'key': '5a8cd312001dbc755cb5c5089fc24fa3',
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
