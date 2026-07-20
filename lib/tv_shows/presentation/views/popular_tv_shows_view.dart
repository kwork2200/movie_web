import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/domain/entities/media.dart';
import '../../../core/presentation/components/ads/hybrid_native_ad_widget.dart';
import '../../../core/presentation/components/custom_app_bar.dart';
import '../../../core/presentation/components/error_screen.dart';
import '../../../core/presentation/components/loading_indicator.dart';
import '../../../core/presentation/components/vertical_listview.dart';
import '../../../core/presentation/components/vertical_listview_card.dart';
import '../../../core/presentation/components/banner_ad_widget.dart';
import '../../../core/resources/app_colors.dart';
import '../../../core/resources/app_strings.dart';
import '../../../core/services/service_locator.dart';
import '../../../core/utils/enums.dart';
import '../controllers/popular_tv_shows_bloc/popular_tv_shows_bloc.dart';
import '../../../core/presentation/components/ads/ad_enabled_screen.dart';

/// ---------------------------------------------------------------------
/// Responsive breakpoints for the grid.
/// ---------------------------------------------------------------------
class _Breakpoints {
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1300;
  static const double largeDesktop = 1700;

  static bool isWide(double width) => width >= tablet;

  static int gridColumns(double width) {
    if (width >= largeDesktop) return 7;
    if (width >= desktop) return 6;
    if (width >= tablet) return 4;
    return 3;
  }

  static double horizontalPadding(double width) {
    if (width >= desktop) return 48;
    if (width >= tablet) return 32;
    return 16;
  }

  static double contentMaxWidth(double width) {
    if (width >= largeDesktop) return 1800;
    return width;
  }
}

class PopularTVShowsView extends StatelessWidget {
  const PopularTVShowsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<PopularTVShowsBloc>()..add(GetPopularTVShowsEvent()),
      child: Scaffold(
        backgroundColor: AppNetflixThemeColor.background,
        appBar:  CustomAppBar(

          title: AppStrings.popularShows,
        ),
        body: BlocBuilder<PopularTVShowsBloc, PopularTVShowsState>(
          builder: (context, state) {
            switch (state.status) {
              case GetAllRequestStatus.loading:
                return const LoadingIndicator();
              case GetAllRequestStatus.loaded:
                return PopularTVShowsWidget(tvShows: state.tvShows);
              case GetAllRequestStatus.error:
                return ErrorScreen(
                  onTryAgainPressed: () {
                    context.read<PopularTVShowsBloc>().add(GetPopularTVShowsEvent());
                  },
                );
              case GetAllRequestStatus.fetchMoreError:
                return PopularTVShowsWidget(tvShows: state.tvShows);
            }
          },
        ),
      ),
    );
  }
}

class PopularTVShowsWidget extends StatelessWidget {
  const PopularTVShowsWidget({
    super.key,
    required this.tvShows,
  });

  final List<Media> tvShows;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final wide = _Breakpoints.isWide(width);

        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.alphaBlend(AppNetflixThemeColor.deepOrange.withOpacity(0.06), AppNetflixThemeColor.background),
                AppNetflixThemeColor.background,    ],
              stops: const [0.0, 0.35],
            ),
          ),
          child: Column(
            children: [
              // const HybridNativeAdWidget(adKey: 'popular_tv_shows'),
              _HeaderBanner(count: tvShows.length, width: width),
              Expanded(
                  child: _WidePopularGrid(tvShows: tvShows, width: width)
              ),
            ],
          ),
        );
      },
    );
  }
}

/// ---------------------------------------------------------------------
/// Eye-catching gradient banner header replacing the plain text row.
/// ---------------------------------------------------------------------
class _HeaderBanner extends StatelessWidget {
  const _HeaderBanner({required this.count, required this.width});

  final int count;
  final double width;

