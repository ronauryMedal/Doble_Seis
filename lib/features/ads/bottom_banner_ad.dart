import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ads_config.dart';
import 'ads_service.dart';

/// Banner inferior que aparece "a veces" (según [AdsConfig.bannerShowChance]).
///
/// Si no hay internet o el anuncio no carga, no ocupa espacio (se colapsa),
/// así que nunca estorba ni rompe el diseño.
class BottomBannerAd extends StatefulWidget {
  const BottomBannerAd({super.key});

  @override
  State<BottomBannerAd> createState() => _BottomBannerAdState();
}

class _BottomBannerAdState extends State<BottomBannerAd> {
  BannerAd? _banner;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _maybeLoad();
  }

  void _maybeLoad() {
    if (!AdsService.instance.isReady) return;
    // "A veces": decisión aleatoria por sesión de pantalla.
    if (Random().nextDouble() > AdsConfig.bannerShowChance) return;

    AdsService.instance.createBanner(
      onLoaded: (ad) {
        if (!mounted) {
          ad.dispose();
          return;
        }
        setState(() {
          _banner = ad;
          _loaded = true;
        });
      },
      onFailed: () {
        if (mounted) setState(() => _loaded = false);
      },
    );
  }

  @override
  void dispose() {
    _banner?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final banner = _banner;
    if (!_loaded || banner == null) {
      return const SizedBox.shrink();
    }

    return SafeArea(
      top: false,
      child: SizedBox(
        width: banner.size.width.toDouble(),
        height: banner.size.height.toDouble(),
        child: AdWidget(ad: banner),
      ),
    );
  }
}
