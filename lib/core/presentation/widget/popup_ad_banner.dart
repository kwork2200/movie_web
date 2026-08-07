import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:movie_web/core/resources/app_colors.dart';
import 'package:movie_web/core/resources/app_constants.dart';
import '../components/ads/html_ad_widget.dart';
import 'custom_banner_card.dart';

class PopupAdBanner extends StatefulWidget {
  final double bannerWidth;
  final double bannerHeight;
  final String? imageUrl;

  const PopupAdBanner({
    super.key,
    this.bannerWidth = 400,
    this.bannerHeight = 340,
    this.imageUrl,
  });

  @override
  State<PopupAdBanner> createState() => _PopupAdBannerState();
}

class _PopupAdBannerState extends State<PopupAdBanner> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: child,
              ),
            );
          },
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: screenWidth - 80,
            ),
            // margin: EdgeInsets.symmetric(horizontal: 20),
            child: IntrinsicWidth(
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.topRight,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: AppNetflixThemeColor.cardBackground,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height:50),
                        Container(
                          color: AppNetflixThemeColor.transparent,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Center(
                            child: Stack(
                              children:  [
                                HtmlAdWidget(viewType: 'ad-bottom-468x60', width: 468, height: 60),
                                HtmlAdWidget(viewType: 'ad-bottom-468x60', width: 468, height: 60),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: CustomBannerCard(
                            height: widget.bannerHeight,
                            width: widget.bannerWidth,
                            imageUrl: widget.imageUrl,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          print('Close button tapped');
                          Navigator.of(context, rootNavigator: true).pop();
                        },
                        borderRadius: BorderRadius.circular(18),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppNetflixThemeColor.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.close,
                            color: AppNetflixThemeColor.netflixRed,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
