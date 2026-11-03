import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../constants/ad_constants.dart';
import '../services/ad_service.dart';
import '../theme/app_colors.dart';

class AdBannerWidget extends StatefulWidget {
  const AdBannerWidget({super.key});

  @override
  State<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends State<AdBannerWidget> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;
  bool _isAdLoading = false;

  /// Progressive backoff delays used to retry failed banner loads.
  /// The last delay is reused until [_maxRetryAttempts] is reached.
  static const List<Duration> _retryDelays = [
    Duration(seconds: 5),
    Duration(seconds: 15),
    Duration(seconds: 30),
  ];
  static const int _maxRetryAttempts = 6;
  int _retryAttempt = 0;
  Timer? _retryTimer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Load only if there is no banner currently in flight or loaded.
    if (_bannerAd == null && !_isAdLoading && _retryTimer == null) {
      _loadBannerAd();
    }
  }

  /// Waits for the Google Mobile Ads SDK to be ready before requesting
  /// the banner, otherwise the first request may be lost while the SDK
  /// is still initializing (it is bootstrapped after `runApp`).
  Future<void> _loadBannerAd() async {
    if (kIsWeb ||
        (defaultTargetPlatform != TargetPlatform.android &&
            defaultTargetPlatform != TargetPlatform.iOS)) {
      return;
    }

    _isAdLoading = true;
    try {
      await AdService.instance.ready;
      if (!mounted) return;

      final int width = MediaQuery.sizeOf(context).width.truncate();
      final Orientation orientation = MediaQuery.orientationOf(context);
      final AdSize size =
          await AdSize.getLargeAnchoredAdaptiveBannerAdSizeWithOrientation(
        orientation,
        width,
      ) ??
          AdSize.banner;

      final BannerAd newBanner = BannerAd(
        adUnitId: AdConstants.bannerAdUnitId,
        size: size,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            if (!mounted) {
              ad.dispose();
              return;
            }
            setState(() {
              _isAdLoaded = true;
              _retryAttempt = 0;
            });
          },
          onAdFailedToLoad: (ad, error) {
            debugPrint(
              'BannerAd failed to load (${error.code}): ${error.message}',
            );
            ad.dispose();
            _bannerAd = null;
            _isAdLoaded = false;
            if (!mounted) return;
            _scheduleRetry();
          },
        ),
      );

      _bannerAd?.dispose();
      _bannerAd = newBanner;
      await newBanner.load();
    } catch (e) {
      debugPrint('Error loading banner ad: $e');
      if (mounted) _scheduleRetry();
    } finally {
      _isAdLoading = false;
    }
  }

  /// Schedules a retry with progressive backoff so transient failures
  /// (no fill, missing connectivity, unfinished SDK init) can recover
  /// without leaving the screen banner-less forever.
  void _scheduleRetry() {
    if (!mounted || _retryTimer != null) return;
    if (_retryAttempt >= _maxRetryAttempts) {
      debugPrint('BannerAd retry limit reached ($_maxRetryAttempts attempts).');
      return;
    }

    final int delayIndex =
        _retryAttempt.clamp(0, _retryDelays.length - 1).toInt();
    final Duration delay = _retryDelays[delayIndex];
    debugPrint('BannerAd retrying in ${delay.inSeconds}s '
        '(attempt ${_retryAttempt + 1}/$_maxRetryAttempts).');

    _retryAttempt++;
    _retryTimer = Timer(delay, () {
      _retryTimer = null;
      if (mounted) _loadBannerAd();
    });
  }

  @override
  void dispose() {
    _retryTimer?.cancel();
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAdLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }

    return SafeArea(
      top: false,
      child: Container(
        width: double.infinity,
        height: _bannerAd!.size.height.toDouble(),
        decoration: const BoxDecoration(
          color: AppColors.surfaceContainerLow,
          border: Border(
            top: BorderSide(color: AppColors.outlineVariant, width: 0.5),
          ),
        ),
        alignment: Alignment.center,
        child: AdWidget(ad: _bannerAd!),
      ),
    );
  }
}
