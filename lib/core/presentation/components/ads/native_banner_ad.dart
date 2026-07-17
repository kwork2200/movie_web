import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:ui_web' as ui_web;
import 'dart:html' as html;

/// Renders a BigotComet/Adsterra-style "atOptions" banner INSIDE the
/// Flutter widget tree, on screen.
///
/// This kind of ad script uses `document.write`, which breaks the whole
/// page if it's injected directly into the live DOM after the page has
/// already loaded. To make it safe, we load it inside an isolated
/// `<iframe srcdoc="...">` — the script writes into the iframe's own
/// document instead of the app's document, so it can't wipe the page.
class AdsterraBannerAd extends StatefulWidget {
  final String adKey; // the 'key' value from atOptions, e.g. '5a8cd312...'
  final double width;
  final double height;

  const AdsterraBannerAd({
    super.key,
    required this.adKey,
    this.width = 468,
    this.height = 60,
  });

  @override
  State<AdsterraBannerAd> createState() => _AdsterraBannerAdState();
}

class _AdsterraBannerAdState extends State<AdsterraBannerAd> {
  late final String _viewType;

  @override
  void initState() {
    super.initState();
    _viewType =
    'adsterra-banner-${widget.adKey}-${DateTime.now().microsecondsSinceEpoch}';
    if (kIsWeb) {
      _registerAdView();
    }
  }

  void _registerAdView() {
    final key = widget.adKey;
    final w = widget.width.toInt();
    final h = widget.height.toInt();

    // ignore: undefined_prefixed_name
    ui_web.platformViewRegistry.registerViewFactory(_viewType, (int viewId) {
      final iframe = html.IFrameElement()
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.overflow = 'hidden'
        ..srcdoc = '''
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
    'key' : '$key',
    'format' : 'iframe',
    'height' : $h,
    'width' : $w,
    'params' : {}
  };
</script>
<script src="https://bigotcomet.com/$key/invoke.js"></script>
</body>
</html>
''';
      return iframe;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) {
      return const SizedBox.shrink();
    }
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: HtmlElementView(viewType: _viewType),
    );
  }
}