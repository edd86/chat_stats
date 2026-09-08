import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../constants/ad_constants.dart';

class AdService {
  static final AdService instance = AdService._internal();

  AdService._internal();

  bool _isInitialized = false;

  /// Initializes the Google Mobile Ads SDK safely (v9.x API).
  Future<void> initialize() async {
    if (_isInitialized) return;
    if (kIsWeb ||
        (defaultTargetPlatform != TargetPlatform.android &&
            defaultTargetPlatform != TargetPlatform.iOS)) {
      debugPrint('AdMob is only supported on Android and iOS.');
      return;
    }

    try {
      final status = await MobileAds.instance.initialize();
      _isInitialized = true;
      status.adapterStatuses.forEach((key, value) {
        debugPrint('AdMob Adapter: $key -> state: ${value.state}');
      });
    } catch (e) {
      debugPrint('Failed to initialize AdMob SDK: $e');
    }
  }

  /// Loads and shows a non-intrusive Interstitial Ad (e.g. during chat import / loading).
  ///
  /// Calls [onAdDismissed] when the ad finishes, fails to load, or is closed by the user,
  /// ensuring application execution flow is never blocked.
  void showInterstitialAd({VoidCallback? onAdDismissed}) {
    if (kIsWeb ||
        (defaultTargetPlatform != TargetPlatform.android &&
            defaultTargetPlatform != TargetPlatform.iOS)) {
      onAdDismissed?.call();
      return;
    }

    InterstitialAd.load(
      adUnitId: AdConstants.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (ad) {
              debugPrint('Interstitial ad showed full screen.');
            },
            onAdDismissedFullScreenContent: (ad) {
              debugPrint('Interstitial ad dismissed.');
              ad.dispose();
              onAdDismissed?.call();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              debugPrint('Failed to show interstitial ad (${error.code}): ${error.message}');
              ad.dispose();
              onAdDismissed?.call();
            },
            onAdImpression: (ad) {
              debugPrint('Interstitial ad impression recorded.');
            },
          );
          ad.show();
        },
        onAdFailedToLoad: (error) {
          debugPrint('Failed to load interstitial ad (${error.code}): ${error.message}');
          onAdDismissed?.call();
        },
      ),
    );
  }
}
