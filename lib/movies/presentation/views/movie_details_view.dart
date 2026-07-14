import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../../../core/domain/entities/media.dart';
import '../../../core/domain/entities/media_details.dart';
import '../../../core/presentation/components/error_screen.dart';
import '../../../core/presentation/components/loading_indicator.dart';
import '../../../core/presentation/components/web_navbar.dart';
import '../../../core/resources/app_routes.dart';
import '../../../core/services/service_locator.dart';
import '../../../core/utils/enums.dart';
import '../../../watchlist/presentation/controllers/watchlist_bloc/watchlist_bloc.dart';
import '../../domain/entities/cast.dart';
import '../../domain/entities/review.dart';
import '../components/cast_card.dart';
import '../components/review_card.dart';
import '../components/trailer_widget.dart';
import '../controllers/movie_details_bloc/movie_details_bloc.dart';
import '../controllers/movies_bloc/movies_bloc.dart';

/// Responsive web layout for a single movie's detail page.
/// Breakpoints: >=1100 desktop, >=700 tablet, below that phone-width-in-browser.
class WebMovieDetailsView extends StatefulWidget {
  final int movieId;

  const WebMovieDetailsView({super.key, required this.movieId});

  @override
  State<WebMovieDetailsView> createState() => _WebMovieDetailsViewState();
}

class _WebMovieDetailsViewState extends State<WebMovieDetailsView> {
  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) return const SizedBox.shrink();

    return BlocProvider(
      create: (context) =>
      sl<MovieDetailsBloc>()..add(GetMovieDetailsEvent(widget.movieId)),
      child: Scaffold(
        backgroundColor: const Color(0xFF141414),
        body: BlocBuilder<MovieDetailsBloc, MovieDetailsState>(
          builder: (context, state) {
            switch (state.status) {
              case RequestStatus.loading:
                return const LoadingIndicator();
              case RequestStatus.loaded:
                return _WebMovieDetailsContent(movieDetails: state.movieDetails!);
              case RequestStatus.error:
                return ErrorScreen(
                  onTryAgainPressed: () {
                    context
                        .read<MovieDetailsBloc>()
                        .add(GetMovieDetailsEvent(widget.movieId));
                  },
                );
            }
          },
        ),
      ),
    );
  }
}

class _WebMovieDetailsContent extends StatefulWidget {
  final MediaDetails movieDetails;

  const _WebMovieDetailsContent({required this.movieDetails});

  @override
  State<_WebMovieDetailsContent> createState() => _WebMovieDetailsContentState();
}

