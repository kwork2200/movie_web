// Stub for RemoteConfigService on web platforms to prevent initialization errors
class RemoteConfigService {
  static RemoteConfigService? _instance;
  static RemoteConfigService get instance => _instance ??= RemoteConfigService._();

  RemoteConfigService._();

  bool _isInitialized = false;

  Future<void> initialize() async {
    _isInitialized = true;
  }

  bool get showBannerAds => true;
  bool get showNativeAds => true;
  bool get showInterstitialAds => false; // Disabled on web
  bool get showFbBannerAds => false;
  bool get showFbNativeAds => false;
  bool get showFbInterstitialAds => false;
  int get interstitialAdFrequency => 3;
  String get bannerAdUnitId => '/6499/example/banner';
  String get interstitialAdUnitId => '/6499/example/interstitial';
  String get nativeAdUnitId => '/6499/example/native';
  String get appOpenAdUnitId => '/6499/example/interstitial';
  String get fbBannerAdUnitId => '';
  String get fbInterstitialAdUnitId => '';
  String get fbNativeAdUnitId => '';
  bool get useFacebookAds => false;
  bool get showThirdPartyBannerAds => false;
  bool get showThirdPartyNativeAds => false;
  String get thirdPartyAdUrl => '';
  bool get showThirdPartyInterstitialAds => false;
  String get thirdPartyInterstitialAdUrl1 => '';
  String get thirdPartyInterstitialAdUrl2 => '';
  String get thirdPartyInterstitialAdUrl3 => '';

  // Screen-specific native ad getters
  bool get showNativeAdLanguageSelection => false; // Disabled on web
  bool get showNativeAdLoginSignup => false;
  bool get showNativeAdProfileSetup => false;
  bool get showNativeAdMoviesHome1 => false;
  bool get showNativeAdTVShowsHome => false;
  bool get showNativeAdSearch => false;
  bool get showNativeAdWatchlist => false;
  bool get showNativeAdPopularMovies => false;
  bool get showNativeAdTopRatedMovies => false;
  bool get showNativeAdMovieDetails => false;
  bool get showNativeAdPopularTVShows => false;
  bool get showNativeAdTopRatedTVShows => false;
  bool get showNativeAdTVShowDetails => false;

  // Facebook screen-specific native ad getters
  bool get showFbNativeAdLanguageSelection => false;
  bool get showFbNativeAdLoginSignup => false;
  bool get showFbNativeAdProfileSetup => false;
  bool get showFbNativeAdMoviesHome1 => false;
  bool get showFbNativeAdMoviesHome2 => false;
  bool get showFbNativeAdMoviesHome3 => false;
  bool get showFbNativeAdTVShowsHome => false;
  bool get showFbNativeAdSearch => false;
  bool get showFbNativeAdWatchlist => false;
  bool get showFbNativeAdPopularMovies => false;
  bool get showFbNativeAdTopRatedMovies => false;
  bool get showFbNativeAdMovieDetails => false;
  bool get showFbNativeAdPopularTVShows => false;
  bool get showFbNativeAdTopRatedTVShows => false;
  bool get showFbNativeAdTVShowDetails => false;
}
