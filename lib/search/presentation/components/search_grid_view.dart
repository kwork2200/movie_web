import 'package:flutter/material.dart';

import '../../../core/presentation/components/ads/hybrid_native_ad_widget.dart';
import '../../../core/presentation/components/banner_ad_widget.dart';
import '../../../core/resources/app_values.dart';
import '../../domain/entities/search_result_item.dart';
import 'grid_view_card.dart';

class SearchGridView extends StatelessWidget {
  const SearchGridView({
    super.key,
    required this.results,
  });

  final List<SearchResultItem> results;

  int _crossAxisCount(double width) {
    if (width >= 1400) return 8;
    if (width >= 1100) return 7;
    if (width >= 900) return 6;
    if (width >= 700) return 5;
    if (width >= 500) return 4;
    return 3; // mobile default
  }

  double _childAspectRatio(double width) {
    if (width >= 900) return 0.62;
    if (width >= 500) return 0.58;
    return 0.55;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        print('Width : ${constraints.maxWidth}');
        print('Height: ${constraints.maxHeight}');

        final width = constraints.maxWidth;
        final crossAxisCount = _crossAxisCount(width);
        final aspectRatio = _childAspectRatio(width);

        final List<Widget> itemsWithAds = [];
        int adCounter = 0;
        for (int i = 0; i < results.length; i++) {
          itemsWithAds.add(GridViewCard(item: results[i]));
          if ((i + 1) % 2 == 0 && i < results.length - 1) {
            adCounter++;
            itemsWithAds.add(
              Center(
                child: BannerAdWidget(
                  width: 160,
                  height: 300,
                  adKey: '16bd2bc289ee2531871e1be42c1d1c9b$adCounter',
                ),
              ),
            );
          }
        }
        return GridView.builder(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 8),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 23,
            mainAxisSpacing: 12,
            childAspectRatio: aspectRatio,
          ),
          itemCount: itemsWithAds.length,

          itemBuilder: (context, index) {
            return itemsWithAds[index];
          },
        );
      },
    );
  }
}