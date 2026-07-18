import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/presentation/components/error_text.dart';
import '../../../core/presentation/components/loading_indicator.dart';
import '../../../core/resources/app_values.dart';
import '../../../core/resources/app_constants.dart';
import '../../../core/services/service_locator.dart';
import '../../../core/utils/enums.dart';
import '../controllers/tv_show_details_bloc/tv_show_details_bloc.dart';
import '../components/episodes_widget.dart';

class SeasonDetailsView extends StatefulWidget {
  const SeasonDetailsView({
    super.key,
    required this.tvShowId,
    required this.seasonNumber,
    required this.seasonName,
  });

  final int tvShowId;
  final int seasonNumber;
  final String seasonName;

  @override
  State<SeasonDetailsView> createState() => _SeasonDetailsViewState();
}

class _SeasonDetailsViewState extends State<SeasonDetailsView> {
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
      create: (context) => sl<TVShowDetailsBloc>()
        ..add(GetSeasonDetailsEvent(id: widget.tvShowId, seasonNumber: widget.seasonNumber)),
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.seasonName),
        ),
        body: BlocBuilder<TVShowDetailsBloc, TVShowDetailsState>(
          builder: (context, state) {
            switch (state.seasonDetailsStatus) {
              case RequestStatus.loading:
                return const LoadingIndicator();
              case RequestStatus.loaded:
                return EpisodesWidget(episodes: state.seasonDetails!.episodes);
              case RequestStatus.error:
                return const ErrorText();
            }
          },
        ),
      ),
    );
  }
}
