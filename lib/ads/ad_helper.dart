import 'dart:developer';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../core/services/remote_config_service.dart';

class AdHelper {

  static String get appOpenUnitId {
    return RemoteConfigService.instance.appOpenAdUnitId;
  }

  static String get interstitialAdUnitId1 {
    return RemoteConfigService.instance.interstitialAdUnitId;
  }

  static String get interstitialAdUnitId2 {
    return RemoteConfigService.instance.interstitialAdUnitId;
  }

  static String get interstitialAdUnitId3 {
    return RemoteConfigService.instance.interstitialAdUnitId;
  }

  static String get rewardedAdUnitId {
    if (kIsWeb) {
      return '/6499/example/rewarded';
    } else if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/5224354917';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/1712485313';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

}
