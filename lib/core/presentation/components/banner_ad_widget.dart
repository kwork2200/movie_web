import 'package:flutter/material.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
// ignore: avoid_web_libraries_in_flutter
import 'dart:ui_web' as ui_web;

class BannerAdWidget extends StatefulWidget {
  final double width;
  final double height;
  final String adKey;

  const BannerAdWidget({
    super.key,
    this.width = 160,
    this.height = 300,
    required this.adKey,
  });

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  late String viewId;
  static final Set<String> _registeredViewIds = {};
  static int _adCounter = 0;

  @override
  void initState() {
    super.initState();
    _adCounter++;
    viewId = 'banner-ad-${_adCounter}-${widget.adKey}-${DateTime.now().microsecondsSinceEpoch}';
    _registerAdView();
  }

  void _registerAdView() {
    if (_registeredViewIds.contains(viewId)) {
      return;
    }
    
    try {
      final uniqueId = viewId.replaceAll('-', '_').replaceAll('.', '_');
      
      ui_web.platformViewRegistry.registerViewFactory(
        viewId,
        (int factoryViewId) {
          // Create an iframe to bypass Flutter's HTML sanitization
          final iframe = html.IFrameElement()
            ..id = 'ad-iframe-$uniqueId'
            ..style.width = '${widget.width.toInt()}px'
            ..style.height = '${widget.height.toInt()}px'
            ..style.border = 'none'
            ..style.overflow = 'hidden';

          // Create HTML content with ad scripts
          final adHtml = '''
            <!DOCTYPE html>
            <html>
            <head>
              <style>
                body {
                  margin: 0;
                  padding: 0;
                  overflow: hidden;
                  display: flex;
                  align-items: center;
                  justify-content: center;
                  width: ${widget.width.toInt()}px;
                  height: ${widget.height.toInt()}px;
                  background: transparent;
                }
                #ad-container {
                  width: ${widget.width.toInt()}px;
                  height: ${widget.height.toInt()}px;
                }
              </style>
            </head>
            <body>
              <div id="ad-container"></div>
              <script type="text/javascript">
                atOptions = {
                  'key': 'b347d3f3f9b37ca40047e6d5457181d5',
                  'format': 'iframe',
                  'height': ${widget.height.toInt()},
                  'width': ${widget.width.toInt()},
                  'params': {}
                };
              </script>
              <script type="text/javascript" src="https://bigotcomet.com/b347d3f3f9b37ca40047e6d5457181d5/invoke.js"></script>
              <script>
                console.log('✅ Ad iframe loaded: $uniqueId');
              </script>
            </body>
            </html>
          ''';

          // Set iframe content using srcdoc
          iframe.srcdoc = adHtml;

          return iframe;
        },
      );
      
      _registeredViewIds.add(viewId);
      debugPrint('✅ Ad registered: $viewId (Total: ${_registeredViewIds.length})');
    } catch (e) {
      debugPrint('❌ Error registering ad: $viewId - $e');
    }
  }

  @override
  void dispose() {
    _registeredViewIds.remove(viewId);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: HtmlElementView(viewType: viewId),
      ),
    );
  }
}
