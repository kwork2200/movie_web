// Stub for Firebase on web platforms to prevent initialization errors
class Firebase {
  static Future<FirebaseApp> initializeApp({String? name, FirebaseOptions? options}) async {
    throw UnimplementedError('Firebase is not supported on web in this configuration');
  }
}

class FirebaseApp {
  final String name;
  final FirebaseOptions options;

  FirebaseApp({required this.name, required this.options});
}

class FirebaseOptions {
  final String apiKey;
  final String authDomain;
  final String projectId;
  final String storageBucket;
  final String messagingSenderId;
  final String appId;
  final String? measurementId;

  FirebaseOptions({
    required this.apiKey,
    required this.authDomain,
    required this.projectId,
    required this.storageBucket,
    required this.messagingSenderId,
    required this.appId,
    this.measurementId,
  });
}
