import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_web/core/presentation/components/ads/html_ad_widget.dart';

import '../../../core/presentation/components/error_screen.dart';
import '../../../core/presentation/components/image_with_shimmer.dart';
import '../../../core/presentation/components/loading_indicator.dart';
import '../../../core/presentation/components/section_listview_card.dart';
import '../../../core/presentation/components/section_title.dart';
import '../../../core/resources/app_colors.dart';
import '../../../core/resources/app_values.dart';
import '../../../core/resources/app_constants.dart';
import '../../../core/services/service_locator.dart';
import '../../../core/utils/enums.dart';
import '../../../core/domain/entities/media.dart';
import '../../domain/entities/person_details.dart';
import '../controllers/person_details_bloc/person_details_bloc.dart';
import '../controllers/person_details_bloc/person_details_event.dart';
import '../controllers/person_details_bloc/person_details_state.dart';

/// -----------------------------------------------------------------------
/// Responsive breakpoints — tweak these to match your design system.
/// -----------------------------------------------------------------------
class _Breakpoints {
  static const double mobile = 600;
  static const double tablet = 1024;
  static const double desktop = 1440;
}

enum _ScreenType { mobile, tablet, desktop, wide }

_ScreenType _screenTypeOf(double width) {
  if (width < _Breakpoints.mobile) return _ScreenType.mobile;
  if (width < _Breakpoints.tablet) return _ScreenType.tablet;
  if (width < _Breakpoints.desktop) return _ScreenType.desktop;
  return _ScreenType.wide;
}

class PersonDetailsView extends StatefulWidget {
  final int personId;

  const PersonDetailsView({
    super.key,
    required this.personId,
  });

  @override
  State<PersonDetailsView> createState() => _PersonDetailsViewState();
}

class _PersonDetailsViewState extends State<PersonDetailsView> {
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
      create: (context) =>
      sl<PersonDetailsBloc>()..add(GetPersonDetailsEvent(widget.personId)),
      child: Scaffold(
        backgroundColor: AppNetflixThemeColor.primaryBackground,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: AppNetflixThemeColor.transparent,
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.only(
              top: AppPadding.p12,
              left: AppPadding.p16,
            ),
            child: _BackButton(onTap: () => Navigator.of(context).pop()),
          ),
        ),
        body: BlocBuilder<PersonDetailsBloc, PersonDetailsState>(
          builder: (context, state) {
            switch (state.status) {
              case RequestStatus.loading:
                return const LoadingIndicator();
              case RequestStatus.loaded:
                return PersonDetailsWidget(personDetails: state.personDetails!);
              case RequestStatus.error:
                return ErrorScreen(
                  onTryAgainPressed: () {
                    context
                        .read<PersonDetailsBloc>()
                        .add(GetPersonDetailsEvent(widget.personId));
                  },
                );
            }
          },
        ),
      ),
    );
  }
}

/// A back button that gets a subtle hover state on web/desktop.
class _BackButton extends StatefulWidget {
  const _BackButton({required this.onTap});
  final VoidCallback onTap;

  @override
  State<_BackButton> createState() => _BackButtonState();
}

class _BackButtonState extends State<_BackButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
     /* child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(AppPadding.p8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _hovering
                ? AppColors.iconContainerColor.withOpacity(0.8)
                : AppColors.iconContainerColor,
            boxShadow: _hovering
                ? [
              BoxShadow(
                color: AppColors.black.withOpacity(0.25),
                blurRadius: 8,
              ),
            ]
                : null,
          ),
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.secondaryText,
            size: AppSize.s20,
          ),
        ),
      ),*/
    );
  }
}

// class PersonDetailsWidget extends StatelessWidget {
//   const PersonDetailsWidget({
//     required this.personDetails,
//     super.key,
//   });
//
//   final PersonDetails personDetails;
//
//   @override
//   Widget build(BuildContext context) {
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         final screenType = _screenTypeOf(constraints.maxWidth);
//         final isWide = screenType == _ScreenType.desktop ||
//             screenType == _ScreenType.wide;
//
//         // Cap content width on very large screens so text/cards
//         // don't stretch edge-to-edge on desktop browsers.
//         final maxContentWidth = switch (screenType) {
//           _ScreenType.mobile => constraints.maxWidth,
//           _ScreenType.tablet => constraints.maxWidth,
//           _ScreenType.desktop => 960.0,
//           _ScreenType.wide => 1200.0,
//         };
//
//         return SingleChildScrollView(
//           physics: const BouncingScrollPhysics(),
//           child: Center(
//             child: ConstrainedBox(
//               constraints: BoxConstraints(maxWidth: maxContentWidth),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   isWide
//                       ? _DesktopHeader(personDetails: personDetails)
//                       : _MobileHeader(
//                     personDetails: personDetails,
//                     screenType: screenType,
//                   ),
//                   if (isWide)
//                     _DesktopBody(personDetails: personDetails)
//                   else
//                     _MobileBody(
//                       personDetails: personDetails,
//                       screenType: screenType,
//                     ),
//                   const SizedBox(height: AppSize.s24),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

