import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/player_colors.dart';
import '../../../data/repositories/game_repository.dart';
import '../../../domain/stats/game_stats.dart';

/// Estadísticas por equipo y por persona desde partidas ganadas.
class GameStatsScreen extends StatelessWidget {
  const GameStatsScreen({super.key, required this.repository});

  final GameRepository repository;

  @override
  Widget build(BuildContext context) {
    final stats = GameStatsCalculator.fromHistory(repository.loadHistory());

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Estadísticas'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          bottom: TabBar(
            indicatorColor: AppColors.neonCyan,
            labelColor: AppColors.neonCyan,
            unselectedLabelColor: AppColors.textMuted,
            tabs: const [
              Tab(text: 'Equipos'),
              Tab(text: 'Personas'),
            ],
          ),
        ),
        body: stats.totalGames == 0
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    'Juega y gana partidas para ver estadísticas.\n'
                    'En equipos, escribe el nombre de cada jugador al crear la partida.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textMuted,
                        ),
                  ),
                ),
              )
            : TabBarView(
                children: [
                  _TeamStatsTab(
                    records: stats.teams,
                    matchups: stats.teamMatchups,
                    totalGames: stats.totalGames,
                  ),
                  _PersonStatsTab(
                    records: stats.persons,
                    matchups: stats.personMatchups,
                    totalGames: stats.totalGames,
                  ),
                ],
              ),
      ),
    );
  }
}

class _TeamStatsTab extends StatelessWidget {
  const _TeamStatsTab({
    required this.records,
    required this.matchups,
    required this.totalGames,
  });

  final List<WinRecord> records;
  final List<HeadToHeadRecord> matchups;
  final int totalGames;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Victorias por nombre de equipo (ej. "Los Mejores")',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textMuted,
              ),
        ),
        const SizedBox(height: 16),
        Text(
          'Ranking · $totalGames partidas',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
        ),
        const SizedBox(height: 10),
        ...records.asMap().entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _WinRecordTile(
              rank: entry.key + 1,
              name: entry.value.name,
              wins: entry.value.wins,
              dominadas: entry.value.dominadas,
              accent: PlayerColors.forIndex(entry.key),
            ),
          );
        }),
        if (matchups.isNotEmpty) ...[
          const SizedBox(height: 20),
          _MatchupSection(matchups: matchups, accent: AppColors.neonCyan),
        ],
      ],
    );
  }
}

class _PersonStatsTab extends StatelessWidget {
  const _PersonStatsTab({
    required this.records,
    required this.matchups,
    required this.totalGames,
  });

  final List<PersonWinRecord> records;
  final List<HeadToHeadRecord> matchups;
  final int totalGames;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Ranking global: cada jugador suma victorias aunque cambie de equipo. '
          'Si ganó "Los Mejores" (Ronal + Saúl), los dos suman +1.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textMuted,
              ),
        ),
        const SizedBox(height: 16),
        Text(
          'Jugadores · $totalGames partidas',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
        ),
        const SizedBox(height: 10),
        if (records.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Text(
              'Sin datos de jugadores.\n'
              'Al crear la partida en modo equipos, escribe los nombres '
              'de Ronal, Saúl, etc.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textMuted,
                  ),
            ),
          )
        else
          ...records.asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _PersonRecordTile(
                rank: entry.key + 1,
                record: entry.value,
                accent: PlayerColors.forIndex(entry.key),
              ),
            );
          }),
        if (matchups.isNotEmpty) ...[
          const SizedBox(height: 20),
          _MatchupSection(matchups: matchups, accent: AppColors.neonAmber),
        ],
      ],
    );
  }
}

class _WinRecordTile extends StatelessWidget {
  const _WinRecordTile({
    required this.rank,
    required this.name,
    required this.wins,
    required this.dominadas,
    required this.accent,
  });

  final int rank;
  final String name;
  final int wins;
  final int dominadas;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.nightCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          _RankBadge(rank: rank, accent: accent),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          _WinCount(wins: wins, dominadas: dominadas, accent: accent),
        ],
      ),
    );
  }
}

class _PersonRecordTile extends StatelessWidget {
  const _PersonRecordTile({
    required this.rank,
    required this.record,
    required this.accent,
  });

  final int rank;
  final PersonWinRecord record;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.nightCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _RankBadge(rank: rank, accent: accent),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  record.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              _WinCount(
                wins: record.wins,
                dominadas: record.dominadas,
                accent: accent,
              ),
            ],
          ),
          if (record.teamsWonWith.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: record.teamsWonWith.map((team) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.neonCyan.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: AppColors.neonCyan.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Text(
                    team,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.neonCyan,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _RankBadge extends StatelessWidget {
  const _RankBadge({required this.rank, required this.accent});

  final int rank;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$rank',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: accent,
        ),
      ),
    );
  }
}

class _WinCount extends StatelessWidget {
  const _WinCount({
    required this.wins,
    required this.dominadas,
    required this.accent,
  });

  final int wins;
  final int dominadas;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '$wins ${wins == 1 ? 'victoria' : 'victorias'}',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: accent,
          ),
        ),
        if (dominadas > 0)
          Text(
            '$dominadas dominadas',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textMuted,
                  fontSize: 10,
                ),
          ),
      ],
    );
  }
}

class _MatchupSection extends StatelessWidget {
  const _MatchupSection({
    required this.matchups,
    required this.accent,
  });

  final List<HeadToHeadRecord> matchups;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cara a cara',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
        ),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 0.95,
          ),
          itemCount: matchups.length,
          itemBuilder: (context, index) {
            return _MatchupCard(
              record: matchups[index],
              accent: accent,
            );
          },
        ),
      ],
    );
  }
}

class _MatchupCard extends StatelessWidget {
  const _MatchupCard({
    required this.record,
    required this.accent,
  });

  final HeadToHeadRecord record;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.nightCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            record.nameA,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${record.winsA}',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w300,
                  color: record.winsA >= record.winsB
                      ? accent
                      : AppColors.textMuted,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  '—',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textMuted.withValues(alpha: 0.6),
                  ),
                ),
              ),
              Text(
                '${record.winsB}',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w300,
                  color: record.winsB > record.winsA
                      ? accent
                      : AppColors.textMuted,
                ),
              ),
            ],
          ),
          Text(
            record.nameB,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: record.ratioA,
              minHeight: 4,
              backgroundColor: Colors.white.withValues(alpha: 0.08),
              valueColor: AlwaysStoppedAnimation(accent),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${record.total} partidas',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 9,
                  color: AppColors.textMuted,
                ),
          ),
        ],
      ),
    );
  }
}
