import 'package:flutter/foundation.dart';

/// Centralized Google AdMob configuration.
/// 
/// Currently uses official Google Test Ad Unit IDs.
/// When your AdMob account is approved, replace these strings with your production IDs.
abstract class AdConstants {
  // --- TEST AD UNIT IDs (Google Official) ---
  static const String _androidTestBannerId = 'ca-app-pub-3940256099942544/6300978111';
  static const String _iosTestBannerId = 'ca-app-pub-3940256099942544/2934735716';

  static const String _androidTestInterstitialId = 'ca-app-pub-3940256099942544/1033173712';
  static const String _iosTestInterstitialId = 'ca-app-pub-3940256099942544/4411468910';

  // --- PRODUCTION AD UNIT IDs (Replace when approved) ---
  static const String _androidProdBannerId = _androidTestBannerId;
  static const String _iosProdBannerId = _iosTestBannerId;

  static const String _androidProdInterstitialId = _androidTestInterstitialId;
  static const String _iosProdInterstitialId = _iosTestInterstitialId;

  /// Returns the appropriate Banner Ad Unit ID based on platform.
  static String get bannerAdUnitId {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return kReleaseMode ? _androidProdBannerId : _androidTestBannerId;
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return kReleaseMode ? _iosProdBannerId : _iosTestBannerId;
    }
    return _androidTestBannerId;
  }

  /// Returns the appropriate Interstitial Ad Unit ID based on platform.
  static String get interstitialAdUnitId {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return kReleaseMode ? _androidProdInterstitialId : _androidTestInterstitialId;
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return kReleaseMode ? _iosProdInterstitialId : _iosTestInterstitialId;
    }
    return _androidTestInterstitialId;
  }
}
