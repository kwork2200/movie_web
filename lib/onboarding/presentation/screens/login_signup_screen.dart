import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/presentation/components/ads/hybrid_native_ad_widget.dart';
import '../../../core/services/service_locator.dart';
import '../../../core/utils/screen_utils.dart';
import '../../../core/resources/app_colors.dart';
import '../../data/services/onboarding_storage_service.dart';
import '../../../core/presentation/components/ads/ad_enabled_screen.dart';
import '../../../core/presentation/components/ads/native_ad_widget.dart';

class LoginSignupScreen extends StatefulWidget {
  const LoginSignupScreen({super.key});

  @override
  State<LoginSignupScreen> createState() => _LoginSignupScreenState();
}

class _LoginSignupScreenState extends State<LoginSignupScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _loginFormKey = GlobalKey<FormState>();
  final _signupFormKey = GlobalKey<FormState>();

  final _loginPhoneController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  final _signupPhoneController = TextEditingController();
  final _signupPasswordController = TextEditingController();
  final _signupConfirmPasswordController = TextEditingController();

  bool _loginObscure = true;
  bool _signupObscure = true;
  bool _signupConfirmObscure = true;
  bool _isLoading = false;

  // Design constants - using AppColors
  static const Color _bg = AppNetflixThemeColor.background;
  static const Color _surface = AppNetflixThemeColor.cardBackground;
  static const Color _card = AppNetflixThemeColor.cardBackground;
  static const Color _border = AppNetflixThemeColor.borderColorLight;
  static const Color _primary = AppNetflixThemeColor.primaryIndigo;
  static const Color _secondary = AppNetflixThemeColor.secondaryPurple;
  static const Color _muted = AppNetflixThemeColor.mutedText;
  static const Color _text = AppNetflixThemeColor.textPrimary;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: AppNetflixThemeColor.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginPhoneController.dispose();
    _loginPasswordController.dispose();
    _signupPhoneController.dispose();
    _signupPasswordController.dispose();
    _signupConfirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_loginFormKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 800));

    final storage = sl<OnboardingStorageService>();
    final storedPhone = storage.getUserPhone();
    final storedPassword = storage.getUserPassword();

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (storedPhone == null || storedPassword == null) {
      _showSnackBar('No account found. Please sign up first.', isError: true);
      return;
    }

    if (_loginPhoneController.text == storedPhone &&
        _loginPasswordController.text == storedPassword) {
      await storage.setLoggedIn(true);
      _showSnackBar('Welcome back!');
      if (storage.isOnboardingComplete()) {
        if (mounted) context.go('/movies');
      } else {
        if (mounted) context.go('/profile-setup');
      }
    } else {
      _showSnackBar('Invalid phone number or password', isError: true);
    }
  }

  Future<void> _handleSignup() async {
    if (!_signupFormKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 800));

    final storage = sl<OnboardingStorageService>();
    await storage.saveCredentials(
      _signupPhoneController.text,
      _signupPasswordController.text,
    );
    await storage.setLoggedIn(true);

    if (!mounted) return;
    setState(() => _isLoading = false);
    _showSnackBar('Account created!');
    context.go('/profile-setup');
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
            Text(message, style: GoogleFonts.inter(color: AppNetflixThemeColor.white)),
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
      extendBodyBehindAppBar: true,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenUtils = ScreenUtils.of(context);
          return Stack(
            children: [
              // Background radial glows
              Positioned(
                top: -60,
                right: -60,
                child: _glowCircle(_secondary, 250, 0.1),
              ),
              Positioned(
                bottom: 120,
                left: -80,
                child: _glowCircle(_primary, 280, 0.08),
              ),

              SafeArea(
                child: Column(
                  children: [
                    // Hero section
                    _buildHero(),

                    // Tab bar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: _buildTabBar(),
                    ),
                    const SizedBox(height: 24),

                    // Tab content
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildLoginForm(),
                          _buildSignupForm(),
                        ],
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

  Widget _glowCircle(Color color, double size, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withOpacity(opacity), AppNetflixThemeColor.transparent],
        ),
      ),
    );
  }

  Widget _buildHero() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 32),
      child: Column(
        children: [
          // Icon with glow
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [_primary, _secondary],
              ),
              boxShadow: [
                BoxShadow(
                  color: _primary.withOpacity(0.3),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Icon(
              Icons.play_circle_filled,
              color: AppNetflixThemeColor.white,
              size: 36,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'WELCOME',
            style: GoogleFonts.inter(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
              color: _text,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Sign in or create your account',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: _muted,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
      ),
      padding: const EdgeInsets.all(4),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: const LinearGradient(
            colors: [AppNetflixThemeColor.primaryIndigo, AppNetflixThemeColor.secondaryPurple],
          ),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: AppNetflixThemeColor.black,
        unselectedLabelColor: _muted,
        labelStyle: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        dividerColor: AppNetflixThemeColor.transparent,
        tabs: const [
          Tab(text: 'Login'),
          Tab(text: 'Sign Up'),
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Form(
        key: _loginFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Native Ad
            // const HybridNativeAdWidget(adKey: 'login_signup'),
            _fieldLabel('Phone Number'),
            _buildPhoneField(_loginPhoneController),
            const SizedBox(height: 16),
            _fieldLabel('Password'),
            _buildPasswordField(
              controller: _loginPasswordController,
              obscure: _loginObscure,
              onToggle: () => setState(() => _loginObscure = !_loginObscure),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Forgot password?',
                  style: GoogleFonts.inter(
                    color: _primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildGoldButton(
              label: 'Login',
              onTap: _isLoading ? null : _handleLogin,
              isLoading: _isLoading,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSignupForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Form(
        key: _signupFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _fieldLabel('Phone Number'),
            _buildPhoneField(_signupPhoneController),
            const SizedBox(height: 16),
            _fieldLabel('Password'),
            _buildPasswordField(
              controller: _signupPasswordController,
              obscure: _signupObscure,
              onToggle: () => setState(() => _signupObscure = !_signupObscure),
            ),
            const SizedBox(height: 16),
            _fieldLabel('Confirm Password'),
            _buildPasswordField(
              controller: _signupConfirmPasswordController,
              obscure: _signupConfirmObscure,
              onToggle: () => setState(
                      () => _signupConfirmObscure = !_signupConfirmObscure),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please confirm your password';
                }
                if (value != _signupPasswordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
            const SizedBox(height: 28),
            _buildGoldButton(
              label: 'Create Account',
              onTap: _isLoading ? null : _handleSignup,
              isLoading: _isLoading,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _fieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 11,
          color: _muted,
          letterSpacing: 1.2,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildPhoneField(TextEditingController controller) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.phone,
      maxLength: 10,
      style: GoogleFonts.inter(color: _text, fontSize: 15),
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        counterText: '',
        fillColor: _card,
        filled: true,
        hintText: '98765 43210',
        hintStyle: GoogleFonts.inter(color: _muted, fontSize: 15),
        prefixIcon: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: _primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '+91',
              style: GoogleFonts.inter(
                color: _primary,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
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
          borderSide: const BorderSide(color: _primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppNetflixThemeColor.errorRed),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppNetflixThemeColor.errorRed, width: 1.5),
        ),
        errorStyle: GoogleFonts.inter(color: AppNetflixThemeColor.errorRed, fontSize: 12),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Please enter your phone number';
        if (value.length != 10) return 'Phone number must be 10 digits';
        if (!RegExp(r'^[6-9][0-9]{9}$').hasMatch(value)) {
          return 'Enter a valid Indian phone number';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required bool obscure,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      style: GoogleFonts.inter(color: _text, fontSize: 15),
      decoration: InputDecoration(
        fillColor: _card,
        filled: true,
        hintText: '••••••••',
        hintStyle: GoogleFonts.inter(color: _muted, fontSize: 18, letterSpacing: 3),
        prefixIcon: const Icon(Icons.lock_outline_rounded, color: _muted, size: 20),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            color: _muted,
            size: 20,
          ),
          onPressed: onToggle,
        ),
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
          borderSide: const BorderSide(color: _primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppNetflixThemeColor.errorRed),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppNetflixThemeColor.errorRed, width: 1.5),
        ),
        errorStyle: GoogleFonts.inter(color: AppNetflixThemeColor.errorRed, fontSize: 12),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      validator: validator ??
              (value) {
            if (value == null || value.isEmpty) return 'Please enter your password';
            if (value.length < 6) return 'At least 6 characters required';
            return null;
          },
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
            colors: [AppNetflixThemeColor.primaryIndigo, AppNetflixThemeColor.secondaryPurple],
          )
              : null,
          color: onTap == null ? _border : null,
          boxShadow: onTap != null
              ? [
            BoxShadow(
              color: AppNetflixThemeColor.primaryIndigo.withOpacity(0.4),
              blurRadius: 24,
              offset: const Offset(0, 8),
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
              color: AppNetflixThemeColor.white,
              strokeWidth: 2.5,
            ),
          )
              : Text(
            label,
            style: GoogleFonts.inter(
              color: AppNetflixThemeColor.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}