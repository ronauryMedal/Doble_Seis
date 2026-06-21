import '../../data/models/game_history_entry.dart';
import '../../domain/enums/game_mode.dart';

/// Victorias y dominadas acumuladas (equipos).
class WinRecord {
  const WinRecord({
    required this.name,
    required this.wins,
    required this.dominadas,
  });

  final String name;
  final int wins;
  final int dominadas;
}

/// Victorias globales por jugador — suma en todos los equipos donde participó.
class PersonWinRecord {
  const PersonWinRecord({
    required this.name,
    required this.wins,
    required this.dominadas,
    required this.teamsWonWith,
  });

  final String name;
  final int wins;
  final int dominadas;
  /// Equipos con los que ganó al menos una partida (ej. "Los Mejores").
  final List<String> teamsWonWith;
}

/// Enfrentamiento directo entre dos equipos o dos personas.
class HeadToHeadRecord {
  const HeadToHeadRecord({
    required this.nameA,
    required this.nameB,
    required this.winsA,
    required this.winsB,
  });

  final String nameA;
  final String nameB;
  final int winsA;
  final int winsB;

  int get total => winsA + winsB;

  double get ratioA => total == 0 ? 0.5 : winsA / total;
}

/// Resumen calculado desde el historial de partidas ganadas.
class GameStatsSummary {
  const GameStatsSummary({
    required this.teams,
    required this.persons,
    required this.teamMatchups,
    required this.personMatchups,
    required this.totalGames,
  });

  final List<WinRecord> teams;
  final List<PersonWinRecord> persons;
  final List<HeadToHeadRecord> teamMatchups;
  final List<HeadToHeadRecord> personMatchups;
  final int totalGames;

  static const empty = GameStatsSummary(
    teams: [],
    persons: [],
    teamMatchups: [],
    personMatchups: [],
    totalGames: 0,
  );
}

/// Agrega estadísticas por equipo, persona y enfrentamientos.
class GameStatsCalculator {
  GameStatsCalculator._();

  static GameStatsSummary fromHistory(List<GameHistoryEntry> history) {
    if (history.isEmpty) return GameStatsSummary.empty;

    final teamWins = <String, int>{};
    final teamDominadas = <String, int>{};
    final personWins = <String, int>{};
    final personDominadas = <String, int>{};
    final personTeams = <String, Set<String>>{};
    final teamH2H = <String, _H2HPair>{};
    final personH2H = <String, _H2HPair>{};

    for (final entry in history) {
      _countDominadas(entry, teamDominadas, personDominadas);
      _creditWinner(entry, teamWins, personWins, personTeams);
      _recordMatchups(entry, teamH2H, personH2H);
    }

    return GameStatsSummary(
      totalGames: history.length,
      teams: _sortedTeamRecords(teamWins, teamDominadas),
      persons: _sortedPersonRecords(personWins, personDominadas, personTeams),
      teamMatchups: _sortedH2H(teamH2H),
      personMatchups: _sortedH2H(personH2H),
    );
  }

  static void _countDominadas(
    GameHistoryEntry entry,
    Map<String, int> teamDom,
    Map<String, int> personDom,
  ) {
    for (final event in entry.events) {
      final participant = _findParticipant(entry, event.teamId);
      if (participant == null) continue;

      if (entry.mode == GameMode.teamVsTeam) {
        teamDom[participant.name] = (teamDom[participant.name] ?? 0) + 1;
      }

      if (entry.mode == GameMode.individual) {
        personDom[participant.name] =
            (personDom[participant.name] ?? 0) + 1;
      }
    }
  }

  static void _creditWinner(
    GameHistoryEntry entry,
    Map<String, int> teamWins,
    Map<String, int> personWins,
    Map<String, Set<String>> personTeams,
  ) {
    final winner = _findParticipant(entry, entry.winnerId);
    if (winner == null) return;

    if (entry.mode == GameMode.teamVsTeam) {
      // 1 victoria para el nombre del equipo ("Los Mejores").
      teamWins[winner.name] = (teamWins[winner.name] ?? 0) + 1;

      // 1 victoria para cada integrante (Ronal, Saúl).
      _eachMember(winner, (memberName) {
        personWins[memberName] = (personWins[memberName] ?? 0) + 1;
        personTeams
            .putIfAbsent(memberName, () => {})
            .add(winner.name);
      });
    } else {
      personWins[winner.name] = (personWins[winner.name] ?? 0) + 1;
    }
  }

