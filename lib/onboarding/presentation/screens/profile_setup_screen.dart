import 'dart:io' show File;
import 'dart:math' as math;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/presentation/components/ads/hybrid_native_ad_widget.dart';
import '../../../core/services/service_locator.dart';
import '../../../core/utils/screen_utils.dart';
import '../../../core/resources/app_colors.dart';
import '../../data/services/onboarding_storage_service.dart';
import '../../../core/presentation/components/ads/ad_enabled_screen.dart';
import '../../../core/presentation/components/ads/native_ad_widget.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _nicknameController = TextEditingController();
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  late AnimationController _orbController;

  // Design constants - using AppColors
  static const Color _bg = AppNetflixThemeColor.darkBackground;
  static const Color _card = AppNetflixThemeColor.cardBackgroundDark;
  static const Color _border = AppNetflixThemeColor.borderColor;
  static const Color _gold = AppNetflixThemeColor.gold;
  static const Color _purple = AppNetflixThemeColor.purpleAccent;
  static const Color _muted = AppNetflixThemeColor.mutedTextDark;
  static const Color _text = AppNetflixThemeColor.textSecondary;

  @override
  void initState() {
    super.initState();
    _orbController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nicknameController.dispose();
    _orbController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    // Image picker camera source is not supported on web
    if (kIsWeb && source == ImageSource.camera) {
      _showSnackBar('Camera not available on web', isError: true);
      return;
    }

    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );
      if (picked != null) {
        setState(() => _profileImage = File(picked.path));
      }
    } catch (e) {
      _showSnackBar('Could not pick image', isError: true);
    }
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppNetflixThemeColor.sheetBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: _border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text(
                  'Profile Photo',
                  style: GoogleFonts.dmSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: _text,
                  ),
                ),
                const SizedBox(height: 20),
                // Camera option - only show on non-web platforms
                if (!kIsWeb)
                  _sheetOption(
                    icon: Icons.camera_alt_outlined,
                    label: 'Take Photo',
                    color: _purple,
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.camera);
                    },
                  ),
                if (!kIsWeb) const SizedBox(height: 12),
                _sheetOption(
                  icon: Icons.photo_library_outlined,
                  label: 'Choose from Gallery',
                  color: _gold,
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                if (_profileImage != null) ...[
                  const SizedBox(height: 12),
                  _sheetOption(
                    icon: Icons.delete_outline_rounded,
                    label: 'Remove Photo',
                    color:  AppNetflixThemeColor.errorRed,
                    onTap: () {
                      Navigator.pop(context);
                      setState(() => _profileImage = null);
                    },
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _sheetOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Text(
              label,
              style: GoogleFonts.dmSans(
                color: _text,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleContinue() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 600));

    final storage = sl<OnboardingStorageService>();
    await storage.saveProfileData(
      name: _nameController.text,
      nickname: _nicknameController.text,
      imagePath: _profileImage?.path,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);
    _showSnackBar('Profile saved!');
    context.go('/language-selection');
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: AppNetflixThemeColor.white,
              size: 18,
            ),
            const SizedBox(width: 10),
            Text(message, style: GoogleFonts.dmSans(color: AppNetflixThemeColor.white)),
          ],
        ),
        backgroundColor: isError ?  AppNetflixThemeColor.errorDark :  AppNetflixThemeColor.successGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenUtils = ScreenUtils.of(context);
          return Stack(
            children: [
              // Subtle glow top right
              Positioned(
                top: -60,
                right: -60,
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        _purple.withOpacity(0.1),
                        AppNetflixThemeColor.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              SafeArea(
                child: Column(
                  children: [
                    // Step indicator + header
                    _buildHeader(),

                    // Scrollable content
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              const SizedBox(height: 8),
                              // Avatar picker
                              _buildAvatarPicker(),
                              const SizedBox(height: 10),
                              Text(
                                'Tap to add profile photo',
                                style: GoogleFonts.dmSans(
                                  color: _muted,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 36),

                              // // Native Ad
                              // const Padding(
                              //   padding: EdgeInsets.only(bottom: 24),
                              //   child: HybridNativeAdWidget(adKey: 'profile_setup'),
                              // ),

                              // Name field
                              _fieldLabel('Full Name'),
                              _buildTextField(
                                controller: _nameController,
                                hint: 'Enter your full name',
                                icon: Icons.person_outline_rounded,
                                validator: (v) {
                                  if (v == null || v.isEmpty) return 'Please enter your name';
                                  if (v.length < 2) return 'At least 2 characters';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              // Nickname field
                              _fieldLabel('Nickname'),
                              _buildTextField(
                                controller: _nicknameController,
                                hint: 'Your cool nickname',
                                icon: Icons.badge_outlined,
                                validator: (v) {
                                  if (v == null || v.isEmpty) return 'Please enter a nickname';
                                  if (v.length < 2) return 'At least 2 characters';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 36),

                              // Continue button
                              _buildGoldButton(
                                label: 'Continue',
                                onTap: _isLoading ? null : _handleContinue,
                                isLoading: _isLoading,
                              ),
                              const SizedBox(height: 14),

                              // Skip
                              GestureDetector(
                                onTap: () => context.go('/language-selection'),
                                child: Text(
                                  'Skip for now',
                                  style: GoogleFonts.dmSans(
                                    color: _muted,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step progress bar
          Row(
            children: List.generate(3, (i) {
              return Expanded(
                child: Container(
                  height: 3,
                  margin: EdgeInsets.only(right: i < 2 ? 6 : 0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(99),
                    color: i == 0
                        ? _gold
                        : i == 1
                        ? _purple
                        : _border,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 20),

          // Back + title row
          Row(
            children: [
              GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _border),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: _muted,
                    size: 16,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Text(
                'Setup Profile',
                style: GoogleFonts.dmSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: _text,
                ),
              ),
              const Spacer(),
              Text(
                'Step 2/3',
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  color: _muted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarPicker() {
    return GestureDetector(
      onTap: _showImageSourceSheet,
      child: SizedBox(
        width: 128,
        height: 128,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Spinning gradient ring
            AnimatedBuilder(
              animation: _orbController,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _orbController.value * 2 * math.pi,
                  child: Container(
                    width: 128,
                    height: 128,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: SweepGradient(
                        colors: [
                          AppNetflixThemeColor.gold,
                          AppNetflixThemeColor.purpleAccent,
                          AppNetflixThemeColor.primaryIndigo,
                          AppNetflixThemeColor.gold,
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

            // Inner circle with image or placeholder
            Container(
              width: 118,
              height: 118,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppNetflixThemeColor.cardBackgroundDark,
              ),
              child: ClipOval(
                child: _profileImage != null
                    ? Image.file(_profileImage!, fit: BoxFit.cover)
                    : const Icon(
                  Icons.person_rounded,
                  size: 52,
                  color: AppNetflixThemeColor.mutedTextDark,
                ),
              ),
            ),

            // Camera badge
            Positioned(
              bottom: 2,
              right: 2,
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [AppNetflixThemeColor.gold, AppNetflixThemeColor.goldDark],
                  ),
                  border: Border.all(color: _bg, width: 2.5),
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  color: AppNetflixThemeColor.black,
                  size: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          label.toUpperCase(),
          style: GoogleFonts.dmSans(
            fontSize: 11,
            color: _muted,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      style: GoogleFonts.dmSans(color: _text, fontSize: 15),
      decoration: InputDecoration(
        fillColor: _card,
        filled: true,
        hintText: hint,
        hintStyle: GoogleFonts.dmSans(color: _muted, fontSize: 15),
        prefixIcon: Icon(icon, color: _muted, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _gold, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppNetflixThemeColor.errorRed),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppNetflixThemeColor.errorRed, width: 1.5),
        ),
        errorStyle: GoogleFonts.dmSans(color: AppNetflixThemeColor.errorRed, fontSize: 12),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      validator: validator,
    );
  }

  Widget _buildGoldButton({
    required String label,
    VoidCallback? onTap,
    bool isLoading = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: onTap != null
              ? const LinearGradient(
            colors: [AppNetflixThemeColor.gold, AppNetflixThemeColor.goldDark],
          )
              : null,
          color: onTap == null ? _border : null,
          boxShadow: onTap != null
              ? [
            BoxShadow(
              color: _gold.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ]
              : null,
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              color: AppNetflixThemeColor.black,
              strokeWidth: 2.5,
            ),
          )
              : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: GoogleFonts.dmSans(
                  color: AppNetflixThemeColor.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_rounded,
                color: AppNetflixThemeColor.black,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}