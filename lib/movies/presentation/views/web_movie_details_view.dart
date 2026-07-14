import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../../core/domain/entities/media.dart';
import '../../../core/domain/entities/media_details.dart';
import '../../../core/presentation/components/error_screen.dart';
import '../../../core/presentation/components/loading_indicator.dart';
import '../../../core/presentation/components/web_navbar.dart';
import '../../../core/resources/app_values.dart';
import '../../../core/services/service_locator.dart';
import '../../../core/utils/enums.dart';
import '../../../core/utils/functions.dart';
import '../../domain/entities/cast.dart';
import '../../domain/entities/review.dart';
import '../controllers/movie_details_bloc/movie_details_bloc.dart';
import '../controllers/movies_bloc/movies_bloc.dart';
import '../../../watchlist/presentation/controllers/watchlist_bloc/watchlist_bloc.dart';
import '../../../core/presentation/components/ads/ad_enabled_screen.dart';

class WebMovieDetailsView extends StatefulWidget {
  final int movieId;

  const WebMovieDetailsView({
    super.key,
    required this.movieId,
  });

  @override
  State<WebMovieDetailsView> createState() => _WebMovieDetailsViewState();
}

class _WebMovieDetailsViewState extends State<WebMovieDetailsView> {
  YoutubePlayerController? _youtubeController;

  @override
  void dispose() {
    _youtubeController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) {
      return const SizedBox.shrink();
    }

    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      body: Column(
        children: [
          const WebNavbar(),
          Expanded(
            child: BlocProvider(
              create: (context) =>
              sl<MovieDetailsBloc>()..add(GetMovieDetailsEvent(widget.movieId)),
              child: BlocBuilder<MovieDetailsBloc, MovieDetailsState>(
                builder: (context, state) {
                  switch (state.status) {
                    case RequestStatus.loading:
                      return const LoadingIndicator();
                    case RequestStatus.loaded:
                      return WebMovieDetailsWidget(movieDetails: state.movieDetails!);
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
          ),
        ],
      ),
    );
  }
}

class WebMovieDetailsWidget extends StatefulWidget {
  final MediaDetails movieDetails;

  const WebMovieDetailsWidget({
    super.key,
    required this.movieDetails,
  });

  @override
  State<WebMovieDetailsWidget> createState() => _WebMovieDetailsWidgetState();
}

class _WebMovieDetailsWidgetState extends State<WebMovieDetailsWidget> {
  YoutubePlayerController? _youtubeController;

  @override
  void initState() {
    super.initState();
    _initializeYoutubePlayer();
  }

  void _initializeYoutubePlayer() {
    if (widget.movieDetails.trailerUrl.isNotEmpty) {
      final videoId = YoutubePlayer.convertUrlToId(widget.movieDetails.trailerUrl);
      if (videoId != null) {
        _youtubeController = YoutubePlayerController(
          initialVideoId: videoId,
          flags: const YoutubePlayerFlags(
            autoPlay: false,
            mute: false,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _youtubeController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeroSection(),
          _buildContentSection(),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      width: double.infinity,
      height: 500,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(widget.movieDetails.backdropUrl),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.transparent,
              const Color(0xFF141414).withOpacity(0.9),
              const Color(0xFF141414),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 60),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.movieDetails.title,
                          style: GoogleFonts.inter(
                            fontSize: 56,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            height: 1.1,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _buildInfoChip(Icons.star_rate_rounded, widget.movieDetails.voteAverage.toStringAsFixed(1)),
                            const SizedBox(width: 12),
                            _buildInfoChip(Icons.calendar_today, widget.movieDetails.releaseDate),
                            const SizedBox(width: 12),
                            _buildInfoChip(Icons.access_time, '${widget.movieDetails.runtime} min'),
                            const SizedBox(width: 12),
                            _buildInfoChip(Icons.hd, '4K'),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            _buildPlayButton(),
                            const SizedBox(width: 16),
                            _buildBookmarkButton(),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 48),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      widget.movieDetails.posterUrl,
                      width: 280,
                      height: 400,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 280,
                          height: 400,
                          color: const Color(0xFF1F1F1F),
                          child: const Icon(
                            Icons.movie,
                            color: Color(0xFF404040),
                            size: 64,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE50914), Color(0xFFB81D24)],
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.play_arrow, color: Colors.white, size: 28),
          const SizedBox(width: 12),
          Text(
            'Watch Now',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookmarkButton() {
    return BlocBuilder<WatchlistBloc, WatchlistState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(
                widget.movieDetails.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                widget.movieDetails.isBookmarked ? 'Added' : 'My List',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContentSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOverviewSection(),
          const SizedBox(height: 40),
          _buildTrailerSection(),
          const SizedBox(height: 40),
          _buildCastSection(),
          const SizedBox(height: 40),
          _buildGenresSection(),
          const SizedBox(height: 40),
          _buildSimilarSection(),
        ],
      ),
    );
  }

  Widget _buildOverviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overview',
          style: GoogleFonts.inter(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          widget.movieDetails.overview,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: const Color(0xFFB3B3B3),
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildTrailerSection() {
    if (_youtubeController == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Trailer',
          style: GoogleFonts.inter(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: YoutubePlayer(
              controller: _youtubeController!,
              showVideoProgressIndicator: true,
              progressIndicatorColor: const Color(0xFFE50914),
              progressColors: const ProgressBarColors(
                playedColor: Color(0xFFE50914),
                handleColor: Color(0xFFE50914),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCastSection() {
    if (widget.movieDetails.cast == null || widget.movieDetails.cast!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cast',
          style: GoogleFonts.inter(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: widget.movieDetails.cast!.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              return _buildCastCard(widget.movieDetails.cast![index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCastCard(Cast cast) {
    return Container(
      width: 140,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              cast.profileUrl,
              width: 140,
              height: 160,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 140,
                  height: 160,
                  color: const Color(0xFF1F1F1F),
                  child: const Icon(
                    Icons.person,
                    color: Color(0xFF404040),
                    size: 48,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Text(
            cast.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenresSection() {
    if (widget.movieDetails.genres == null || widget.movieDetails.genres!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Genres',
          style: GoogleFonts.inter(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: widget.movieDetails.genres.split(',').map((genre) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Text(
                genre.trim(),
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSimilarSection() {
    final moviesBloc = context.read<MoviesBloc>();
    final popularMovies = moviesBloc.state.status == RequestStatus.loaded
        ? moviesBloc.state.movies[1]
        : <Media>[];
    final similarMovies = widget.movieDetails.similar ?? popularMovies;

    if (similarMovies.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Similar Movies',
          style: GoogleFonts.inter(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 280,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: similarMovies.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              return _buildSimilarMovieCard(similarMovies[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSimilarMovieCard(Media media) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          navigateToDetailsView(context, media);
        },
        child: Container(
          width: 200,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  media.posterUrl,
                  width: 200,
                  height: 280,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 200,
                      height: 280,
                      color: const Color(0xFF1F1F1F),
                      child: const Icon(
                        Icons.movie,
                        color: Color(0xFF404040),
                        size: 48,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              Text(
                media.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.star_rate_rounded,
                    color: Color(0xFFE8B84B),
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    media.voteAverage.toStringAsFixed(1),
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
