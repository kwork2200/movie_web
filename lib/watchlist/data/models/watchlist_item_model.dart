import 'package:hive/hive.dart';
import 'dart:convert';

import '../../../core/domain/entities/media.dart';

part 'watchlist_item_model.g.dart';

@HiveType(typeId: 1)
class WatchlistItemModel {
  @HiveField(0)
  final int tmdbID;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String posterUrl;

  @HiveField(3)
  final String backdropUrl;

  @HiveField(4)
  final double voteAverage;

  @HiveField(5)
  final String releaseDate;

  @HiveField(6)
  final String overview;

  @HiveField(7)
  final bool isMovie;

  const WatchlistItemModel({
    required this.tmdbID,
    required this.title,
    required this.posterUrl,
    required this.backdropUrl,
    required this.voteAverage,
    required this.releaseDate,
    required this.overview,
    required this.isMovie,
  });

  factory WatchlistItemModel.fromEntity(Media media) {
    return WatchlistItemModel(
      tmdbID: media.tmdbID,
      title: media.title,
      posterUrl: media.posterUrl,
      backdropUrl: media.backdropUrl,
      voteAverage: media.voteAverage,
      releaseDate: media.releaseDate,
      overview: media.overview,
      isMovie: media.isMovie,
    );
  }

  // JSON serialization for web support
  factory WatchlistItemModel.fromJson(Map<String, dynamic> json) {
    return WatchlistItemModel(
      tmdbID: json['tmdbID'] as int,
      title: json['title'] as String,
      posterUrl: json['posterUrl'] as String,
      backdropUrl: json['backdropUrl'] as String,
      voteAverage: (json['voteAverage'] as num).toDouble(),
      releaseDate: json['releaseDate'] as String,
      overview: json['overview'] as String,
      isMovie: json['isMovie'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tmdbID': tmdbID,
      'title': title,
      'posterUrl': posterUrl,
      'backdropUrl': backdropUrl,
      'voteAverage': voteAverage,
      'releaseDate': releaseDate,
      'overview': overview,
      'isMovie': isMovie,
    };
  }

  Media toEntity() {
    return Media(
      tmdbID: tmdbID,
      title: title,
      posterUrl: posterUrl,
      backdropUrl: backdropUrl,
      voteAverage: voteAverage,
      releaseDate: releaseDate,
      overview: overview,
      isMovie: isMovie,
    );
  }

  @override
  String toString() {
    return 'WatchlistItemModel(tmdbID: $tmdbID, title: $title, isMovie: $isMovie)';
  }
}
