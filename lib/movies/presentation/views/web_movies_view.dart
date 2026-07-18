import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:movie_web/core/presentation/widget/custom_banner_card.dart';

import '../../../core/domain/entities/media.dart';
import '../../../core/resources/app_colors.dart';
import '../../../core/presentation/components/custom_slider.dart';
import '../../../core/presentation/components/error_screen.dart';
import '../../../core/presentation/components/loading_indicator.dart';
import '../../../core/presentation/components/section_header.dart';
import '../../../core/presentation/components/section_listview.dart';
import '../../../core/presentation/components/banner_ad_widget.dart';
import '../../../core/presentation/components/section_listview_card.dart';
import '../../../core/presentation/components/slider_card.dart';
import '../../../core/presentation/components/web_navbar.dart';
import '../../../core/resources/app_constants.dart';
import '../../../core/resources/app_routes.dart';
import '../../../core/resources/app_strings.dart';
import '../../../core/resources/app_values.dart';
import '../../../core/utils/enums.dart';
import '../controllers/movies_bloc/movies_bloc.dart';
import '../controllers/movies_bloc/movies_event.dart';
import '../controllers/movies_bloc/movies_state.dart';
import '../../../core/presentation/components/ads/ad_enabled_screen.dart';
import '../../../core/presentation/components/ads/hybrid_native_ad_widget.dart';

class WebMoviesView extends StatefulWidget {
  const WebMoviesView({super.key});

  @override
  State<WebMoviesView> createState() => _WebMoviesViewState();
}

class _WebMoviesViewState extends State<WebMoviesView> {

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) {
      // Fallback to mobile view if not on web
      return const SizedBox.shrink();
    }

    // NOTE: Bottom navigation bar removed. Its items (Movies, Shows, Search,
    // Watchlist) have been merged into WebNavbar (top). If you still have a
    // separate bottom-nav-bearing shell/scaffold wrapping this page (the one
    // visible at the bottom of the screenshot), remove the bottomNavigationBar
    // usage there too — it isn't part of this file.
    return Scaffold(
      backgroundColor: AppNetflixThemeColor.darkWebBackground,
      body: BlocBuilder<MoviesBloc, MoviesState>(
        builder: (context, state) {
          switch (state.status) {
            case RequestStatus.loading:
              return const LoadingIndicator();
            case RequestStatus.loaded:
            // Stack: scrollable content underneath, navbar floats on top
            // (transparent/gradient) over the hero image.
              return Stack(
                children: [
                  WebMoviesWidget(
                    nowPlayingMovies: state.movies[0],
                    popularMovies: state.movies[1],
                    topRatedMovies: state.movies[2],
                  ),
                  const Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: WebNavbar(),
                  ),
                ],
              );
            case RequestStatus.error:
              return ErrorScreen(
                onTryAgainPressed: () {
                  context.read<MoviesBloc>().add(GetMoviesEvent());
                },
              );
          }
        },
      ),
    );
  }
}

class WebMoviesWidget extends StatefulWidget {
  final List<Media> nowPlayingMovies;
  final List<Media> popularMovies;
  final List<Media> topRatedMovies;

  const WebMoviesWidget({
    super.key,
    required this.nowPlayingMovies,
    required this.popularMovies,
    required this.topRatedMovies,
  });

  @override
  State<WebMoviesWidget> createState() => _WebMoviesWidgetState();
}

class _WebMoviesWidgetState extends State<WebMoviesWidget> {
  int _currentHeroIndex = 0;
  Timer? _heroAutoSlideTimer;
  final PageController _heroPageController = PageController();
  final Map<String, ScrollController> _rowControllers = {};
  ScrollController _controllerFor(String key) {
    return _rowControllers.putIfAbsent(key, () => ScrollController());
  }

  void _scrollRow(String key, {required bool forward}) {
    final controller = _rowControllers[key];
    if (controller == null || !controller.hasClients) return;
    const double delta = 600;
    final target = forward
        ? (controller.offset + delta).clamp(0.0, controller.position.maxScrollExtent)
        : (controller.offset - delta).clamp(0.0, controller.position.maxScrollExtent);
    controller.animateTo(
      target,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
    );
  }


  @override
  void initState() {
    super.initState();
    _startAutoSlide();
  }

