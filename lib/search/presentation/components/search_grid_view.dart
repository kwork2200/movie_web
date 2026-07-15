import 'package:flutter/material.dart';

import '../../../core/presentation/components/ads/hybrid_native_ad_widget.dart';
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

  int _itemsPerSection(int crossAxisCount) => crossAxisCount * 2;

  double _childAspectRatio(double width) {
    if (width >= 900) return 0.62;
    if (width >= 500) return 0.58;
    return 0.55;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final crossAxisCount = _crossAxisCount(width);
        final itemsPerSection = _itemsPerSection(crossAxisCount);
        final aspectRatio = _childAspectRatio(width);

        final sections = <List<SearchResultItem>>[];
        for (int i = 0; i < results.length; i += itemsPerSection) {
          sections.add(
            results.sublist(
              i,
              (i + itemsPerSection > results.length)
                  ? results.length
                  : i + itemsPerSection,
            ),
          );
        }
        final isWeb = width >= 900;
        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            for (int sectionIndex = 0;
            sectionIndex < sections.length;
            sectionIndex++) ...[
              SliverPadding(
                padding: EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 0,
                ),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      return GridViewCard(
                        item: sections[sectionIndex][index],
                      );
                    },
                    childCount: sections[sectionIndex].length,
                  ),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: aspectRatio,
                  ),
                ),
              ),

            ],
          ],
        );
      },
    );
  }
}