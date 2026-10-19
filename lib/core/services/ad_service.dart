import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../constants/ad_constants.dart';

class AdService {
  static final AdService instance = AdService._internal();

  AdService._internal();

  bool _isInitialized = false;
  InterstitialAd? _interstitialAd;
  bool _isLoading = false;

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
      preloadInterstitialAd();
    } catch (e) {
      debugPrint('Failed to initialize AdMob SDK: $e');
    }
  }

  /// Preloads an Interstitial Ad in background so it can be shown instantly without lag.
  void preloadInterstitialAd() {
    if (kIsWeb ||
        (defaultTargetPlatform != TargetPlatform.android &&
            defaultTargetPlatform != TargetPlatform.iOS)) {
      return;
    }
    if (_interstitialAd != null || _isLoading) return;

    _isLoading = true;
    InterstitialAd.load(
      adUnitId: AdConstants.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('Interstitial ad preloaded successfully.');
          _interstitialAd = ad;
          _isLoading = false;
        },
        onAdFailedToLoad: (error) {
          debugPrint('Failed to preload interstitial ad (${error.code}): ${error.message}');
          _interstitialAd = null;
          _isLoading = false;
        },
      ),
    );
  }

  /// Loads and shows an Interstitial Ad (e.g. during chat import or selecting an existing chat).
  ///
  /// If an ad is preloaded, displays it immediately.
  /// Calls [onAdDismissed] when the ad finishes, fails to load, or is closed by the user,
  /// ensuring application execution flow is never blocked.
  void showInterstitialAd({VoidCallback? onAdDismissed}) {
    if (kIsWeb ||
        (defaultTargetPlatform != TargetPlatform.android &&
            defaultTargetPlatform != TargetPlatform.iOS)) {
      onAdDismissed?.call();
      return;
    }

    // 1. If an ad is already preloaded, show it immediately
    if (_interstitialAd != null) {
      final ad = _interstitialAd!;
      _interstitialAd = null;
      _attachCallbacksAndShow(ad, onAdDismissed);
      return;
    }

    // 2. If no ad is preloaded yet, load on-the-fly with a safety timeout
    var handled = false;
    void safeDismiss() {
      if (!handled) {
        handled = true;
        onAdDismissed?.call();
      }
    }

    // Safety timeout: Never keep the user waiting longer than 3 seconds
    final timer = Timer(const Duration(seconds: 3), () {
      debugPrint('Interstitial ad load timed out. Continuing navigation.');
      safeDismiss();
    });

    _isLoading = true;
    InterstitialAd.load(
      adUnitId: AdConstants.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _isLoading = false;
          timer.cancel();
          if (handled) {
            _interstitialAd = ad;
            return;
          }
          _attachCallbacksAndShow(ad, safeDismiss);
        },
        onAdFailedToLoad: (error) {
          _isLoading = false;
          timer.cancel();
          debugPrint('Failed to load interstitial ad (${error.code}): ${error.message}');
          safeDismiss();
        },
      ),
    );
  }

  void _attachCallbacksAndShow(InterstitialAd ad, VoidCallback? onDismissed) {
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        debugPrint('Interstitial ad showed full screen.');
      },
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('Interstitial ad dismissed.');
        ad.dispose();
        preloadInterstitialAd();
        onDismissed?.call();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('Failed to show interstitial ad (${error.code}): ${error.message}');
        ad.dispose();
        preloadInterstitialAd();
        onDismissed?.call();
      },
      onAdImpression: (ad) {
        debugPrint('Interstitial ad impression recorded.');
      },
    );
    ad.show();
  }
}