class PersonDetailsWidget extends StatelessWidget {
  const PersonDetailsWidget({required this.personDetails, super.key});

  final PersonDetails personDetails;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final screenType = _screenTypeOf(width);
        final isWide = screenType == _ScreenType.desktop ||
            screenType == _ScreenType.wide;

        final showSidebarAds = kIsWeb && width >= 1200;

        // Builds the content, but sizes itself based on the width
        // ACTUALLY available to it (important when sidebars are present).
        Widget buildMainContent() {
          return LayoutBuilder(
            builder: (context, innerConstraints) {
              final availableWidth = innerConstraints.maxWidth;
              final innerScreenType = _screenTypeOf(availableWidth);
              final innerIsWide = innerScreenType == _ScreenType.desktop ||
                  innerScreenType == _ScreenType.wide;

              final maxContentWidth = switch (innerScreenType) {
                _ScreenType.mobile => availableWidth,
                _ScreenType.tablet => availableWidth,
                _ScreenType.desktop => 960.0,
                _ScreenType.wide => 1200.0,
              };

              return Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: maxContentWidth < availableWidth
                        ? maxContentWidth
                        : availableWidth,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      innerIsWide
                          ? _DesktopHeader(personDetails: personDetails)
                          : _MobileHeader(
                        personDetails: personDetails,
                        screenType: innerScreenType,
                      ),
                      if (innerIsWide)
                        _DesktopBody(personDetails: personDetails)
                      else
                        _MobileBody(
                          personDetails: personDetails,
                          screenType: innerScreenType,
                        ),
                      Container(
                        color: AppNetflixThemeColor.transparent,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                        child: const Center(
                          child: HtmlAdWidget(
                            viewType: 'ad-bottom-468x60',
                            width: 468,
                            height: 60,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSize.s24),
                    ],
                  ),
                ),
              );
            },
          );
        }

        if (!showSidebarAds) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: buildMainContent(),
          );
        }

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 160,
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 40),
                child: const HtmlAdWidget(
                  viewType: 'ad-sidebar-left-160x600',
                  width: 160,
                  height: 2500,
                ),
              ),
              Expanded(child: buildMainContent()),
              Padding(
                padding: const EdgeInsets.only(right: 15.0),
                child: Container(
                  width: 160,
                  padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 40),
                  child: const HtmlAdWidget(
                    viewType: 'ad-sidebar-right-160x600',
                    width: 160,
                    height: 1800,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
/// -----------------------------------------------------------------------
/// MOBILE / TABLET LAYOUT — hero image with overlayed name (original style,
/// polished up).
/// -----------------------------------------------------------------------
class _MobileHeader extends StatelessWidget {
  const _MobileHeader({required this.personDetails, required this.screenType});

  final PersonDetails personDetails;
  final _ScreenType screenType;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final heroHeight = screenType == _ScreenType.tablet
        ? AppSize.s400 + 80
        : AppSize.s400;

    return Stack(
      children: [
        ShaderMask(
          shaderCallback: (rect) {
            return const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppNetflixThemeColor.transparent,
                AppNetflixThemeColor.black,
                AppNetflixThemeColor.black,
                AppNetflixThemeColor.transparent,
              ],
              stops: [0.0, 0.5, 0.7, 1.0],
            ).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
          },
          blendMode: BlendMode.dstIn,
          child: ImageWithShimmer(
            imageUrl: personDetails.imageUrl,
            width: double.infinity,
            height: heroHeight,
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(AppPadding.p16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppNetflixThemeColor.transparent,
                  AppNetflixThemeColor.black.withOpacity(0.75),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  personDetails.name,
                  style: textTheme.titleLarge?.copyWith(
                    fontSize: screenType == _ScreenType.tablet ? 34 : 28,
                    fontWeight: FontWeight.bold,
                    shadows: const [
                      Shadow(color: AppNetflixThemeColor.black54, blurRadius: 6),
                    ],
                  ),
                ),
                const SizedBox(height: AppSize.s8),
                _GenderChip(gender: personDetails.gender),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MobileBody extends StatelessWidget {
  const _MobileBody({required this.personDetails, required this.screenType});

  final PersonDetails personDetails;
  final _ScreenType screenType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(AppPadding.p16),
          child: _InfoCard(personDetails: personDetails),
        ),
        if (personDetails.castCredits.isNotEmpty)
          _KnownForSection(
            personDetails: personDetails,
            crossAxisCount: screenType == _ScreenType.tablet ? 3 : null,
          ),
      ],
    );
  }
}

/// -----------------------------------------------------------------------
/// DESKTOP / WEB LAYOUT — side-by-side poster + info, better use of
/// horizontal space instead of a full-bleed hero image.
/// -----------------------------------------------------------------------
class _DesktopHeader extends StatelessWidget {
  const _DesktopHeader({required this.personDetails});

  final PersonDetails personDetails;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppPadding.p24,
        AppPadding.s80,
        AppPadding.p24,
        AppPadding.p24,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Poster card
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppNetflixThemeColor.black.withOpacity(0.35),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: ImageWithShimmer(
                imageUrl: personDetails.imageUrl,
                width: 280,
                height: 380,
              ),
            ),
          ),
          const SizedBox(width: AppSize.s24 + AppSize.s8),
          // Name + gender + info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  personDetails.name,
                  style: textTheme.titleLarge?.copyWith(
                    fontSize: 42,
                    color: AppNetflixThemeColor.primary,
                    fontWeight: FontWeight.bold,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: AppSize.s12),
                _GenderChip(gender: personDetails.gender),
                const SizedBox(height: AppSize.s24),
                _InfoCard(personDetails: personDetails),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DesktopBody extends StatelessWidget {
  const _DesktopBody({required this.personDetails});

  final PersonDetails personDetails;

  @override
  Widget build(BuildContext context) {
    if (personDetails.castCredits.isEmpty) return const SizedBox.shrink();
    return _KnownForSection(
      personDetails: personDetails,
      crossAxisCount: 5,
    );
  }
}

