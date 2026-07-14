import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../resources/app_router.dart';
import '../../resources/app_routes.dart';
import '../../resources/app_strings.dart';
import '../../resources/app_values.dart';
import '../components/ads/hybrid_native_ad_widget.dart';
import '../../utils/screen_utils.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key, required this.child});

  final Widget child;

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return widget.child;
        },
      ),
     /* bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: Colors.black,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.black,
          selectedItemColor: const Color(0xFFE8B84B),
          unselectedItemColor: const Color(0xFF8892AA),
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 11,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 11,
          ),
          showSelectedLabels: true,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          enableFeedback: false,
          items: const [
            BottomNavigationBarItem(
              label: AppStrings.movies,
              icon: Icon(Icons.movie_creation_outlined, size: AppSize.s20),
              activeIcon: Icon(Icons.movie_creation_rounded, size: AppSize.s20),
            ),
            BottomNavigationBarItem(
              label: AppStrings.shows,
              icon: Icon(Icons.tv_outlined, size: AppSize.s20),
              activeIcon: Icon(Icons.tv_rounded, size: AppSize.s20),
            ),
            BottomNavigationBarItem(
              label: AppStrings.search,
              icon: Icon(Icons.search_outlined, size: AppSize.s20),
              activeIcon: Icon(Icons.search_rounded, size: AppSize.s20),
            ),
            BottomNavigationBarItem(
              label: AppStrings.watchlist,
              icon: Icon(Icons.bookmark_outline_rounded, size: AppSize.s20),
              activeIcon: Icon(Icons.bookmark_rounded, size: AppSize.s20),
            ),
          ],
          currentIndex: _getSelectedIndex(context),
          onTap: (index) => _onItemTapped(index, context),
        ),
      ),*/
    );
  }

  int _getSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith(moviesPath)) {
      return 0;
    }
    if (location.startsWith(tvShowsPath)) {
      return 1;
    }
    if (location.startsWith(searchPath)) {
      return 2;
    }
    if (location.startsWith(watchlistPath)) {
      return 3;
    }
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.goNamed(AppRoutes.moviesRoute);
        break;
      case 1:
        context.goNamed(AppRoutes.tvShowsRoute);
        break;
      case 2:
        context.goNamed(AppRoutes.searchRoute);
        break;
      case 3:
        context.goNamed(AppRoutes.watchlistRoute);
        break;
    }
  }
}