  @override
  Widget build(BuildContext context) {
    final hPad = _Breakpoints.horizontalPadding(width);

    return Padding(
      padding: EdgeInsets.fromLTRB(hPad, 18, hPad, 14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppNetflixThemeColor.tvOrangeStart, AppNetflixThemeColor.tvOrangeEnd],          ),
          boxShadow: [
            BoxShadow(
              color: AppNetflixThemeColor.deepOrange.withOpacity(0.35),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.local_fire_department_rounded, color: Colors.white, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Popular Shows',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$count shows trending right now',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.85),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------
/// Grid used on wide (laptop/desktop web) screens, with its own
/// pagination listener, hover lift, staggered entrance, and a
/// scroll-to-top button once the user scrolls down.
/// ---------------------------------------------------------------------
class _WidePopularGrid extends StatefulWidget {
  const _WidePopularGrid({required this.tvShows, required this.width});

  final List<Media> tvShows;
  final double width;

  @override
  State<_WidePopularGrid> createState() => _WidePopularGridState();
}

class _WidePopularGridState extends State<_WidePopularGrid> {
  final ScrollController _controller = ScrollController();
  bool _requestedMore = false;
  bool _showScrollTop = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(covariant _WidePopularGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tvShows.length != widget.tvShows.length) {
      _requestedMore = false;
    }
  }

  void _onScroll() {
    if (!_controller.hasClients) return;

    final shouldShow = _controller.position.pixels > 480;
    if (shouldShow != _showScrollTop) {
      setState(() => _showScrollTop = shouldShow);
    }

    if (_requestedMore) return;
    final threshold = _controller.position.maxScrollExtent - 400;
    if (_controller.position.pixels >= threshold) {
      _requestedMore = true;
      context.read<PopularTVShowsBloc>().add(FetchMorePopularTVShowsEvent());
    }
  }

  void _scrollToTop() {
    _controller.animateTo(0, duration: const Duration(milliseconds: 400), curve: Curves.easeOutCubic);
  }

  @override
  void dispose() {
    _controller.removeListener(_onScroll);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hPad = _Breakpoints.horizontalPadding(widget.width);
    final columns = _Breakpoints.gridColumns(widget.width);
    final maxContentWidth = _Breakpoints.contentMaxWidth(widget.width);

    final List<Widget> gridItems = [];
    for (int i = 0; i < widget.tvShows.length; i++) {
      gridItems.add(_StaggeredEntrance(index: i, child: _HoverCard(child: VerticalListViewCard(media: widget.tvShows[i])),),
      );

      if ((i + 1) % 2 == 0 && i < widget.tvShows.length - 1) {
        gridItems.add(Center(child: BannerAdWidget(width: 160, height: 300, adKey: '16bd2bc289ee2531871e1be42c1d1c9b${i ~/ 2}'),),
        );
      }
    }

    return Stack(
      children: [
        Scrollbar(
          controller: _controller,
          thumbVisibility: true,
          child: SingleChildScrollView(
            controller: _controller,
            physics: const BouncingScrollPhysics(),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxContentWidth),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(hPad, 4, hPad, 32),
                  child: Column(
                    children: [
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: gridItems.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          mainAxisSpacing: 22,
                          crossAxisSpacing: 20,
                          childAspectRatio: 0.7,
                        ),
                        itemBuilder: (context, index) => gridItems[index],
                      ),
                      const SizedBox(height: 24),
                      const LoadingIndicator(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        // Floating scroll-to-top button (web/desktop touch).
        Positioned(
          right: 24,
          bottom: 24,
          child: AnimatedSlide(
            offset: _showScrollTop ? Offset.zero : const Offset(0, 2),
            duration: const Duration(milliseconds: 200),
            child: AnimatedOpacity(
              opacity: _showScrollTop ? 1 : 0,
              duration: const Duration(milliseconds: 200),
              child: IgnorePointer(
                ignoring: !_showScrollTop,
                child: FloatingActionButton(
                  heroTag: 'popular_scroll_top',
                  backgroundColor: AppNetflixThemeColor.tvOrangeEnd,onPressed: _scrollToTop,
                  child: const Icon(Icons.keyboard_arrow_up_rounded, color: AppNetflixThemeColor.white),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// ---------------------------------------------------------------------
/// Small fade + slide-up entrance, staggered by grid/list index, so
/// content doesn't just pop in — gives the page a "premium" feel.
/// ---------------------------------------------------------------------
class _StaggeredEntrance extends StatelessWidget {
  const _StaggeredEntrance({required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // Cap the delay so items far down the list don't wait forever.
    final delayMs = min(index, 20) * 40;

    return TweenAnimationBuilder<double>(
      key: ValueKey('stagger_$index'),
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 380 + delayMs),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 18),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

/// Subtle scale + shadow lift on hover for desktop/mouse users.
class _HoverCard extends StatefulWidget {
  const _HoverCard({required this.child});

  final Widget child;

  @override
  State<_HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<_HoverCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedScale(
        scale: _hovering ? 1.04 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: _hovering
                ? [
              BoxShadow(
                color: AppNetflixThemeColor.black.withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ]
                : [],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}