/// -----------------------------------------------------------------------
/// SHARED PIECES
/// -----------------------------------------------------------------------
class _GenderChip extends StatelessWidget {
  const _GenderChip({required this.gender});
  final String gender;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppPadding.p12,
        vertical: AppPadding.p6,
      ),
      decoration: BoxDecoration(
        color: AppNetflixThemeColor.iconContainerColor.withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        gender,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: AppNetflixThemeColor.secondaryText,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.personDetails});

  final PersonDetails personDetails;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final rows = <Widget>[];

    if (personDetails.birthday != null) {
      rows.add(_InfoRow(
        icon: Icons.cake_outlined,
        label: 'Birthday',
        value: personDetails.birthday!,
      ));
    }
    if (personDetails.deathday != null) {
      rows.add(_InfoRow(
        icon: Icons.event_busy_outlined,
        label: 'Deathday',
        value: personDetails.deathday!,
      ));
    }
    if (personDetails.country != null) {
      rows.add(_InfoRow(
        icon: Icons.public_outlined,
        label: 'Country',
        value: personDetails.country!,
      ));
    }

    if (rows.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppPadding.p16),
      decoration: BoxDecoration(
        color: AppNetflixThemeColor.iconContainerColor.withOpacity(0.25),
        // color: AppNetflixThemeColor.primary.withOpacity(0.25),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppNetflixThemeColor.iconContainerColor.withOpacity(0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Personal Information',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: AppSize.s16),
          ...rows,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSize.s12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppNetflixThemeColor.secondaryText),
          const SizedBox(width: AppSize.s10),
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: textTheme.bodyMedium?.copyWith(
                color: AppNetflixThemeColor.secondaryText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: AppSize.s16),
          Expanded(
            child: Text(
              value,
              style: textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

/// "Known For" section.
/// - On mobile: horizontal scroll (as in the original).
/// - On tablet/desktop: a responsive wrap-grid so more posters are visible
///   without needing to scroll sideways — much nicer for web/mouse users.
class _KnownForSection extends StatelessWidget {
  const _KnownForSection({
    required this.personDetails,
    this.crossAxisCount,
  });

  final PersonDetails personDetails;

  /// If null -> horizontal scrolling list (mobile).
  /// If set -> grid with this many columns (tablet/desktop/web).
  final int? crossAxisCount;

  @override
  Widget build(BuildContext context) {
    final credits = personDetails.castCredits;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: 'Known For'),
        if (crossAxisCount == null)
          SizedBox(
            height: AppSize.s240,
            child: ListView.separated(
              padding:
              const EdgeInsets.symmetric(horizontal: AppPadding.p16),
              scrollDirection: Axis.horizontal,
              itemCount: credits.length,
              separatorBuilder: (_, __) => const SizedBox(width: AppSize.s10),
              itemBuilder: (context, index) =>
                  _CreditCard(credit: credits[index]),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppPadding.p16),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: credits.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount!,
                mainAxisSpacing: AppSize.s16,
                crossAxisSpacing: AppSize.s16,
                childAspectRatio: 0.62,
              ),
              itemBuilder: (context, index) =>
                  _CreditCard(credit: credits[index]),
            ),
          ),
      ],
    );
  }
}

/// A single "Known For" credit card with a subtle web hover lift.
class _CreditCard extends StatefulWidget {
  const _CreditCard({required this.credit});
  final dynamic credit;

  @override
  State<_CreditCard> createState() => _CreditCardState();
}

class _CreditCardState extends State<_CreditCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final credit = widget.credit;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedScale(
        scale: _hovering ? 1.03 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
          ),
          child: SectionListViewCard(
            media: Media(
              tmdbID: credit.showId,
              title: credit.showName,
              posterUrl: credit.showImageUrl ?? '',
              backdropUrl: '',
              overview: credit.characterName ?? '',
              voteAverage: 0,
              releaseDate: '',
              isMovie: false,
            ),
          ),
        ),
      ),
    );
  }
}