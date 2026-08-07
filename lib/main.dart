import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:movie_web/tv_shows/presentation/controllers/tv_shows_bloc/tv_shows_bloc.dart';
import 'package:movie_web/watchlist/data/models/watchlist_item_model.dart';
import 'package:movie_web/watchlist/presentation/controllers/watchlist_bloc/watchlist_bloc.dart';

import 'core/presentation/components/ads/html_ad_widget.dart';
import 'core/resources/app_router.dart';
import 'core/resources/app_strings.dart';
import 'core/resources/app_colors.dart';
import 'core/services/service_locator.dart';
import 'core/services/remote_config_service.dart' if (dart.library.html) 'core/services/remote_config_stub.dart';
import 'core/services/firebase_ad_config_service.dart';
import 'core/services/dns_detector_service.dart';
import 'core/presentation/components/network_aware_widget.dart';
import 'movies/presentation/controllers/movies_bloc/movies_bloc.dart';
import 'movies/presentation/controllers/movies_bloc/movies_event.dart';
import 'ads/app_open_ad_manager.dart';
import 'ads/app_lifecycle_reactor.dart';

// Import Hive with platform-specific handling
import 'package:hive_flutter/hive_flutter.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
bool _adsRegistered = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load();

  // Initialize Firebase with error handling
  try {
    // Initialize Firebase for all platforms including web
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized successfully');
  } catch (e) {
    print('⚠️ Firebase initialization failed: $e');
    print('⚠️ App will continue without Firebase');
  }

  // Initialize Mobile Ads with error handling (only on non-web platforms)
  if (!kIsWeb) {
    try {
      await MobileAds.instance.initialize();
    } catch (e) {
      print('⚠️ Mobile Ads initialization failed: $e');
      print('⚠️ App will continue without ads');
    }
  } else {
    print('ℹ️ Mobile Ads initialization skipped on web platform');
  }

  // Initialize Remote Config with error handling
  try {
    await RemoteConfigService.instance.initialize();
  } catch (e) {
    print('⚠️ Remote Config initialization failed: $e');
    print('⚠️ App will continue with default ad settings');
  }

  if (kIsWeb) {
    try {
      await FirebaseAdConfigService().initialize();
      print('✅ Firebase Ad Config Service initialized');
    } catch (e) {
      print('⚠️ Firebase Ad Config initialization failed: $e');
      print('⚠️ App will continue with default ad keys');
    }
  }

  // Only initialize DNS detector on non-web platforms
  if (!kIsWeb) {
    await DnsDetectorService().initialize();
  }

  // Only initialize Hive on non-web platforms
  if (!kIsWeb) {
    await Hive.initFlutter();
    Hive.registerAdapter(WatchlistItemModelAdapter());
    await Hive.openBox<WatchlistItemModel>('items');
  }

  await ServiceLocator.init();
  if (kIsWeb && !_adsRegistered) {
    registerAllAdViews();
    _adsRegistered = true;
  }
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => sl<MoviesBloc>()..add(GetMoviesEvent()),
        ),
        BlocProvider(
          create: (context) => sl<TVShowsBloc>()..add(GetTVShowsEvent()),
        ),
        BlocProvider(
          create: (context) =>
          sl<WatchlistBloc>()..add(GetWatchListItemsEvent()),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  bool _wasInBackground = false;
  DateTime? _lastPausedTime;
  static const Duration _backgroundThreshold = Duration(seconds: 2);

  late AppLifecycleReactor _appLifecycleReactor;

  @override
  void initState() {
    super.initState();

    // Only add lifecycle observer and initialize ads on non-web platforms
    if (!kIsWeb) {
      WidgetsBinding.instance.addObserver(this);
      AppOpenAdManager.instance;

      _appLifecycleReactor = AppLifecycleReactor(
        appOpenAdManager: AppOpenAdManager.instance,
      );
      _appLifecycleReactor.listenToAppStateChanges();

      print('✅ Global App Open Ad Manager initialized');
    }
  }

  @override
  void dispose() {
    if (!kIsWeb) {
      WidgetsBinding.instance.removeObserver(this);
      _appLifecycleReactor.dispose();
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (kIsWeb) return;

    super.didChangeAppLifecycleState(state);

    print('🔵 App lifecycle state: $state');
    if (state == AppLifecycleState.paused) {
      _wasInBackground = true;
      _lastPausedTime = DateTime.now();
      print('🔴 App going to background at ${_lastPausedTime}');
    }
    if (state == AppLifecycleState.resumed && _wasInBackground && _lastPausedTime != null) {
      final pauseDuration = DateTime.now().difference(_lastPausedTime!);
      print('🟢 App resumed after ${pauseDuration.inSeconds} seconds');
      if (pauseDuration >= _backgroundThreshold) {
        print('✅ App was in background long enough - scheduling navigation to info screen');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _navigateToInfoScreen();
        });
      } else {
        print('⏭️ Quick resume - skipping info screen');
      }
      _wasInBackground = false;
      _lastPausedTime = null;
    }
  }

  void _navigateToInfoScreen() {
    if (!mounted) {
      print('⚠️ Cannot navigate - widget not mounted');
      return;
    }
    try {
      final router = AppRouter.router;
      router.go('/info');
      print('📍 Navigated to info screen');
    } catch (e) {
      print('❌ Navigation error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return NetworkAwareWidget(
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: AppStrings.appTitle,
        theme: ThemeData(
          scaffoldBackgroundColor: AppNetflixThemeColor.background,
          primaryColor: AppNetflixThemeColor.primaryIndigo,
          colorScheme: ColorScheme.dark(
            background: AppNetflixThemeColor.background,
            surface: AppNetflixThemeColor.cardBackground,
            primary: AppNetflixThemeColor.primaryIndigo,
            secondary: AppNetflixThemeColor.secondaryPurple,
            tertiary: AppNetflixThemeColor.tertiaryPink,
          ),
          fontFamily: 'Inter',
          textTheme: TextTheme(
            displayLarge: GoogleFonts.inter(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: AppNetflixThemeColor.white,
            ),
            displayMedium: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: AppNetflixThemeColor.white,
            ),
            displaySmall: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: AppNetflixThemeColor.white,
            ),
            headlineMedium: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppNetflixThemeColor.white,
            ),
            titleLarge: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppNetflixThemeColor.white,
            ),
            titleMedium: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppNetflixThemeColor.white,
            ),
            bodyLarge: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: AppNetflixThemeColor.bodyText,
            ),
            bodyMedium: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppNetflixThemeColor.bodyTextLight,
            ),
            labelLarge: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppNetflixThemeColor.white,
            ),
          ),
          cardTheme: CardThemeData(
            color: AppNetflixThemeColor.cardBackground,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppNetflixThemeColor.primaryIndigo,
              foregroundColor: AppNetflixThemeColor.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: AppNetflixThemeColor.transparent,
            elevation: 0,
            titleTextStyle: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppNetflixThemeColor.white,
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: AppNetflixThemeColor.cardBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppNetflixThemeColor.primaryIndigo, width: 2),
            ),
            hintStyle: GoogleFonts.inter(
              fontSize: 14,
              color: AppNetflixThemeColor.hintText,
            ),
          ),
        ),
        routerConfig: AppRouter.router,
      ),
    );
  }
}
