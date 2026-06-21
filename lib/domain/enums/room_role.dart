/// Rol del usuario en una sala en vivo (futuro Firebase/Supabase).
enum RoomRole {
  /// Único que puede modificar el marcador.
  leader,

  /// Solo lectura — sigue la partida en tiempo real.
  spectator,
}
