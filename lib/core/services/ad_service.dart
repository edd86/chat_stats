import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../constants/ad_constants.dart';

class AdService {
  static final AdService instance = AdService._internal();

  AdService._internal();

  bool _isInitialized = false;
  Future<void>? _initializationFuture;
  InterstitialAd? _interstitialAd;
  Completer<InterstitialAd?>? _loadingCompleter;
  bool _pendingShowOnLoad = false;
  VoidCallback? _pendingDismissCallback;

  Future<void> get ready {
    if (_isInitialized) return Future<void>.value();
    return _initializationFuture ??= _initialize();
  }

  Future<void> _initialize() async {
    if (kIsWeb ||
        (defaultTargetPlatform != TargetPlatform.android &&
            defaultTargetPlatform != TargetPlatform.iOS)) {
      return;
    }

    try {
      await MobileAds.instance.initialize();
      _isInitialized = true;
      preloadInterstitialAd();
    } catch (e) {
      debugPrint('Failed to initialize AdMob SDK: $e');
    }
  }

  Future<void> preloadInterstitialAd() async {
    if (_interstitialAd != null || _loadingCompleter != null) return;
    
    await ready;
    _loadingCompleter = Completer<InterstitialAd?>();

    InterstitialAd.load(
      adUnitId: AdConstants.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('Interstitial ad preloaded successfully.');
          _interstitialAd = ad;
          _loadingCompleter!.complete(ad);
          _loadingCompleter = null;
          
          if (_pendingShowOnLoad) {
             _pendingShowOnLoad = false;
             _showInterstitialAdInternal(_pendingDismissCallback);
             _pendingDismissCallback = null;
          }
        },
        onAdFailedToLoad: (error) {
          debugPrint('Failed to preload interstitial ad (${error.code}): ${error.message}');
          _interstitialAd = null;
          _loadingCompleter!.complete(null);
          _loadingCompleter = null;
          Future.delayed(const Duration(seconds: 5), () => preloadInterstitialAd());
        },
      ),
    );
  }

  Future<void> showInterstitialAd({VoidCallback? onAdDismissed}) async {
    await ready;

    if (_interstitialAd != null) {
      _showInterstitialAdInternal(onAdDismissed);
      return;
    }

    if (_loadingCompleter != null) {
      _pendingShowOnLoad = true;
      _pendingDismissCallback = onAdDismissed;
      return;
    }

    _pendingShowOnLoad = true;
    _pendingDismissCallback = onAdDismissed;
    preloadInterstitialAd();
  }

  Future<void> _showInterstitialAdInternal(VoidCallback? onAdDismissed) async {
    final ad = _interstitialAd!;
    _interstitialAd = null;
    
    while (WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    await WidgetsBinding.instance.endOfFrame;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        preloadInterstitialAd();
        onAdDismissed?.call();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        preloadInterstitialAd();
        onAdDismissed?.call();
      },
    );
    ad.show();
  }
}
