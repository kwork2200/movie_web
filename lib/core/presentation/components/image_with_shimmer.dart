import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../resources/app_colors.dart';

class ImageWithShimmer extends StatelessWidget {
  const ImageWithShimmer({
    super.key,
    required this.imageUrl,
    required this.width,
    required this.height,
  });

  final String imageUrl;
  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    // Use Image.network on web to avoid CORS issues with CachedNetworkImage
    if (kIsWeb) {
      return Image.network(
        imageUrl,
        height: height,
        width: width,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Shimmer.fromColors(
            baseColor: Colors.grey[850]!,
            highlightColor: Colors.grey[800]!,
            child: Container(height: height, color: AppNetflixThemeColor.secondaryText),
          );
        },
        errorBuilder: (context, error, stackTrace) => 
             Image.asset("assets/images/episode_default.png"),
      );
    }
    
    return CachedNetworkImage(
      imageUrl: imageUrl,
      height: height,
      width: width,
      fit: BoxFit.cover,
      placeholder: (_, _) => Shimmer.fromColors(
        baseColor: Colors.grey[850]!,
        highlightColor: Colors.grey[800]!,
        child: Container(height: height, color: AppNetflixThemeColor.secondaryText),
      ),
      errorWidget: (_, _, _) => const Icon(Icons.error, color: AppNetflixThemeColor.error),
    );
  }
}
