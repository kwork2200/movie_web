import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:movie_web/core/resources/app_colors.dart';
import 'package:movie_web/core/resources/app_constants.dart';

class CustomBannerCard extends StatelessWidget {
  final double height;
  final double width;
  // final VoidCallback onTap;
  final String? imageUrl;

  static final List<String> _staticPosters = [
    'https://image.tmdb.org/t/p/w500/qNBAXBIQlnOThrVvA6mA2B5ggV6.jpg',
    'https://image.tmdb.org/t/p/w500/8Gxv8gSFCU0XGDykEGv7zR1n2ua.jpg',
    'https://image.tmdb.org/t/p/w500/jRXYjXNq0Cs2TcJjLkki24MLp7u.jpg',
    'https://image.tmdb.org/t/p/w500/9BBTo63ANSmhC4e6r62OJFuK2GL.jpg',
  ];

  const CustomBannerCard({
    super.key,
    required this.height,
    // required this.onTap,
    this.width = 320,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final String resolvedImageUrl = imageUrl ?? _staticPosters[DateTime.now().millisecondsSinceEpoch % _staticPosters.length];

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: width,
          height: height,
          child: Image.network(
            resolvedImageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: AppNetflixThemeColor.errorBackground,
                child:  Center(child: Icon(Icons.image_not_supported, color: AppNetflixThemeColor.errorIcon, size: 48)),
              );
            },
          ),
        ),
      ),
    );
  }
}