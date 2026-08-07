import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

class FirebaseAdConfigService {
  static final FirebaseAdConfigService _instance = FirebaseAdConfigService._internal();
  factory FirebaseAdConfigService() => _instance;
  FirebaseAdConfigService._internal();

  FirebaseRemoteConfig? _remoteConfig;
  Map<String, String> _adKeys = {};
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _remoteConfig = FirebaseRemoteConfig.instance;
      
      await _remoteConfig!.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(hours: 1),
      ));

      // Default values commented out - Only Firebase keys will be used
      // await _remoteConfig!.setDefaults({
      //   'ad_key_banner_1_468x60': 'f92fd51462df13e93e1549f302a4f668',
      //   'ad_key_banner_728x90': '14c1219b6c6a21061e2795fa9dcef8e5',
      //   'ad_key_banner_2_300x250': '5cb6f6899f19690a46f7d9fb4692177a',
      //   'ad_key_banner_3_160x600': '9334562f34012e4dd1841f78d4c7d332',
      //   'ad_key_banner_4_160x300': '063c76c839f754d4f5f60c9988ad6e92',
      //   'ad_key_banner_5_320x50': 'dbeb85669fb7da87e9f90d8241f72b3c',
      //   'ad_key_banner_6_728x90': '14c1219b6c6a21061e2795fa9dcef8e5',
      //   'ad_key_sidebar_left_160x600': '9334562f34012e4dd1841f78d4c7d332',
      //   'ad_key_sidebar_right_160x600': '9334562f34012e4dd1841f78d4c7d332',
      //   'ad_key_bottom_468x60': 'f92fd51462df13e93e1549f302a4f668',
      // });

      await _remoteConfig!.fetchAndActivate();

      _loadAdKeys();
      _isInitialized = true;

      if (kDebugMode) {
        print('✅ Firebase Ad Config initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error initializing Firebase Ad Config: $e');
      }
      _useDefaultKeys();
      _isInitialized = true;
    }
  }

  void _loadAdKeys() {
    _adKeys = {
      'banner-1-468x60': _remoteConfig!.getString('ad_key_banner_1_468x60_online'),
      'banner-728x90': _remoteConfig!.getString('ad_key_banner_728x90_online'),
      'banner-2-300x250': _remoteConfig!.getString('ad_key_banner_2_300x250_online'),
      'banner-3-160x600': _remoteConfig!.getString('ad_key_banner_3_160x600_online'),
      'banner-4-160x300': _remoteConfig!.getString('ad_key_banner_4_160x300_online'),
      'banner-5-320x50': _remoteConfig!.getString('ad_key_banner_5_320x50_online'),
      'banner-6-728x90': _remoteConfig!.getString('ad_key_banner_6_728x90_online'),
      'ad-sidebar-left-160x600': _remoteConfig!.getString('ad_key_sidebar_left_160x600_online'),
      'ad-sidebar-right-160x600': _remoteConfig!.getString('ad_key_sidebar_right_160x600_online'),
      'ad-bottom-468x60': _remoteConfig!.getString('ad_key_bottom_468x60_online'),
    };
  }

  void _useDefaultKeys() {
    // Default keys commented out - Only Firebase keys will be used
    // _adKeys = {
    //   'banner-1-468x60': 'f92fd51462df13e93e1549f302a4f668',
    //   'banner-728x90': '14c1219b6c6a21061e2795fa9dcef8e5',
    //   'banner-2-300x250': '5cb6f6899f19690a46f7d9fb4692177a',
    //   'banner-3-160x600': '9334562f34012e4dd1841f78d4c7d332',
    //   'banner-4-160x300': '063c76c839f754d4f5f60c9988ad6e92',
    //   'banner-5-320x50': 'dbeb85669fb7da87e9f90d8241f72b3c',
    //   'banner-6-728x90': '14c1219b6c6a21061e2795fa9dcef8e5',
    //   'ad-sidebar-left-160x600': '9334562f34012e4dd1841f78d4c7d332',
    //   'ad-sidebar-right-160x600': '9334562f34012e4dd1841f78d4c7d332',
    //   'ad-bottom-468x60': 'f92fd51462df13e93e1549f302a4f668',
    // };
    
    // Initialize empty map - ads will only work if Firebase has the keys
    _adKeys = {};
  }

  String getAdKey(String placement) {
    return _adKeys[placement] ?? '';
  }

  Map<String, String> getAllAdKeys() {
    return Map.unmodifiable(_adKeys);
  }

  bool get isInitialized => _isInitialized;
}
