import '../services/remote_config_service.dart';

class Env {
  Env._();

  static String get apiKey => RemoteConfigService.instance.apiKey;
  static String get baseUrl => RemoteConfigService.instance.apiBaseUrl;
}
