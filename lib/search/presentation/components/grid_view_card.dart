import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/presentation/components/image_with_shimmer.dart';
import '../../../core/resources/app_constants.dart';
import '../../../core/resources/app_routes.dart';
import '../../../core/resources/app_values.dart';
import '../../../core/resources/app_colors.dart';
import '../../domain/entities/search_result_item.dart';

class GridViewCard extends StatefulWidget {
  const GridViewCard({super.key, required this.item});

  final SearchResultItem item;

  @override
  State<GridViewCard> createState() => _GridViewCardState();
}

class _GridViewCardState extends State<GridViewCard> {
  bool _isHovered = false;

  void _onTap(BuildContext context) async {
    await AppConstants.openSmartLink();

    print("type--> ${widget.item.isMovie}");
    widget.item.isMovie
        ? context.pushNamed(
      AppRoutes.movieDetailsRoute,
      pathParameters: {'movieId': widget.item.tmdbID.toString()},
    )
        : context.pushNamed(
      AppRoutes.tvShowDetailsRoute,
      pathParameters: {'tvShowId': widget.item.tmdbID.toString()},
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () => _onTap(context),
        child: Column(
          children: [
            SizedBox(height: 30,),
            AspectRatio(
              aspectRatio: 2.3 / 3.2,
              child: AnimatedScale(
                scale: _isHovered ? 1.04 : 1.0,
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppSize.s8),
                    boxShadow: _isHovered
                        ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ]
                        : [],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppSize.s8),
                    child: ImageWithShimmer(
                      imageUrl: widget.item.posterUrl,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: Text(
                widget.item.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: _isHovered
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}