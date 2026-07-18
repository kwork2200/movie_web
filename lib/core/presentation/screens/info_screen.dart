import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:movie_web/core/presentation/components/ads/html_ad_widget.dart';
import 'package:movie_web/core/presentation/widget/popup_ad_banner.dart';
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
      await Future.any([
        Future.delayed(const Duration(seconds: 3)),
      ]);

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
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      // barrierColor: AppNetflixThemeColor.black.withOpacity(0.7),
      builder: (context) => const PopupAdBanner(bannerWidth: 468, bannerHeight: 340),
    );
  }

  // ---- Responsive helpers ----
  bool _isWeb(double width) => width >= 900;

  double _maxContentWidth(double width) {
    if (width >= 1400) return 720;
    if (width >= 900) return 640;
    return width;
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
        final isWeb = _isWeb(width);

        return Scaffold(
          backgroundColor: AppNetflixThemeColor.background,
          // appBar: AppBar(
          //   backgroundColor: AppNetflixThemeColor.transparent,
          //   elevation: 0,
          //   title: Text(
          //     'Welcome',
          //     style: GoogleFonts.inter(
          //       fontSize: 20,
          //       fontWeight: FontWeight.w600,
          //       color: AppNetflixThemeColor.white,
          //     ),
          //   ),
          // ),
          body: Stack(
            children: [
              Positioned.fill(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: kIsWeb ? 120 : 20, // space for bottom banner
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ⬇️ Left banner (web only, wide screens) - native banner (responsive)
                        if (kIsWeb && width >= 1200)
                          Container(
                            width: 160,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                            child: const HtmlAdWidget(
                              viewType: 'ad-sidebar-left-160x600',
                              width: 160,
                              height: 2500,
                            ),
                          ),

                        Expanded(
                          child: Center(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: _maxContentWidth(width),
                              ),
                              child: Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(isWeb ? 32 : 24),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: double.infinity,
                                      padding: EdgeInsets.all(isWeb ? 44 : 32),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            AppNetflixThemeColor.primaryIndigo.withOpacity(0.15),
                                            AppNetflixThemeColor.secondaryPurple.withOpacity(0.15),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius:
                                        BorderRadius.circular(24),
                                        border: Border.all(
                                          color: AppNetflixThemeColor.primaryIndigo.withOpacity(0.3), width: 1),
                                        boxShadow: isWeb
                                            ? [
                                          BoxShadow(
                                            color: AppNetflixThemeColor.primaryIndigo
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
                                                isWeb ? 24 : 20),
                                            decoration: BoxDecoration(
                                              gradient: const LinearGradient(
                                                colors: [
                                                  AppNetflixThemeColor.primaryIndigo,
                                                  AppNetflixThemeColor.secondaryPurple,
                                                ],
                                              ),
                                              borderRadius:
                                              BorderRadius.circular(20),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: AppNetflixThemeColor.primaryIndigo
                                                      .withOpacity(0.4),
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
                                              await AppConstants
                                                  .openSmartLink();
                                              await Future.delayed(
                                                  const Duration(
                                                      milliseconds: 500));
                                              if (context.mounted) {
                                                context.go(
                                                    '/language-selection');
                                              }
                                            },
                                            isWeb: isWeb,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    // Action tiles: stacked on mobile, side-by-side on web
                                    isWeb
                                        ? Row(
                                      children: [
                                        Expanded(
                                          child:
                                          _buildModernActionTile(
                                            icon: Icons
                                                .star_rate_rounded,
                                            title: 'Rate Us',
                                            subtitle:
                                            'Help us improve with your feedback..',
                                            gradient:
                                            const LinearGradient(
                                              colors: [
                                                AppNetflixThemeColor.secondaryPurple,
                                                AppNetflixThemeColor.tertiaryPink,
                                              ],
                                            ),
                                            onTap: () async{
                                              await AppConstants.openSmartLink();
                                              _launchURL(
                                                  'https://play.google.com/store/apps');
                                            },
                                            isWeb: true,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child:
                                          _buildModernActionTile(
                                            icon: Icons.share_rounded,
                                            title: 'Share App',
                                            subtitle:
                                            'Share with your friends..',
                                            gradient:
                                            const LinearGradient(
                                              colors: [
                                                AppNetflixThemeColor.primaryIndigo,
                                                AppNetflixThemeColor.secondaryPurple,
                                              ],
                                            ),
                                            onTap: () async{
                                              await AppConstants.openSmartLink();
                                              _launchURL(
                                                  'https://play.google.com/store/apps');
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
                                          gradient:
                                          const LinearGradient(
                                            colors: [
                                              AppNetflixThemeColor.secondaryPurple,
                                              AppNetflixThemeColor.tertiaryPink,
                                            ],
                                          ),
                                          onTap: () async{
                                            await AppConstants.openSmartLink();
                                            _launchURL(
                                                'https://play.google.com/store/apps');
                                          },
                                          isWeb: false,
                                        ),
                                        const SizedBox(height: 16),
                                        _buildModernActionTile(
                                          icon: Icons.share_rounded,
                                          title: 'Share App',
                                          subtitle:
                                          'Share with your friends',
                                          gradient:
                                          const LinearGradient(
                                            colors: [
                                              AppNetflixThemeColor.primaryIndigo,
                                              AppNetflixThemeColor.secondaryPurple,
                                            ],
                                          ),
                                          onTap: () async{
                                            await AppConstants.openSmartLink();
                                            _launchURL(
                                                'https://play.google.com/store/apps');
                                          },
                                          isWeb: false,
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: isWeb ? 24 : 0),

                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        // ⬇️ Right banner (web only, wide screens) - native banner (responsive)
                        if (kIsWeb && width >= 1200)
                          Padding(
                            padding: const EdgeInsets.only(right:15.0),
                            child: Container(
                              width: 160,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 0,

                                vertical: 16,
                              ),
                              child: const HtmlAdWidget(
                                viewType: 'ad-sidebar-right-160x600',
                                width: 160,
                                height: 1800,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              // ⬇️ Bottom banner (web only, floats over content) - stays thin 468x60
              if (kIsWeb)
                Positioned(
                  bottom: 30,
                  left: 0,
                  right: 0,
                  child: Container(
                    // color: const Color(0xFF0A0E1A),
                    color: AppNetflixThemeColor.transparent,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: const Center(
                      child: HtmlAdWidget(
                        viewType: 'ad-bottom-468x60',
                        width: 468,
                        height: 60,
                      ),
                    ),
                  ),
                ),

            ],
          ),
        );
      },
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
          ? Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppNetflixThemeColor.white, size: 28),
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
            style: GoogleFonts.inter(
              fontSize: 13,
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
            child: Icon(icon, color: AppNetflixThemeColor.white, size: 28),
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
                  color: AppNetflixThemeColor.primaryIndigo.withOpacity(0.5),
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
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppNetflixThemeColor.white,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward, size: 20, color: AppNetflixThemeColor.white),
              ],
            ),
          ),
        ),
      ),
    );
  }
}