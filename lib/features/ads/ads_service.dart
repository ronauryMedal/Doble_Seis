import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ads_config.dart';

/// Servicio central de anuncios (AdMob).
///
/// Filosofía: los anuncios son "best-effort". Si no hay internet o algo
/// falla, NUNCA debe romper la app — simplemente no se muestran anuncios.
/// Por eso todo va envuelto en try/catch y banderas de disponibilidad.
class AdsService {
  AdsService._();
  static final AdsService instance = AdsService._();

  bool _initialized = false;
  bool get isReady => _initialized && AdsConfig.isSupportedPlatform;

  InterstitialAd? _interstitial;
  bool _loadingInterstitial = false;
  int _finishedGames = 0;

  /// Inicializa el SDK. Seguro de llamar siempre; si falla, no pasa nada.
  Future<void> initialize() async {
    if (_initialized) return;
    if (!AdsConfig.isSupportedPlatform) return;
    try {
      await MobileAds.instance.initialize();
      _initialized = true;
      _preloadInterstitial();
    } on Object catch (e) {
      // Sin red o plataforma no disponible: seguimos sin anuncios.
      debugPrint('AdsService: init falló (se continúa sin anuncios): $e');
      _initialized = false;
    }
  }

  // -------------------------------------------------------------------------
  // Banner
  // -------------------------------------------------------------------------

  /// Crea y carga un banner adaptativo. Devuelve null si no se puede.
  /// El llamador es responsable de hacer `dispose()` del banner.
  Future<BannerAd?> createBanner({
    required void Function(BannerAd ad) onLoaded,
    void Function()? onFailed,
  }) async {
    if (!isReady) {
      onFailed?.call();
      return null;
    }
    try {
      final banner = BannerAd(
        adUnitId: AdsConfig.bannerUnitId,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) => onLoaded(ad as BannerAd),
          onAdFailedToLoad: (ad, error) {
            ad.dispose();
            debugPrint('AdsService: banner no cargó: $error');
            onFailed?.call();
          },
        ),
      );
      await banner.load();
      return banner;
    } on Object catch (e) {
      debugPrint('AdsService: error creando banner: $e');
      onFailed?.call();
      return null;
    }
  }

  // -------------------------------------------------------------------------
  // Intersticial
  // -------------------------------------------------------------------------

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
    if (!isReady) return;
    _finishedGames++;

    final shouldShow = _finishedGames % AdsConfig.interstitialEveryGames == 0;
    if (!shouldShow) {
      _preloadInterstitial();
      return;
    }

    final ad = _interstitial;
    if (ad == null) {
      // No hay anuncio listo (p. ej. sin internet): no pasa nada.
      _preloadInterstitial();
      return;
    }

    try {
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