class _WebMovieDetailsContentState extends State<_WebMovieDetailsContent> {
  @override
  void initState() {
    super.initState();
    // Kick off the bookmark check once, after first frame, instead of on
    // every rebuild.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context
          .read<WatchlistBloc>()
          .add(CheckBookmarkEvent(tmdbId: widget.movieDetails.tmdbID));
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final bool isDesktop = width >= 1100;
    final bool isTablet = width >= 700 && width < 1100;
    final double hPad = isDesktop ? 48 : (isTablet ? 32 : 20);

    final moviesBloc = context.read<MoviesBloc>();
    final topRatedMovies = moviesBloc.state.status == RequestStatus.loaded
        ? moviesBloc.state.movies[2]
        : <Media>[];

    return Stack(
      children: [
        SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHero(context, isDesktop, isTablet, hPad),
              _buildTrailerSection(isDesktop, hPad),
              const SizedBox(height: 8),
              _buildCastSection(hPad),
              _buildReviewsSection(hPad),
              _buildPosterRow(
                context,
                title: 'Similar',
                movies: (widget.movieDetails.similar != null &&
                    widget.movieDetails.similar!.isNotEmpty)
                    ? widget.movieDetails.similar!
                    : topRatedMovies,
                hPad: hPad,
              ),
              _buildPosterRow(
                context,
                title: 'Most Viewed',
                movies: topRatedMovies,
                hPad: hPad,
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
        const Positioned(top: 0, left: 0, right: 0, child: WebNavbar()),
        Positioned(
          top: 88,
          left: hPad,
          child: _buildBackButton(context),
        ),
      ],
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/movies');
          }
        },
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.25)),
          ),
          child: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
        ),
      ),
    );
  }

  Widget _buildHero(
      BuildContext context,
      bool isDesktop,
      bool isTablet,
      double hPad,
      ) {
    final movieDetails = widget.movieDetails;
    final double heroHeight = isDesktop ? 620 : (isTablet ? 560 : 640);
    final double posterWidth = isDesktop ? 220 : (isTablet ? 180 : 140);
    final double posterHeight = posterWidth * 1.5;

    final poster = ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.network(
        movieDetails.posterUrl,
        width: posterWidth,
        height: posterHeight,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          width: posterWidth,
          height: posterHeight,
          color: const Color(0xFF1F1F1F),
          child: const Icon(Icons.movie, color: Color(0xFF404040), size: 40),
        ),
      ),
    );

    final info = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          movieDetails.title.toUpperCase(),
          style: GoogleFonts.inter(
            fontSize: isDesktop ? 44 : (isTablet ? 34 : 26),
            fontWeight: FontWeight.w800,
            color: Colors.white,
            height: 1.1,
          ),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            _buildRatingChip('U/A 16+'),
            const SizedBox(width: 12),
            const Icon(Icons.star_rate_rounded, color: Colors.amber, size: 18),
            const SizedBox(width: 4),
            Text(
              movieDetails.voteAverage.toStringAsFixed(1),
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: isDesktop ? 640 : double.infinity),
          child: Text(
            movieDetails.overview,
            style: GoogleFonts.inter(
              fontSize: isDesktop ? 15 : 13,
              fontWeight: FontWeight.w400,
              color: const Color(0xFFD1D5DB),
              height: 1.5,
            ),
            maxLines: isDesktop ? 5 : 6,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildPlayButton(),
            _buildWatchlistButton(context, movieDetails),
          ],
        ),
      ],
    );

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: heroHeight),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(movieDetails.backdropUrl),
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
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
                  Colors.black.withOpacity(0.65),
                  Colors.black.withOpacity(0.35),
                  const Color(0xFF141414).withOpacity(0.85),
                  const Color(0xFF141414),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: hPad, right: hPad, top: 150, bottom: 40),
            child: isDesktop || isTablet
                ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                poster,
                const SizedBox(width: 32),
                Expanded(child: info),
              ],
            )
                : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: poster),
                const SizedBox(height: 20),
                info,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingChip(String rating) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFE50914),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        rating,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildPlayButton() {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          // Handle play
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFE50914), Color(0xFFB81D24)],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.play_arrow, color: Colors.white, size: 24),
              const SizedBox(width: 8),
              Text(
                'Play',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWatchlistButton(BuildContext context, MediaDetails movieDetails) {
    return BlocConsumer<WatchlistBloc, WatchlistState>(
      listener: (context, state) {
        final action = state.actionStatus;
        if (action == BookmarkStatus.added) {
          movieDetails.id = state.id;
          movieDetails.isBookmarked = true;
        } else if (action == BookmarkStatus.removed) {
          movieDetails.id = null;
          movieDetails.isBookmarked = false;
        } else if (action == BookmarkStatus.exists && state.id != -1) {
          movieDetails.id = state.id;
          movieDetails.isBookmarked = true;
        }
      },
      builder: (context, state) {
        final bool isBookmarked = movieDetails.isBookmarked;
        return MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () {
              isBookmarked
                  ? context
                  .read<WatchlistBloc>()
                  .add(RemoveWatchListItemEvent(movieDetails.id!))
                  : context.read<WatchlistBloc>().add(
                AddWatchListItemEvent(
                  media: Media.fromMediaDetails(movieDetails),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isBookmarked ? 'In My List' : 'My List',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTrailerSection(bool isDesktop, double hPad) {
    final trailerUrl = widget.movieDetails.trailerUrl;
    if (trailerUrl.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 28),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: isDesktop ? 960 : double.infinity),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: TrailerWidget(trailerUrl: trailerUrl),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, double hPad) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad),
      child: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildCastSection(double hPad) {
    final List<Cast>? cast = widget.movieDetails.cast;
    if (cast == null || cast.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Cast', hPad),
          const SizedBox(height: 16),
          SizedBox(
            height: 175,
            child: ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: hPad),
              scrollDirection: Axis.horizontal,
              itemCount: cast.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) => CastCard(cast: cast[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsSection(double hPad) {
    final List<Review>? reviews = widget.movieDetails.reviews;
    if (reviews == null || reviews.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Reviews', hPad),
          const SizedBox(height: 16),
          SizedBox(
            height: 175,
            child: ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: hPad),
              scrollDirection: Axis.horizontal,
              itemCount: reviews.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) => ReviewCard(review: reviews[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPosterRow(
      BuildContext context, {
        required String title,
        required List<Media> movies,
        required double hPad,
      }) {
    if (movies.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(title, hPad),
          const SizedBox(height: 16),
          SizedBox(
            height: 280,
            child: ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: hPad),
              scrollDirection: Axis.horizontal,
              itemCount: movies.length,
              separatorBuilder: (_, __) => const SizedBox(width: 16),
              itemBuilder: (context, index) => _buildPosterCard(context, movies[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPosterCard(BuildContext context, Media media) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          // Push so the browser/back button returns to this details page.
          context.pushNamed(
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
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: const Color(0xFF1F1F1F),
                      child: const Center(
                        child: Icon(Icons.movie, color: Color(0xFF404040), size: 48),
                      ),
                    ),
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
                          Colors.transparent,
                          Color(0x66000F3D),
                          Color(0xCC001B5E),
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
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.star_rate_rounded, color: Colors.amber, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              media.voteAverage.toStringAsFixed(1),
                              style: GoogleFonts.inter(
                                color: Colors.white,
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
        ),
      ),
    );
  }
}