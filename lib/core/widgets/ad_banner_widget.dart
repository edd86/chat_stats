import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../constants/ad_constants.dart';
import '../theme/app_colors.dart';

class AdBannerWidget extends StatefulWidget {
  const AdBannerWidget({super.key});

  @override
  State<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends State<AdBannerWidget> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_bannerAd == null) {
      _loadBannerAd();
    }
  }

  Future<void> _loadBannerAd() async {
    if (kIsWeb ||
        (defaultTargetPlatform != TargetPlatform.android &&
            defaultTargetPlatform != TargetPlatform.iOS)) {
      return;
    }

    try {
      final double width = MediaQuery.sizeOf(context).width;
      final Orientation orientation = MediaQuery.orientationOf(context);
      final AdSize size =
          await AdSize.getLargeAnchoredAdaptiveBannerAdSizeWithOrientation(
            orientation,
            width.truncate(),
          ) ??
          AdSize.banner;

      if (!mounted) return;

      final banner = BannerAd(
        adUnitId: AdConstants.bannerAdUnitId,
        size: size,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            if (mounted) {
              setState(() {
                _isAdLoaded = true;
              });
            }
          },
          onAdFailedToLoad: (ad, error) {
            debugPrint(
              'BannerAd failed to load (${error.code}): ${error.message}',
            );
            ad.dispose();
            if (mounted) {
              setState(() {
                _isAdLoaded = false;
              });
            }
          },
        ),
      );

      _bannerAd = banner;
      await banner.load();
    } catch (e) {
      debugPrint('Error loading banner ad: $e');
    }
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAdLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }

    return Container(
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
    );
  }
}
