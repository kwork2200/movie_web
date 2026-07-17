import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/domain/entities/media.dart';
import '../../../core/presentation/components/ads/hybrid_native_ad_widget.dart';
import '../../../core/presentation/components/custom_slider.dart';
import '../../../core/presentation/components/error_screen.dart';

import '../../../core/presentation/components/loading_indicator.dart';
import '../../../core/presentation/components/section_header.dart';
import '../../../core/presentation/components/section_listview.dart';
import '../../../core/presentation/components/section_listview_with_ads.dart';
import '../../../core/presentation/components/section_listview_card.dart';
import '../../../core/presentation/components/slider_card.dart';
import '../../../core/resources/app_colors.dart';
import '../../../core/resources/app_routes.dart';
import '../../../core/resources/app_strings.dart';
import '../../../core/resources/app_values.dart';
import '../../../core/utils/enums.dart';
import '../controllers/tv_shows_bloc/tv_shows_bloc.dart';
import '../../../core/presentation/components/ads/ad_enabled_screen.dart';

class TVShowsView extends StatelessWidget {
  const TVShowsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<TVShowsBloc, TVShowsState>(
        builder: (context, state) {
          switch (state.status) {
            case RequestStatus.loading:
              return const LoadingIndicator();
            case RequestStatus.loaded:
              return TVShowsWidget(
                onAirTvShows: state.tvShows[0],
                popularTvShows: state.tvShows[1],
                topRatedTvShows: state.tvShows[2],
              );
            case RequestStatus.error:
              return ErrorScreen(
                onTryAgainPressed: () {
                  context.read<TVShowsBloc>().add(GetTVShowsEvent());
                },
              );
          }
        },
      ),
    );
  }
}

class TVShowsWidget extends StatelessWidget {
  const TVShowsWidget({
    super.key,
    required this.onAirTvShows,
    required this.popularTvShows,
    required this.topRatedTvShows,
  });

  final List<Media> onAirTvShows;
  final List<Media> popularTvShows;
  final List<Media> topRatedTvShows;

  @override
  Widget build(BuildContext context) {
    // Check if all lists are empty
    if (onAirTvShows.isEmpty && popularTvShows.isEmpty && topRatedTvShows.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(AppPadding.p16),
          child: Text(
            'No TV shows available at the moment',
            style: TextStyle(
              fontSize: 16,
              color: AppNetflixThemeColor.secondaryText,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          CustomSlider(
            items: onAirTvShows,
            itemBuilder: (context, itemIndex, _) {
              return SliderCard(
                media: onAirTvShows[itemIndex],
                itemIndex: itemIndex,
              );
            },
          ),
          // Native Ad after slider
          // HybridNativeAdWidget(adKey: 'tv_shows_home'),
          SectionHeader(
            title: AppStrings.popularShows,
            onSeeAllTap: () {
              context.goNamed(AppRoutes.popularTvShowsRoute);
            },
          ),
          SectionListViewWithAds(
            height: AppSize.s280,
            itemCount: popularTvShows.length,
            adKey: 'popular_tv_shows',
            adInterval: 2,
            itemBuilder: (context, index) {
              return SectionListViewCard(media: popularTvShows[index]);
            },
          ),
          SectionHeader(
            title: AppStrings.topRatedShows,
            onSeeAllTap: () {
              context.goNamed(AppRoutes.topRatedTvShowsRoute);
            },
          ),
          SectionListViewWithAds(
            height: AppSize.s280,
            itemCount: topRatedTvShows.length,
            adKey: 'top_rated_tv_shows',
            adInterval: 2,
            itemBuilder: (context, index) {
              return SectionListViewCard(media: topRatedTvShows[index]);
            },
          ),
          // HybridNativeAdWidget(height: AppSize.s175, adKey: 'tv_shows_home'),
          // Trending Section
          SectionHeader(
            title: 'Trending Now',
            onSeeAllTap: () {
              context.goNamed(AppRoutes.popularMoviesRoute);
            },
          ),
          SectionListViewWithAds(
            height: AppSize.s300,
            itemCount: popularTvShows.length,
            adKey: 'trending_tv_shows',
            adInterval: 2,
            itemBuilder: (context, index) {
              return SectionListViewCard(media: popularTvShows[index]);
            },
          ),
          SectionHeader(
            title: 'Upcoming Shows',
            onSeeAllTap: () {
              context.goNamed(AppRoutes.popularMoviesRoute);
            },
          ),
          SectionListViewWithAds(
            height: AppSize.s300,
            itemCount: topRatedTvShows.length,
            adKey: 'upcoming_tv_shows',
            adInterval: 2,
            itemBuilder: (context, index) {
              return SectionListViewCard(media: topRatedTvShows[index]);
            },
          ),
          // HybridNativeAdWidget(height: AppSize.s175, adKey: 'tv_shows_home'),
          // Action Section
          SectionHeader(
            title: 'Action & Adventure',
            onSeeAllTap: () {
              context.goNamed(AppRoutes.topRatedMoviesRoute);
            },
          ),
          SectionListViewWithAds(
            height: AppSize.s300,
            itemCount: popularTvShows.length,
            adKey: 'action_tv_shows',
            adInterval: 2,
            itemBuilder: (context, index) {
              return SectionListViewCard(media: popularTvShows[index]);
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
