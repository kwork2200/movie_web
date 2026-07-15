import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/domain/entities/media.dart';
import '../../../core/presentation/components/custom_app_bar.dart';
import '../../../core/presentation/components/error_screen.dart';
import '../../../core/presentation/components/loading_indicator.dart';
import '../../../core/presentation/components/vertical_listview_card.dart';
import '../../../core/resources/app_strings.dart';
import '../../../core/resources/app_values.dart';
import '../../../core/services/service_locator.dart';
import '../../../core/utils/enums.dart';
import '../components/empty_watchlist_text.dart';
import '../controllers/watchlist_bloc/watchlist_bloc.dart';

class WatchlistView extends StatelessWidget {
  const WatchlistView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: AppStrings.watchlist),
      body: BlocBuilder<WatchlistBloc, WatchlistState>(
        builder: (context, state) {
          if (state.status == WatchlistRequestStatus.loading) {
            return const LoadingIndicator();
          } else if (state.status == WatchlistRequestStatus.loaded) {
            return WatchlistWidget(items: state.items);
          } else if (state.status == WatchlistRequestStatus.empty) {
            return Center(child: const EmptyWatchlistText());
          } else {
            return ErrorScreen(
              onTryAgainPressed: () {
                context.read<WatchlistBloc>().add(GetWatchListItemsEvent());
              },
            );
          }
        },
      ),
    );
  }
}

class WatchlistWidget extends StatelessWidget {
  const WatchlistWidget({super.key, required this.items});

  final List<Media> items;
  static const int _adIndex = 1;

  @override
  Widget build(BuildContext context) {
    final int itemCount = items.length + 1;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView.separated(
        itemCount: itemCount,
        itemBuilder: (context, index) {
          final mediaIndex = index > _adIndex ? index - 1 : index;
          return VerticalListViewCard(
            media: items[mediaIndex],
          );
        },
        separatorBuilder: (_, __) =>
        const SizedBox(height: AppSize.s10),
      ),
    );
  }
}
