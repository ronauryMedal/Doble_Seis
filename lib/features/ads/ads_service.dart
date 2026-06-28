import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ads_config.dart';

/// Servicio central de anuncios (AdMob).
///
/// Filosofía: los anuncios son "best-effort". Si no hay internet o algo
/// falla, NUNCA debe romper la app — simplemente no se muestran anuncios.
/// La inicialización es perezosa (no en el arranque) para no afectar el inicio.
class AdsService {
  AdsService._();
  static final AdsService instance = AdsService._();

  bool _initialized = false;
  bool _initFailed = false;
  Future<void>? _initFuture;

  bool get isReady => _initialized && !_initFailed && AdsConfig.isSupportedPlatform;

  /// Inicializa el SDK la primera vez que se necesita. Seguro de llamar siempre.
  Future<void> initialize() {
    if (_initFailed) return Future.value();
    if (_initialized) return Future.value();
    _initFuture ??= _doInitialize();
    return _initFuture!;
  }

  Future<void> _doInitialize() async {
    if (!AdsConfig.isSupportedPlatform) {
      _initFailed = true;
      return;
    }
    try {
      await MobileAds.instance.initialize();
      _initialized = true;
      _preloadInterstitial();
    } on Object catch (e) {
      _initFailed = true;
      debugPrint('AdsService: init falló (se continúa sin anuncios): $e');
    }
  }

  // -------------------------------------------------------------------------
  // Banner
  // -------------------------------------------------------------------------

  /// Crea y carga un banner. Devuelve null si no se puede.
  Future<BannerAd?> createBanner({
    required void Function(BannerAd ad) onLoaded,
    void Function()? onFailed,
  }) async {
    try {
      await initialize();
      if (!isReady) {
        onFailed?.call();
        return null;
      }

      final completer = Completer<BannerAd?>();
      final banner = BannerAd(
        adUnitId: AdsConfig.bannerUnitId,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            final loaded = ad as BannerAd;
            onLoaded(loaded);
            if (!completer.isCompleted) completer.complete(loaded);
          },
          onAdFailedToLoad: (ad, error) {
            ad.dispose();
            debugPrint('AdsService: banner no cargó: $error');
            onFailed?.call();
            if (!completer.isCompleted) completer.complete(null);
          },
        ),
      );
      await banner.load();
      return completer.future.timeout(
        const Duration(seconds: 8),
        onTimeout: () {
          onFailed?.call();
          return null;
        },
      );
    } on Object catch (e) {
      debugPrint('AdsService: error creando banner: $e');
      onFailed?.call();
      return null;
    }
  }

  // -------------------------------------------------------------------------
  // Intersticial
  // -------------------------------------------------------------------------

  InterstitialAd? _interstitial;
  bool _loadingInterstitial = false;
  int _finishedGames = 0;

  void _preloadInterstitial() {
    if (!isReady || _interstitial != null || _loadingInterstitial) return;
    _loadingInterstitial = true;
    try {
      InterstitialAd.load(
        adUnitId: AdsConfig.interstitialUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _interstitial = ad;
            _loadingInterstitial = false;
          },
          onAdFailedToLoad: (error) {
            _interstitial = null;
            _loadingInterstitial = false;
            debugPrint('AdsService: intersticial no cargó: $error');
          },
        ),
      );
    } on Object catch (e) {
      _loadingInterstitial = false;
      debugPrint('AdsService: error cargando intersticial: $e');
    }
  }

  /// Llamar al terminar una partida. Muestra un intersticial cada
  /// [AdsConfig.interstitialEveryGames] partidas, si hay uno cargado.
  Future<void> onGameFinished() async {
    try {
      await initialize();
      if (!isReady) return;

      _finishedGames++;

      final shouldShow = _finishedGames % AdsConfig.interstitialEveryGames == 0;
      if (!shouldShow) {
        _preloadInterstitial();
        return;
      }

      final ad = _interstitial;
      if (ad == null) {
        _preloadInterstitial();
        return;
      }

      ad.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _interstitial = null;
          _preloadInterstitial();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _interstitial = null;
          _preloadInterstitial();
        },
      );
      await ad.show();
    } on Object catch (e) {
      debugPrint('AdsService: error mostrando intersticial: $e');
      _interstitial = null;
      _preloadInterstitial();
    }
  }
}
