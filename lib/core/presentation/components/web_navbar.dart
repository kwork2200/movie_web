import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class WebNavbar extends StatelessWidget {
  const WebNavbar({super.key});

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) return const SizedBox.shrink();

    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 48),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.75),
            Colors.black.withOpacity(0.35),
            Colors.transparent,
          ],
        ),
      ),
      child: Row(
        children: [
          _buildLogo(context),
          const SizedBox(width: 48),
          _buildNavItems(context),
          const Spacer(),
          _buildLoginButton(context),
          const SizedBox(width: 16),
          _buildSearchIcon(context),
          // const SizedBox(width: 16),
          // _buildWatchlistIcon(context),
        ],
      ),
    );
  }

  Widget _buildLogo(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          context.go('/movies');
        },
        child:  ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6), Color(0xFFEC4899)],
          ).createShader(bounds),
          child: Text(
            'CINEPLEX',
            style: GoogleFonts.inter(
              fontSize: 35,
              fontWeight: FontWeight.w800,
              letterSpacing: 4,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  // Merged: top nav items + former bottom-nav items (Movies, Shows) live here.
  Widget _buildNavItems(BuildContext context) {
    return Row(
      children: [
        _buildNavItem('TV Shows', '/tvShows', context),
        _buildNavItem('Movies', '/movies', context),
        /*_buildNavItem('VDesi', '/movies', context),
        _buildNavItem('New Now', '/movies', context),
        _buildNavItem('Trailers', '/movies', context),*/
      ],
    );
  }

  Widget _buildNavItem(String title, String route, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => context.go(route),
          child: Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          // context.go('/login');
        },
        child: Text(
          'Login',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // Former bottom-nav "Search" item, moved to top navbar.
  Widget _buildSearchIcon(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          context.go('/search');
        },
        child: const Icon(Icons.search, color: Colors.white, size: 24),
      ),
    );
  }

  // Former bottom-nav "Watchlist" item, moved to top navbar.
  Widget _buildWatchlistIcon(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          context.go('/watchlist');
        },
        child: const Icon(Icons.bookmark_border, color: Colors.white, size: 24),
      ),
    );
  }
}
