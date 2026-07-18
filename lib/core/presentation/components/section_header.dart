import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:movie_web/core/resources/app_constants.dart';


import '../../resources/app_colors.dart';
import '../../resources/app_strings.dart';
import '../../resources/app_values.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final Function() onSeeAllTap;

  const SectionHeader({
    super.key,
    required this.title,
    required this.onSeeAllTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppPadding.p8,
        horizontal: AppPadding.p16,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppNetflixThemeColor.white,
            ),
          ),
          InkWell(
            onTap: () {
              AppConstants.openSmartLink();
              onSeeAllTap();
            }, //onTap: onSeeAllTap,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: AppNetflixThemeColor.primaryIndigo.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppNetflixThemeColor.primaryIndigo.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Text(
                    AppStrings.seeAll,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppNetflixThemeColor.primaryIndigo,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    size: 16,
                    color: AppNetflixThemeColor.primaryIndigo,
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
