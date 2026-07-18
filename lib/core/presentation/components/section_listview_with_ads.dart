import 'package:flutter/material.dart';
import '../../resources/app_values.dart';
import 'banner_ad_widget.dart';

class SectionListViewWithAds extends StatelessWidget {
  final int itemCount;
  final double height;
  final Widget Function(BuildContext context, int index) itemBuilder;
  final String adKey;
  final int adInterval; // Kitne items ke baad ad dikhana hai

  const SectionListViewWithAds({
    required this.height,
    required this.itemCount,
    required this.itemBuilder,
    required this.adKey,
    this.adInterval = 2, // Default: har 2 items ke baad
    super.key,
  });

  // Calculate total items including ads
  int get _totalItemsWithAds {
    if (itemCount == 0) return 0;
    // Formula: original items + number of ads
    // Ads appear after every 'adInterval' items
    int adsCount = (itemCount / adInterval).floor();
    return itemCount + adsCount;
  }

  // Check if current position should show an ad
  bool _isAdPosition(int index) {
    // Ad positions: after every 'adInterval' items
    // Positions: adInterval, (adInterval*2)+1, (adInterval*3)+2, etc.
    int adjustedIndex = index + 1;
    int blockNumber = adjustedIndex ~/ (adInterval + 1);
    int positionInBlock = adjustedIndex % (adInterval + 1);
    
    return positionInBlock == adInterval && blockNumber * adInterval < itemCount;
  }

  // Get original item index from displayed index
  int _getOriginalIndex(int displayIndex) {
    int adsBeforeThis = (displayIndex / (adInterval + 1)).floor();
    return displayIndex - adsBeforeThis;
  }

  @override
  Widget build(BuildContext context) {
    if (itemCount == 0) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: height,
      width: double.infinity,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: AppPadding.p16),
        itemCount: _totalItemsWithAds,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          if (_isAdPosition(index)) {
            // Show banner ad
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: AppPadding.p8),
              child: BannerAdWidget(
                width: 160,
                height: 300,
                adKey: '${adKey}_$index',
              ),
            );
          } else {
            // Show regular item
            int originalIndex = _getOriginalIndex(index);
            return itemBuilder(context, originalIndex);
          }
        },
        separatorBuilder: (context, index) =>
            const SizedBox(width: AppSize.s10),
      ),
    );
  }
}
