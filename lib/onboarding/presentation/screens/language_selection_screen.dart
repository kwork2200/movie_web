import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/presentation/components/ads/hybrid_native_ad_widget.dart';
import '../../../core/services/service_locator.dart';
import '../../../core/utils/screen_utils.dart';
import '../../data/services/onboarding_storage_service.dart';
import '../../../core/presentation/components/ads/ad_enabled_screen.dart';
import '../../../core/presentation/components/ads/native_ad_widget.dart';
import '../../../core/resources/app_values.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen>
    with SingleTickerProviderStateMixin {
  String? _selectedLanguage;
  bool _isLoading = false;

  late AnimationController _fadeController;
  late List<Animation<double>> _itemAnims;

  // Design constants
  static const Color _bg = Color(0xFF0A0E1A);
  static const Color _card = Color(0xFF121826);
  static const Color _border = Color(0xFF1E293B);
  static const Color _primary = Color(0xFF6366F1);
  static const Color _secondary = Color(0xFF8B5CF6);
  static const Color _muted = Color(0xFF94A3B8);
  static const Color _text = Color(0xFFFFFFFF);

  final List<Map<String, String>> _languages = [
    {'code': 'en', 'name': 'English', 'flag': '🇬🇧', 'native': 'English'},
    {'code': 'hi', 'name': 'Hindi', 'flag': '🇮🇳', 'native': 'हिंदी'},
    {'code': 'es', 'name': 'Spanish', 'flag': '🇪🇸', 'native': 'Español'},
    {'code': 'fr', 'name': 'French', 'flag': '🇫🇷', 'native': 'Français'},
    {'code': 'de', 'name': 'German', 'flag': '🇩🇪', 'native': 'Deutsch'},
    {'code': 'pt', 'name': 'Portuguese', 'flag': '🇧🇷', 'native': 'Português'},
    {'code': 'zh', 'name': 'Chinese', 'flag': '🇨🇳', 'native': '中文'},
    {'code': 'ja', 'name': 'Japanese', 'flag': '🇯🇵', 'native': '日本語'},
    {'code': 'ko', 'name': 'Korean', 'flag': '🇰🇷', 'native': '한국어'},
    {'code': 'ar', 'name': 'Arabic', 'flag': '🇸🇦', 'native': 'العربية'},
  ];

  @override
  void initState() {
    super.initState();
    final storage = sl<OnboardingStorageService>();
    _selectedLanguage = storage.getSelectedLanguage();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _itemAnims = List.generate(_languages.length, (i) {
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _fadeController,
          curve: Interval(
            i * 0.06,
            (i * 0.06 + 0.4).clamp(0.0, 1.0),
            curve: Curves.easeOut,
          ),
        ),
      );
    });

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _fadeController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _handleGetStarted() async {
    if (_selectedLanguage == null) {
      _showSnackBar('Please select a language', isError: true);
      return;
    }
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 600));

    final storage = sl<OnboardingStorageService>();
    await storage.saveLanguage(_selectedLanguage!);
    await storage.setOnboardingComplete(true);

    if (!mounted) return;
    setState(() => _isLoading = false);
    context.go('/movies');
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.celebration_outlined,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 10),
            Text(message, style: GoogleFonts.dmSans(color: Colors.white)),
          ],
        ),
        backgroundColor:
        isError ? const Color(0xFF991B1B) : const Color(0xFF15803D),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // ---- Responsive helpers ----
  bool _isWeb(double width) => width >= 900;

  double _maxContentWidth(double width) {
    if (width >= 1400) return 960;
    if (width >= 900) return 820;
    return width;
  }

  int _gridColumns(double width) {
    if (width >= 1400) return 3;
    if (width >= 1100) return 3;
    if (width >= 900) return 2;
    return 1; // mobile -> list style (1 col)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      extendBodyBehindAppBar: true,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final isWeb = _isWeb(width);

          return Stack(
            children: [
              Positioned(
                top: -80,
                left: -80,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        _secondary.withOpacity(0.12),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -60,
                right: -60,
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        _primary.withOpacity(0.1),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              SafeArea(
                child: Center(
                  child: ConstrainedBox(
                    constraints:
                    BoxConstraints(maxWidth: _maxContentWidth(width)),
                    child: Column(
                      children: [
                        _buildHeader(isWeb),
                        _buildHero(isWeb),
                        Expanded(
                          child: isWeb
                              ? _buildWebGrid(width)
                              : _buildMobileList(),
                        ),
                        _buildBottomSection(isWeb),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ---------- MOBILE: original list (unchanged) ----------
  Widget _buildMobileList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
      itemCount: _languages.length,
      itemBuilder: (context, index) {
        return Column(
          children: [
            AnimatedBuilder(
              animation: _itemAnims[index],
              builder: (context, child) {
                return Opacity(
                  opacity: _itemAnims[index].value,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - _itemAnims[index].value)),
                    child: child,
                  ),
                );
              },
              child: _buildLanguageItem(_languages[index], isWeb: false),
            ),
            // if ((index + 1) % 2 == 0)
            //   HybridNativeAdWidget(
            //     height: AppSize.s175,
            //     adKey: 'language_selection',
            //   ),
          ],
        );
      },
    );
  }

  // ---------- WEB: responsive grid, card-style ----------
  Widget _buildWebGrid(double width) {
    final columns = _gridColumns(width);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      physics: const BouncingScrollPhysics(),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _languages.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 3.2,
        ),
        itemBuilder: (context, index) {
          return AnimatedBuilder(
            animation: _itemAnims[index],
            builder: (context, child) {
              return Opacity(
                opacity: _itemAnims[index].value,
                child: Transform.translate(
                  offset: Offset(0, 16 * (1 - _itemAnims[index].value)),
                  child: child,
                ),
              );
            },
            child: _buildLanguageItem(_languages[index], isWeb: true),
          );
        },
      ),
    );
  }

  Widget _buildHeader(bool isWeb) {
    return Padding(
      padding: EdgeInsets.fromLTRB(isWeb ? 0 : 24, 16, isWeb ? 0 : 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(3, (i) {
              return Expanded(
                child: Container(
                  height: 3,
                  margin: EdgeInsets.only(right: i < 2 ? 6 : 0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(99),
                    color: i <= 1 ? _primary : _secondary,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              GestureDetector(
                onTap: () => context.pop(),
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _border),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: _muted,
                      size: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Text(
                'Language',
                style: GoogleFonts.inter(
                  fontSize: isWeb ? 26 : 22,
                  fontWeight: FontWeight.w700,
                  color: _text,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _primary.withOpacity(0.3)),
                ),
                child: Text(
                  'Step 3/3',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHero(bool isWeb) {
    return Padding(
      padding: EdgeInsets.fromLTRB(isWeb ? 0 : 24, 24, isWeb ? 0 : 24, 16),
      child: Row(
        children: [
          Container(
            width: isWeb ? 64 : 56,
            height: isWeb ? 64 : 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(colors: [_primary, _secondary]),
            ),
            child: Icon(
              Icons.language_rounded,
              color: Colors.white,
              size: isWeb ? 32 : 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Choose Your Language',
                  style: GoogleFonts.inter(
                    fontSize: isWeb ? 24 : 20,
                    fontWeight: FontWeight.w700,
                    color: _text,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'You can change this in settings anytime',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: _muted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageItem(Map<String, String> language,
      {required bool isWeb}) {
    final isSelected = _selectedLanguage == language['code'];

    final content = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: isWeb ? EdgeInsets.zero : const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isSelected ? _primary.withOpacity(0.1) : _card,
        border: Border.all(
          color: isSelected ? _primary : _border,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Text(
            language['flag']!,
            style: const TextStyle(fontSize: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  language['native']!,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? _primary : _text,
                  ),
                ),
                Text(
                  language['name']!,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: _muted,
                  ),
                ),
              ],
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? _primary : Colors.transparent,
              border: Border.all(
                color: isSelected ? _primary : _border,
                width: 2,
              ),
            ),
            child: isSelected
                ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
                : null,
          ),
        ],
      ),
    );

    final tappable = GestureDetector(
      onTap: () => setState(() => _selectedLanguage = language['code']),
      child: isWeb
          ? MouseRegion(cursor: SystemMouseCursors.click, child: content)
          : content,
    );

    return isWeb ? SizedBox(height: double.infinity, child: tappable) : tappable;
  }

  Widget _buildBottomSection(bool isWeb) {
    return Container(
      padding: EdgeInsets.fromLTRB(isWeb ? 0 : 24, 12, isWeb ? 0 : 24, 12),
      decoration: BoxDecoration(
        color: _bg,
        border: Border(
          top: BorderSide(color: _border.withOpacity(0.5)),
        ),
      ),
      child: Column(
        children: [
          if (_selectedLanguage != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Selected: ',
                  style: GoogleFonts.inter(color: _muted, fontSize: 13),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _primary.withOpacity(0.3)),
                  ),
                  child: Text(
                    _languages.firstWhere(
                          (l) => l['code'] == _selectedLanguage,
                      orElse: () => {'native': ''},
                    )['native']!,
                    style: GoogleFonts.inter(
                      color: _primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: isWeb ? 360 : double.infinity),
              child: GestureDetector(
                onTap: _isLoading ? null : _handleGetStarted,
                child: MouseRegion(
                  cursor: _selectedLanguage != null
                      ? SystemMouseCursors.click
                      : SystemMouseCursors.basic,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: double.infinity,
                    height: 47,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: _selectedLanguage != null
                          ? const LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                      )
                          : null,
                      color: _selectedLanguage == null ? _border : null,
                      boxShadow: _selectedLanguage != null
                          ? [
                        BoxShadow(
                          color: _primary.withOpacity(0.4),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ]
                          : null,
                    ),
                    child: Center(
                      child: _isLoading
                          ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.black,
                          strokeWidth: 2.5,
                        ),
                      )
                          : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Get Started',
                            style: GoogleFonts.inter(
                              color: _selectedLanguage != null
                                  ? Colors.white
                                  : _muted,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (_selectedLanguage != null) ...[
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.rocket_launch_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}