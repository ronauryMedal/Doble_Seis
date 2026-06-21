/// Cómo se sincroniza el marcador entre dispositivos.
enum LiveRoomConnectionMode {
  /// Solo este celular — sin compartir.
  offline('Solo local'),

  /// Misma red WiFi — anfitrión sirve el marcador.
  localWifi('WiFi local'),

  /// Internet — Firebase / Supabase (fase 2).
  cloud('Nube');

  const LiveRoomConnectionMode(this.label);
  final String label;

  bool get isAvailable => this != LiveRoomConnectionMode.cloud;
}
