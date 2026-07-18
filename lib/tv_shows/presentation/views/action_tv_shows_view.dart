import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/domain/entities/media.dart';
import '../../../core/presentation/components/custom_app_bar.dart';
import '../../../core/presentation/components/error_screen.dart';
import '../../../core/presentation/components/loading_indicator.dart';
import '../../../core/presentation/components/vertical_listview.dart';
import '../../../core/presentation/components/vertical_listview_card.dart';
import '../../../core/resources/app_colors.dart';
import '../../../core/resources/app_strings.dart';
import '../../../core/resources/app_constants.dart';
import '../../../core/services/service_locator.dart';
import '../../../core/utils/enums.dart';
import '../controllers/top_rated_tv_shows_bloc/top_rated_tv_shows_bloc.dart';

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

class ActionTVShowsView extends StatefulWidget {
  const ActionTVShowsView({super.key});

  @override
  State<ActionTVShowsView> createState() => _ActionTVShowsViewState();
}

class _ActionTVShowsViewState extends State<ActionTVShowsView> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        AppConstants.showPopupAdBanner(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<TopRatedTVShowsBloc>()..add(GetTopRatedTVShowsEvent()),
      child: Scaffold(
        backgroundColor: AppNetflixThemeColor.background,
        // appBar: const CustomAppBar(
        //   title: 'Action & Adventure',
        // ),
        body: BlocBuilder<TopRatedTVShowsBloc, TopRatedTVShowsState>(
          builder: (context, state) {
            switch (state.status) {
              case GetAllRequestStatus.loading:
                return const LoadingIndicator();
              case GetAllRequestStatus.loaded:
                return ActionTVShowsWidget(tvShows: state.tvShows);
              case GetAllRequestStatus.error:
                return ErrorScreen(
                  onTryAgainPressed: () {
                    context.read<TopRatedTVShowsBloc>().add(GetTopRatedTVShowsEvent());
                  },
                );
              case GetAllRequestStatus.fetchMoreError:
                return ActionTVShowsWidget(tvShows: state.tvShows);
            }
          },
        ),
      ),
    );
  }
}

class ActionTVShowsWidget extends StatelessWidget {
  const ActionTVShowsWidget({
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
                AppNetflixThemeColor.background,
              ],
              stops: const [0.0, 0.35],
            ),
          ),
          child: Column(
            children: [
              _HeaderBanner(count: tvShows.length, width: width),
              Expanded(
                child: wide
                    ? _WideActionGrid(tvShows: tvShows, width: width)
                    : _MobileActionList(tvShows: tvShows),
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
            colors: [AppNetflixThemeColor.tvOrangeStart, AppNetflixThemeColor.tvOrangeEnd],
          ),
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
                color: AppNetflixThemeColor.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.flash_on_rounded, color: AppNetflixThemeColor.white, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Action & Adventure',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppNetflixThemeColor.white,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$count action-packed shows',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      color: AppNetflixThemeColor.white.withOpacity(0.85),
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
/// Mobile list — same VerticalListView/pagination as before, just the
/// cards fade+slide in for a bit of polish.
/// ---------------------------------------------------------------------
class _MobileActionList extends StatelessWidget {
  const _MobileActionList({required this.tvShows});

  final List<Media> tvShows;

  @override
  Widget build(BuildContext context) {
    return VerticalListView(
      itemCount: tvShows.length + 1,
      itemBuilder: (context, index) {
        if (index < tvShows.length) {
          return _StaggeredEntrance(
            index: index,
            child: VerticalListViewCard(media: tvShows[index]),
          );
        } else {
          return const LoadingIndicator();
        }
      },
      addEvent: () {
        context.read<TopRatedTVShowsBloc>().add(FetchMoreTopRatedTVShowsEvent());
      },
    );
  }
}

/// ---------------------------------------------------------------------
/// Grid used on wide (laptop/desktop web) screens, with its own
/// pagination listener, hover lift, staggered entrance, and a
/// scroll-to-top button once the user scrolls down.
/// ---------------------------------------------------------------------
class _WideActionGrid extends StatefulWidget {
  const _WideActionGrid({required this.tvShows, required this.width});

  final List<Media> tvShows;
  final double width;

  @override
  State<_WideActionGrid> createState() => _WideActionGridState();
}

class _WideActionGridState extends State<_WideActionGrid> {
  final ScrollController _controller = ScrollController();
  bool _requestedMore = false;
  bool _showScrollTop = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(covariant _WideActionGrid oldWidget) {
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
      context.read<TopRatedTVShowsBloc>().add(FetchMoreTopRatedTVShowsEvent());
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
                        itemCount: widget.tvShows.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          mainAxisSpacing: 22,
                          crossAxisSpacing: 20,
                          childAspectRatio: 0.6,
                        ),
                        itemBuilder: (context, index) {
                          return _StaggeredEntrance(
                            index: index,
                            child: _HoverCard(
                              child: VerticalListViewCard(media: widget.tvShows[index]),
                            ),
                          );
                        },
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
                  heroTag: 'action_scroll_top',
                  backgroundColor: AppNetflixThemeColor.tvOrangeEnd,
                  onPressed: _scrollToTop,
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
