import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:stream_transform/stream_transform.dart';

import '../../../../core/domain/entities/media.dart';
import '../../../../core/domain/usecase/base_use_case.dart';
import '../../../../movies/domain/usecases/get_movies_usecase.dart';
import '../../../../tv_shows/domain/usecases/get_tv_shows_usecase.dart';
import '../../../domain/entities/search_result_item.dart';
import '../../../domain/usecases/search_usecase.dart';

part 'search_event.dart';
part 'search_state.dart';

const _duration = Duration(milliseconds: 400);

EventTransformer<Event> debounce<Event>(Duration duration) {
  return (events, mapper) => events.debounce(duration).switchMap(mapper);
}

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc(
    this._searchUseCase,
    this._getMoviesUseCase,
    this._getTVShowsUseCase,
  ) : super(const SearchState()) {
    on<GetSearchResultsEvent>(_getSearchResults,
        transformer: debounce(_duration));
  }

  final SearchUseCase _searchUseCase;
  final GetMoviesUseCase _getMoviesUseCase;
  final GetTVShowsUseCase _getTVShowsUseCase;

  SearchResultItem _mediaToSearchResultItem(Media media) {
    return SearchResultItem(
      tmdbID: media.tmdbID,
      posterUrl: media.posterUrl,
      title: media.title,
      isMovie: media.isMovie,
    );
  }

  Future<void> _getSearchResults(
      GetSearchResultsEvent event, Emitter<SearchState> emit) async {
    if (event.title.trim().isEmpty) {
      emit(
        state.copyWith(
          status: SearchRequestStatus.loading,
        ),
      );

      final moviesResult = await _getMoviesUseCase(NoParameters());
      final tvShowsResult = await _getTVShowsUseCase(NoParameters());

      final allResults = <SearchResultItem>[];

      moviesResult.fold(
        (l) => null,
        (movieLists) {
          for (final movieList in movieLists) {
            for (final movie in movieList) {
              allResults.add(_mediaToSearchResultItem(movie));
            }
          }
        },
      );

      tvShowsResult.fold(
        (l) => null,
        (tvShowLists) {
          for (final tvShowList in tvShowLists) {
            for (final tvShow in tvShowList) {
              allResults.add(_mediaToSearchResultItem(tvShow));
            }
          }
        },
      );

      if (allResults.isEmpty) {
        return emit(
          state.copyWith(
            status: SearchRequestStatus.noResults,
          ),
        );
      }

      return emit(
        state.copyWith(
          status: SearchRequestStatus.loaded,
          searchResults: allResults,
        ),
      );
    }

    emit(
      state.copyWith(
        status: SearchRequestStatus.loading,
      ),
    );

    final result = await _searchUseCase(event.title);
    result.fold(
      (l) => emit(
        state.copyWith(
          status: SearchRequestStatus.error,
          message: l.message,
        ),
      ),
      (r) {
        if (r.isEmpty) {
          emit(
            state.copyWith(
              status: SearchRequestStatus.noResults,
            ),
          );
        } else {
          emit(
            state.copyWith(
              status: SearchRequestStatus.loaded,
              searchResults: r,
            ),
          );
        }
      },
    );
  }
}