  static void _recordMatchups(
    GameHistoryEntry entry,
    Map<String, _H2HPair> teamH2H,
    Map<String, _H2HPair> personH2H,
  ) {
    final winner = _findParticipant(entry, entry.winnerId);
    if (winner == null) return;

    for (final other in entry.finalScores) {
      if (other.id == entry.winnerId) continue;

      if (entry.mode == GameMode.teamVsTeam) {
        _addH2H(teamH2H, winner.name, other.name);
      } else {
        _addH2H(personH2H, winner.name, other.name);
      }
    }
  }

  static void _addH2H(
    Map<String, _H2HPair> map,
    String winner,
    String loser,
  ) {
    final sorted = [winner, loser]..sort();
    final key = '${sorted[0]}\u0000${sorted[1]}';
    final pair = map.putIfAbsent(
      key,
      () => _H2HPair(nameA: sorted[0], nameB: sorted[1]),
    );
    pair.addWin(winner);
  }

  /// Solo integrantes con nombre — no el nombre del equipo.
  static void _eachMember(
    PlayerScoreRef team,
    void Function(String memberName) fn,
  ) {
    final members = team.memberNames
        .map((m) => m.trim())
        .where((m) => m.isNotEmpty)
        .toList();
    for (final m in members) {
      fn(m);
    }
  }

  static PlayerScoreRef? _findParticipant(
    GameHistoryEntry entry,
    String id,
  ) {
    for (final p in entry.finalScores) {
      if (p.id == id) {
        return PlayerScoreRef(p.name, p.memberNames);
      }
    }
    return null;
  }

  static List<WinRecord> _sortedTeamRecords(
    Map<String, int> wins,
    Map<String, int> dominadas,
  ) {
    final names = {...wins.keys, ...dominadas.keys};
    return names
        .map(
          (name) => WinRecord(
            name: name,
            wins: wins[name] ?? 0,
            dominadas: dominadas[name] ?? 0,
          ),
        )
        .toList()
      ..sort((a, b) {
        final byWins = b.wins.compareTo(a.wins);
        if (byWins != 0) return byWins;
        return b.dominadas.compareTo(a.dominadas);
      });
  }

  static List<PersonWinRecord> _sortedPersonRecords(
    Map<String, int> wins,
    Map<String, int> dominadas,
    Map<String, Set<String>> teams,
  ) {
    final names = {...wins.keys, ...dominadas.keys, ...teams.keys};
    return names
        .map(
          (name) => PersonWinRecord(
            name: name,
            wins: wins[name] ?? 0,
            dominadas: dominadas[name] ?? 0,
            teamsWonWith: (teams[name]?.toList() ?? [])..sort(),
          ),
        )
        .where((r) => r.wins > 0 || r.dominadas > 0)
        .toList()
      ..sort((a, b) {
        final byWins = b.wins.compareTo(a.wins);
        if (byWins != 0) return byWins;
        return b.dominadas.compareTo(a.dominadas);
      });
  }

  static List<HeadToHeadRecord> _sortedH2H(Map<String, _H2HPair> map) {
    return map.values
        .map(
          (p) => HeadToHeadRecord(
            nameA: p.nameA,
            nameB: p.nameB,
            winsA: p.winsA,
            winsB: p.winsB,
          ),
        )
        .toList()
      ..sort((a, b) => b.total.compareTo(a.total));
  }
}

class PlayerScoreRef {
  const PlayerScoreRef(this.name, this.memberNames);

  final String name;
  final List<String> memberNames;
}

class _H2HPair {
  _H2HPair({required this.nameA, required this.nameB});

  final String nameA;
  final String nameB;
  int winsA = 0;
  int winsB = 0;

  void addWin(String winner) {
    if (winner == nameA) {
      winsA++;
    } else if (winner == nameB) {
      winsB++;
    }
  }
}