  // Auto-advances by animating the PageView (proper sliding transition),
  // same idea as the TV Shows CustomSlider.
  void _startAutoSlide() {
    _heroAutoSlideTimer?.cancel();
    if (widget.nowPlayingMovies.length <= 1) return;
    _heroAutoSlideTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || !_heroPageController.hasClients) return;
      final int next = (_currentHeroIndex + 1) % widget.nowPlayingMovies.length;
      _heroPageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void didUpdateWidget(covariant WebMoviesWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.nowPlayingMovies.length != widget.nowPlayingMovies.length) {
      _currentHeroIndex = 0;
      if (_heroPageController.hasClients) {
        _heroPageController.jumpToPage(0);
      }
      _startAutoSlide();
    }
  }

  @override
  void dispose() {
    _heroAutoSlideTimer?.cancel();
    _heroPageController.dispose();
    for (final c in _rowControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.nowPlayingMovies.isEmpty && widget.popularMovies.isEmpty && widget.topRatedMovies.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppPadding.p16),
          child: Text(
            'No movies available at the moment',
            style: GoogleFonts.inter(
              fontSize: 16,
              color: AppNetflixThemeColor.mutedText,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeroSection(),
          const SizedBox(height: 32),
          _buildMovieRow('Trending Now', widget.popularMovies, context),
          const SizedBox(height: 32),
          _buildMovieRow('Top Rated', widget.topRatedMovies, context),
          const SizedBox(height: 32),
          _buildMovieRow('Now Playing', widget.nowPlayingMovies, context),
          const SizedBox(height: 32),
          _buildMovieRow('Popular Movies', widget.popularMovies, context),
          const SizedBox(height: 32),
          _buildMovieRow('Upcoming', widget.nowPlayingMovies, context),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    if (widget.nowPlayingMovies.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      width: double.infinity,
      height: 650,
      child: Stack(
        children: [
          // PageView gives proper sliding motion between slides, like the
          // TV Shows CustomSlider, instead of just swapping the image.
          PageView.builder(
            controller: _heroPageController,
            itemCount: widget.nowPlayingMovies.length,
            onPageChanged: (index) {
              setState(() => _currentHeroIndex = index);
            },
            itemBuilder: (context, index) {
              return _buildHeroSlide(widget.nowPlayingMovies[index]);
            },
          ),
          Positioned(
            left: 48,
            bottom: 60,
            child: _buildCarouselIndicators(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSlide(Media featuredMovie) {
    return Container(
      width: double.infinity,
      height: 650,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(featuredMovie.backdropUrl),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppNetflixThemeColor.black.withOpacity(0.55),
                  AppNetflixThemeColor.transparent,
                  AppNetflixThemeColor.darkWebBackground.withOpacity(0.7),
                  AppNetflixThemeColor.darkWebBackground,
                ],
              ),
            ),
          ),
          // Tapping the poster/backdrop itself opens the detail view.
          // Stops short of the bottom button row so Play/More Info/My List
          // keep working normally without also triggering this.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 170,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () => _openMovieDetails(featuredMovie),
            ),
          ),
          Padding(
            // Extra top padding so the title/content clears the floating navbar.
            // Extra bottom padding leaves room for the indicators overlay.
            padding: const EdgeInsets.only(left: 48, right: 48, top: 110, bottom: 100),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  featuredMovie.title.toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 52,
                    fontWeight: FontWeight.w800,
                    color: AppNetflixThemeColor.white,
                    height: 1.1,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                _buildRatingChip('U/A 16+'),
                const SizedBox(height: 12),
                Text(
                  'Korean Drama, Romance, Melodrama',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppNetflixThemeColor.mutedTextWeb,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: 600,
                  child: Text(
                    'A nine-tailed fox hunts monsters while seeking his lost love - until a producer and his vengeful brother spark chaos.',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: AppNetflixThemeColor.lightTextWeb,
                      height: 1.5,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    _buildPlayButton(),
                    const SizedBox(width: 12),
                    _buildMoreInfoButton(featuredMovie),
                    /*const SizedBox(width: 12),
                    _buildAddToListButton(),*/
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Shared navigation used by both the poster tap and the More Info button.
  void _openMovieDetails(Media media) async{
    await AppConstants.openSmartLink();
    context.goNamed(
      AppRoutes.movieDetailsRoute,
      pathParameters: {'movieId': media.tmdbID.toString()},
    );
  }

  Widget _buildRatingChip(String rating) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppNetflixThemeColor.netflixRed,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          rating,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppNetflixThemeColor.white,
          ),
        ));
  }

  Widget _buildCarouselIndicators() {
    return Row(
      children: List.generate(
        widget.nowPlayingMovies.length > 5 ? 5 : widget.nowPlayingMovies.length,
            (index) {
          return GestureDetector(
            onTap: () {
              _heroPageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
              );
              _startAutoSlide(); // reset the timer on manual tap
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              width: _currentHeroIndex == index ? 32 : 8,
              height: 8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: _currentHeroIndex == index
                    ? AppNetflixThemeColor.white
                    : AppNetflixThemeColor.white.withOpacity(0.4),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPlayButton() {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () async{
          await AppConstants.openSmartLink();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppNetflixThemeColor.netflixRed, AppNetflixThemeColor.netflixRedDark],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Icon(Icons.play_arrow, color: AppNetflixThemeColor.white, size: 24),
              const SizedBox(width: 8),
              Text(
                'Play',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppNetflixThemeColor.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMoreInfoButton(Media featuredMovie) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _openMovieDetails(featuredMovie),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          decoration: BoxDecoration(
            color: AppNetflixThemeColor.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppNetflixThemeColor.white.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: AppNetflixThemeColor.white, size: 20),
              const SizedBox(width: 6),
              Text(
                'More Info',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppNetflixThemeColor.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddToListButton() {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          // Handle add to list
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          decoration: BoxDecoration(
            color: AppNetflixThemeColor.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppNetflixThemeColor.white.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.add, color: AppNetflixThemeColor.white, size: 20),
              const SizedBox(width: 6),
              Text(
                'My List',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppNetflixThemeColor.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMovieRow(String title, List<Media> movies, BuildContext context) {
    if (movies.isEmpty) return const SizedBox.shrink();
    final controller = _controllerFor(title);
    final rowItems = _buildRowItemsWithBanner(movies);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48),
          child: Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppNetflixThemeColor.white,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 280,
          child: Stack(
            children: [
              ListView.separated(
                controller: controller,
                padding: const EdgeInsets.symmetric(horizontal: 48),
                scrollDirection: Axis.horizontal,
                itemCount: rowItems.length,  /// itemCount: movies.length,
                separatorBuilder: (_, __) => const SizedBox(width: 16),
                itemBuilder: (context, index) => rowItems[index],
                // itemBuilder: (context, index) {
                //   return _buildWebMovieCard(movies[index]);
                // },
              ),
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: _buildScrollArrow(
                  icon: Icons.chevron_left,
                  onTap: () => _scrollRow(title, forward: false),
                ),
              ),
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                child: _buildScrollArrow(
                  icon: Icons.chevron_right,
                  onTap: () => _scrollRow(title, forward: true),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildRowItemsWithBanner(List<Media> movies) {
    final List<Widget> items = [];
    for (int i = 0; i < movies.length; i++) {
      items.add(_buildWebMovieCard(movies[i]));
      if ((i + 1) % 2 == 0) { items.add(CustomBannerCard(height: 280, width: 200));
      }
    }
    return items;
  }

  Widget _buildScrollArrow({required IconData icon, required VoidCallback onTap}) {
    final bool isLeft = icon == Icons.chevron_left;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 64,
          decoration: BoxDecoration(
          ),
          alignment: isLeft ? Alignment.centerLeft : Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppNetflixThemeColor.black.withOpacity(0.6),
                shape: BoxShape.circle,
                border: Border.all(color: AppNetflixThemeColor.white.withOpacity(0.15)),
              ),
              child: Icon(icon, color: AppNetflixThemeColor.white, size: 22),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWebMovieCard(Media media) {
    final languages = _getLanguagesForMovie(media);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
          onTap: () async {
            await AppConstants.openSmartLink();
            context.goNamed(
              AppRoutes.movieDetailsRoute,
              pathParameters: {'movieId': media.tmdbID.toString()},
            );
          },
          child: SizedBox(
            width: 200,
            height: 280,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.network(
                      media.posterUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppNetflixThemeColor.errorBackground,
                          child: const Center(
                            child: Icon(
                              Icons.movie,
                              color: AppNetflixThemeColor.errorIcon,
                              size: 48,
                            ),
                          ),
                        );
                      },
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
                            AppNetflixThemeColor.gradientStart,
                            AppNetflixThemeColor.gradientEnd,
                          ],
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            media.title.toUpperCase(),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              color: AppNetflixThemeColor.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            languages,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              color: AppNetflixThemeColor.white70,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.star_rate_rounded,
                                color: AppNetflixThemeColor.amber,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                media.voteAverage.toStringAsFixed(1),
                                style: GoogleFonts.inter(
                                  color: AppNetflixThemeColor.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
      ),
    );
  }

  String _getLanguagesForMovie(Media media) {
    // Simulate language info based on movie index
    final index = media.tmdbID % 4;
    switch (index) {
      case 0:
        return 'HINDI | TAMIL | TELUGU';
      case 1:
        return 'HINDI | TAMIL | TELUGU | MANDARIN';
      case 2:
        return 'KOREAN | ENGLISH';
      case 3:
        return 'HINDI | ENGLISH';
      default:
        return 'MULTI LANGUAGE';
    }
  }
}