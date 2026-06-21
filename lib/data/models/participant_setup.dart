/// Configuración de un participante al crear la partida.
class ParticipantSetup {
  const ParticipantSetup({
    required this.name,
    this.memberNames = const [],
  });

  final String name;
  final List<String> memberNames;
}
