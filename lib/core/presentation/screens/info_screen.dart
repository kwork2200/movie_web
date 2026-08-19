import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:movie_web/core/presentation/components/ads/html_ad_widget.dart';
import 'package:movie_web/core/presentation/widget/custom_banner_card.dart';
import 'package:movie_web/core/resources/app_constants.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';
import '../../../ads/app_open_ad_manager.dart';
import '../components/ads/ad_enabled_screen.dart';
import '../components/ads/interstitial_ad_manager.dart';
import '../components/ads/qureka_interstitial.dart';
import '../../services/ad_service.dart';
import '../../services/fb_ad_service.dart';
import '../../services/remote_config_service.dart';
import '../../utils/functions.dart';
import '../../utils/screen_utils.dart';
import '../../resources/app_colors.dart';

class InfoScreen extends StatefulWidget {
  const InfoScreen({super.key});

  @override
  State<InfoScreen> createState() => _InfoScreenState();
}

class _InfoScreenState extends State<InfoScreen> {
  bool _isAdProcessing = !kIsWeb;

  @override
  void initState() {
    super.initState();
    GoogleFonts.config.allowRuntimeFetching = false;
    if (!kIsWeb) {
      _showAdsSequentially();
    }
    // Show popup ad banner after a delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _showPopupAdBanner();
      }
    });
  }

  Future<void> _showAdsSequentially() async {
    try {
      print('🎬 InfoScreen: Phase 1 - App Open Ad');
      await Future.any([
        // _tryShowAppOpenAd(),
        Future.delayed(const Duration(seconds: 1)),
      ]);
      await Future.delayed(const Duration(milliseconds: 800));
      await Future.any([Future.delayed(const Duration(seconds: 3))]);

      print('🎬 InfoScreen: All ads complete, displaying screen');
    } catch (e) {
      print('❌ InfoScreen: Critical error in ad sequence: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isAdProcessing = false;
        });
      }
    }
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  void _showPopupAdBanner() {
    AppConstants.showPopupAdBanner(context);
  }

  // ---- Responsive helpers ----
  bool _isWeb(double width) => width >= 900;

  bool _showSideAds(double width) => width >= 900;

  double _railWidth(double width) {
    if (width >= 1100) return 160;
    if (width >= 700) return 120;
    if (width >= 480) return 90;
    return 64;
  }

  double _railGap(double width) {
    if (width >= 1100) return 24;
    if (width >= 480) return 12;
    return 8;
  }

  double _maxContentWidth(double width) {
    double base;
    if (width >= 1400) {
      base = 720;
    } else if (width >= 900) {
      base = 640;
    } else {
      base = width;
    }

    if (_showSideAds(width)) {
      final rails = (_railWidth(width) + _railGap(width)) * 2;
      width -= rails;
    }

    return width.clamp(320.0, 720.0);
  }

  @override
  Widget build(BuildContext context) {
    if (_isAdProcessing) {
      return Scaffold(
        backgroundColor: AppNetflixThemeColor.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppNetflixThemeColor.primaryIndigo,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Loading...',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: AppNetflixThemeColor.mutedText,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {

        final width = constraints.maxWidth;

        print("sodefhsgnkfdg====$width");
        final isWeb = _isWeb(width);
        final showSideAds = _showSideAds(width);
        final railWidth = _railWidth(width);
        final railGap = _railGap(width);
        final isSmallWeb = width <= 1564;

        return Scaffold(
          backgroundColor: AppNetflixThemeColor.background,
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.only(bottom: isWeb ? 40 : 20),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showSideAds) ...[
                      Container(
                        width: railWidth,
                        padding: EdgeInsets.symmetric(
                          horizontal: railWidth >= 120 ? 16 : 6,
                          vertical: 16,
                        ),
                        child: Stack(
                          children: [
                            HtmlAdWidget(
                              viewType: 'ad-sidebar-left-160x600',
                              width: railWidth,
                              height: 2500,
                            ),
                            HtmlAdWidget(
                              viewType: 'ad-sidebar-left-160x600',
                              width: railWidth,
                              height: 2500,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox.shrink(), // SizedBox(width: railGap),
                    ],
                    Expanded(
                      child: SizedBox(
                        width: _maxContentWidth(width),

                        child: Container(
                          width: _maxContentWidth(width),
                          padding: EdgeInsets.all(
                            _maxContentWidth(width) < 260
                                ? 12
                                : (isWeb ? 32 : 24),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  if (isWeb) ...[
                                  // if (isWeb && isSmallWeb) ...[
                                    SizedBox(width: 300, height: 250, child: HtmlAdWidget(viewType: 'banner-2-300x250', width: 300, height: 250)),
                                    SizedBox(width: 10),
                                  ],
                                  Expanded(
                                    flex: isWeb ? 2 : 1,
                                    child: Container(
                                      width: double.infinity,
                                      padding: EdgeInsets.all(isWeb ? 44 : 32),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            AppNetflixThemeColor.primaryIndigo
                                                .withOpacity(0.15),
                                            AppNetflixThemeColor.secondaryPurple
                                                .withOpacity(0.15),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(24),
                                        border: Border.all(
                                          color: AppNetflixThemeColor.primaryIndigo
                                              .withOpacity(0.3),
                                          width: 1,
                                        ),
                                        boxShadow: isWeb
                                            ? [
                                                BoxShadow(
                                                  color: AppNetflixThemeColor
                                                      .primaryIndigo
                                                      .withOpacity(0.15),
                                                  blurRadius: 40,
                                                  offset: const Offset(0, 20),
                                                ),
                                              ]
                                            : null,
                                      ),
                                      child: Column(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.all(
                                              isWeb ? 24 : 20,
                                            ),
                                            decoration: BoxDecoration(
                                              gradient: const LinearGradient(
                                                colors: [
                                                  AppNetflixThemeColor
                                                      .primaryIndigo,
                                                  AppNetflixThemeColor
                                                      .secondaryPurple,
                                                ],
                                              ),
                                              borderRadius: BorderRadius.circular(20),
                                              boxShadow: [
                                                BoxShadow(color: AppNetflixThemeColor.primaryIndigo.withOpacity(0.4),
                                                  blurRadius: 24,
                                                  offset: const Offset(0, 10),
                                                ),
                                              ],
                                            ),
                                            child: Icon(
                                              Icons.play_circle_filled,
                                              size: isWeb ? 84 : 72,
                                              color: AppNetflixThemeColor.white,
                                            ),
                                          ),
                                          const SizedBox(height: 24),
                                          Text(
                                            'CINEPLEX',
                                            style: GoogleFonts.inter(
                                              fontSize: isWeb ? 40 : 32,
                                              fontWeight: FontWeight.w800,
                                              color: AppNetflixThemeColor.white,
                                              letterSpacing: 2,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            'Stream unlimited movies & TV shows',
                                            style: GoogleFonts.inter(
                                              fontSize: isWeb ? 17 : 16,
                                              color: AppNetflixThemeColor.mutedText,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(height: 28),
                                          _HoverButton(
                                            onTap: () async {
                                              // await AppConstants.openSmartLink();
                                              await Future.delayed(
                                                const Duration(milliseconds: 500),
                                              );
                                              if (context.mounted) {
                                                context.go('/language-selection');
                                              }
                                            },
                                            isWeb: isWeb,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  if (isWeb) ...[
                                    SizedBox(width: 10),
                                    SizedBox(width: 300, height: 250, child: HtmlAdWidget(viewType: 'banner-2-300x250', width: 300, height: 250)),
                                  ],
                                ],
                              ),
                              SizedBox(height: isWeb ? 24 : 0),
                              if (!isWeb)
                                Container(
                                  color: AppNetflixThemeColor.transparent,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 15,
                                  ),
                                  child: Center(
                                    child: Stack(
                                      children: [
                                        HtmlAdWidget(
                                          viewType: 'ad-bottom-468x60',
                                          width: width < 500 ? width - 32 : 468,
                                          height: 60,
                                        ),
                                        HtmlAdWidget(
                                          viewType: 'ad-bottom-468x60',
                                          width: width < 500 ? width - 32 : 468,
                                          height: 60,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              // Action tiles: stacked on mobile, side-by-side on web
                              isWeb
                                  ? Row(
                                      children: [
                                        Expanded(
                                          child: _buildModernActionTile(
                                            icon: Icons.star_rate_rounded,
                                            title: 'Rate Us',
                                            subtitle: isSmallWeb ? 'Help us\nimprove\nwith your\nfeedback..' : 'Help us improve with your feedback..',
                                            gradient: const LinearGradient(
                                              colors: [
                                                AppNetflixThemeColor
                                                    .secondaryPurple,
                                                AppNetflixThemeColor
                                                    .tertiaryPink,
                                              ],
                                            ),
                                            onTap: () async {
                                              // await AppConstants.openSmartLink();
                                              _launchURL(
                                                'https://play.google.com/store/apps',
                                              );
                                            },
                                            isWeb: true,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: _buildModernActionTile(
                                            icon: Icons.share_rounded,
                                            title: 'Share App',
                                            subtitle: isSmallWeb ? 'Share with your\nfriends..' : 'Share with your friends..',
                                            gradient: const LinearGradient(
                                              colors: [
                                                AppNetflixThemeColor
                                                    .primaryIndigo,
                                                AppNetflixThemeColor
                                                    .secondaryPurple,
                                              ],
                                            ),
                                            onTap: () async {
                                              // await AppConstants.openSmartLink();
                                              _launchURL(
                                                'https://play.google.com/store/apps',
                                              );
                                            },
                                            isWeb: true,
                                          ),
                                        ),
                                      ],
                                    )
                                  : Column(
                                      children: [
                                        _buildModernActionTile(
                                          icon: Icons.star_rate_rounded,
                                          title: 'Rate Us',
                                          subtitle:
                                              'Help us improve with your feedback',
                                          gradient: const LinearGradient(
                                            colors: [
                                              AppNetflixThemeColor
                                                  .secondaryPurple,
                                              AppNetflixThemeColor
                                                  .tertiaryPink,
                                            ],
                                          ),
                                          onTap: () async {
                                            // await AppConstants.openSmartLink();
                                            _launchURL(
                                              'https://play.google.com/store/apps',
                                            );
                                          },
                                          isWeb: false,
                                        ),
                                        const SizedBox(height: 16),
                                        _buildModernActionTile(
                                          icon: Icons.share_rounded,
                                          title: 'Share App',
                                          subtitle: 'Share with your friends',
                                          gradient: const LinearGradient(
                                            colors: [
                                              AppNetflixThemeColor
                                                  .primaryIndigo,
                                              AppNetflixThemeColor
                                                  .secondaryPurple,
                                            ],
                                          ),
                                          onTap: () async {
                                            // await AppConstants.openSmartLink();
                                            _launchURL(
                                              'https://play.google.com/store/apps',
                                            );
                                          },
                                          isWeb: false,
                                        ),
                                      ],
                                    ),
                              SizedBox(height: isWeb ? 24 : 0),
                              if (kIsWeb)
                                Padding(
                                  padding: const EdgeInsets.only(top: 15),
                                  child: Center(
                                    child: Stack(
                                      children: [
                                        _showAdsWithOverLay(child:HtmlAdWidget(viewType: 'ad-bottom-468x60', width: width < 500 ? width - 32 : 468, height: 60)),
                                        _showAdsWithOverLay(child:HtmlAdWidget(viewType: 'ad-bottom-468x60', width: width < 500 ? width - 32 : 468, height: 60)),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (showSideAds) ...[
                      const SizedBox.shrink(), // SizedBox(width: railGap),
                      Padding(
                        padding: EdgeInsets.only(
                          right: railWidth >= 120 ? 15.0 : 4.0,
                        ),
                        child: Container(
                          width: railWidth,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 0,
                            vertical: 16,
                          ),
                          child: Stack(
                            children: [
                              HtmlAdWidget(
                                viewType: 'ad-sidebar-right-160x600',
                                width: railWidth,
                                height: 1800,
                              ),
                              HtmlAdWidget(
                                viewType: 'ad-sidebar-right-160x600',
                                width: railWidth,
                                height: 1800,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _showAdsWithOverLay({Widget? child}) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 10,
      runSpacing: 10, children: List.generate(3, (index) => child ?? const SizedBox.shrink()),
    );
  }

  Widget _buildModernActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Gradient gradient,
    required VoidCallback onTap,
    required bool isWeb,
  }) {
    return _HoverTile(
      onTap: onTap,
      isWeb: isWeb,
      borderColor: gradient.colors.first,
      child: isWeb
          ? Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: AppNetflixThemeColor.white,
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: AppNetflixThemeColor.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppNetflixThemeColor.mutedText,
                ),
              ),
              const SizedBox(height: 12),
              Icon(
                Icons.arrow_forward_rounded,
                color: gradient.colors.first,
                size: 20,
              ),
            ],
          ),
          HtmlAdWidget(viewType: 'banner-2-300x250', width: 300, height: 250),
        ],
      )
          : Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: gradient,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    icon,
                    color: AppNetflixThemeColor.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppNetflixThemeColor.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppNetflixThemeColor.mutedText,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: gradient.colors.first.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    color: gradient.colors.first,
                    size: 20,
                  ),
                ),
              ],
            ),
    );
  }
}

/// Hover-aware wrapper for action tiles (scale + shadow on web/desktop)
class _HoverTile extends StatefulWidget {
  const _HoverTile({
    required this.child,
    required this.onTap,
    required this.isWeb,
    required this.borderColor,
  });

  final Widget child;
  final VoidCallback onTap;
  final bool isWeb;
  final Color borderColor;

  @override
  State<_HoverTile> createState() => _HoverTileState();
}

class _HoverTileState extends State<_HoverTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _hovered && widget.isWeb ? 1.02 : 1.0,
          duration: const Duration(milliseconds: 150),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppNetflixThemeColor.cardBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _hovered
                    ? widget.borderColor.withOpacity(0.7)
                    : widget.borderColor.withOpacity(0.3),
                width: 1,
              ),
              boxShadow: _hovered && widget.isWeb
                  ? [
                      BoxShadow(
                        color: widget.borderColor.withOpacity(0.25),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : null,
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

/// Hover-aware "Get Started" button
class _HoverButton extends StatefulWidget {
  const _HoverButton({required this.onTap, required this.isWeb});

  final VoidCallback onTap;
  final bool isWeb;

  @override
  State<_HoverButton> createState() => _HoverButtonState();
}

class _HoverButtonState extends State<_HoverButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _hovered && widget.isWeb ? 1.03 : 1.0,
          duration: const Duration(milliseconds: 150),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: EdgeInsets.symmetric(
              horizontal: widget.isWeb ? 48 : 40,
              vertical: 16,
            ),
            decoration: BoxDecoration(
              color: AppNetflixThemeColor.primaryIndigo,
              borderRadius: BorderRadius.circular(14),
              boxShadow: _hovered
                  ? [
                      BoxShadow(
                        color: AppNetflixThemeColor.primaryIndigo.withOpacity(
                          0.5,
                        ),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ]
                  : [],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Get Started',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppNetflixThemeColor.white,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.arrow_forward,
                  size: 17,
                  color: AppNetflixThemeColor.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
