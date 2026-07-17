import 'package:flutter/material.dart';

import '../../domain/entities/media.dart';
import '../../resources/app_colors.dart';
import '../../resources/app_values.dart';
import '../../utils/functions.dart';
import 'image_with_shimmer.dart';

class VerticalListViewCard extends StatelessWidget {
  const VerticalListViewCard({
    super.key,
    required this.media,
  });

  final Media media;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: () => navigateToDetailsView(context, media),
      child: Container(
        width: 220,
        height: 320,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSize.s8),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSize.s8),
          child: Stack(
            children: [
              Positioned.fill(
                child: ImageWithShimmer(
                  imageUrl: media.posterUrl,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),

              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppNetflixThemeColor.transparent,
                        AppNetflixThemeColor.cardGradientStart,
                        AppNetflixThemeColor.cardGradientMid,
                        AppNetflixThemeColor.cardGradientEnd,
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        media.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.titleMedium?.copyWith(
                          color: AppNetflixThemeColor.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Row(
                        children: [
                          if (media.releaseDate.isNotEmpty)
                            Expanded(
                              child: Text(
                                media.releaseDate.split('-')[0],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppNetflixThemeColor.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ),

                          const SizedBox(width: 6),

                          const Icon(
                            Icons.star_rate_rounded,
                            color: Colors.amber,
                            size: 14,
                          ),

                          const SizedBox(width: 2),

                          Text(
                            media.voteAverage.toStringAsFixed(1),
                            style: const TextStyle(
                              color: AppNetflixThemeColor.white,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),


                      const SizedBox(height: 8),

                      Text(
                        media.overview,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppNetflixThemeColor.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
