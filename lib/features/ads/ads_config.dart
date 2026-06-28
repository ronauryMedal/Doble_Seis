import 'dart:io';

import 'package:flutter/foundation.dart';

/// Configuración central de AdMob.
///
/// Por defecto usa los IDs de PRUEBA oficiales de Google, para que la app
/// funcione sin riesgo durante el desarrollo. Cuando tengas tu cuenta de
/// AdMob, reemplaza los valores de [_prodAndroidAppId], [_prodBannerAndroid]
/// e [_prodInterstitialAndroid] por los tuyos y pon [useTestAds] en `false`.
///
/// IMPORTANTE: nunca toques tus propios anuncios reales mientras pruebas
/// (puede suspender tu cuenta). Usa siempre los de prueba en desarrollo.
class AdsConfig {
  AdsConfig._();

  /// `false` = usa tus IDs reales de AdMob (cuando estén configurados).
  static const bool useTestAds = false;

  // --- IDs de PRUEBA oficiales de Google (no generan ingresos) ---
  static const String _testAndroidAppId =
      'ca-app-pub-3940256099942544~3347511713';
  static const String _testBannerAndroid =
      'ca-app-pub-3940256099942544/6300978111';
  static const String _testInterstitialAndroid =
      'ca-app-pub-3940256099942544/1033173712';

  static const String _testIosAppId =
      'ca-app-pub-3940256099942544~1458002511';
  static const String _testBannerIos =
      'ca-app-pub-3940256099942544/2934735716';
  static const String _testInterstitialIos =
      'ca-app-pub-3940256099942544/4411468910';

  // --- IDs REALES — Doble Seis (AdMob) ---
  // App ID también debe ir en AndroidManifest.xml.
  static const String _prodAndroidAppId =
      'ca-app-pub-6942175829686408~4430419341';
  static const String _prodBannerAndroid =
      'ca-app-pub-6942175829686408/1748415689';
  static const String _prodInterstitialAndroid =
      'ca-app-pub-6942175829686408/8122252349';

  static const String _prodIosAppId =
      'ca-app-pub-0000000000000000~0000000000';
  static const String _prodBannerIos =
      'ca-app-pub-0000000000000000/0000000000';
  static const String _prodInterstitialIos =
      'ca-app-pub-0000000000000000/0000000000';

  static bool get _isAndroid => !kIsWeb && Platform.isAndroid;
  static bool get _isIOS => !kIsWeb && Platform.isIOS;

  /// Probabilidad de mostrar el banner inferior (0.0 a 1.0).
  /// 0.6 = aparece ~60% de las partidas, para no saturar.
  static const double bannerShowChance = 0.6;

  /// Mínimo de partidas terminadas entre intersticiales (evita spam).
  static const int interstitialEveryGames = 2;

  static String get appId {
    if (_isAndroid) return useTestAds ? _testAndroidAppId : _prodAndroidAppId;
    if (_isIOS) return useTestAds ? _testIosAppId : _prodIosAppId;
    return '';
  }

  static String get bannerUnitId {
    if (_isAndroid) return useTestAds ? _testBannerAndroid : _prodBannerAndroid;
    if (_isIOS) return useTestAds ? _testBannerIos : _prodBannerIos;
    return '';
  }

  static bool get _hasProdInterstitialAndroid =>
      _prodInterstitialAndroid.isNotEmpty;

  static String get interstitialUnitId {
    if (_isAndroid) {
      if (useTestAds || !_hasProdInterstitialAndroid) {
        return _testInterstitialAndroid;
      }
      return _prodInterstitialAndroid;
    }
    if (_isIOS) {
      return useTestAds ? _testInterstitialIos : _prodInterstitialIos;
    }
    return '';
  }

  /// Plataformas donde AdMob está soportado por este plugin.
  static bool get isSupportedPlatform => _isAndroid || _isIOS;
}
