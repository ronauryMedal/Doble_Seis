import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_tokens.dart';
import '../../widgets/app_background.dart';
import '../../widgets/app_logo.dart';

/// Guía de uso ilustrada — explica qué es la app y cómo usarla paso a paso.
///
/// Cada paso muestra una ilustración. Si existe una captura real en
/// `assets/images/tutorial/<image>` se usa esa; si no, se dibuja un
/// mini-mockup con widgets para que la guía funcione sin imágenes externas.
/// Secciones de la guía.
class _GuideSection {
  const _GuideSection(this.label, this.icon, this.color);
  final String label;
  final IconData icon;
  final Color color;
}

const _GuideSection _secBefore =
    _GuideSection('Antes de empezar', Icons.tune_rounded, AppColors.neonCyan);
const _GuideSection _secDuring = _GuideSection(
    'Durante la partida', Icons.sports_esports_rounded, AppColors.neonAmber);
const _GuideSection _secAfter =
    _GuideSection('Después de jugar', Icons.insights_rounded, AppColors.neonCyan);

/// Datos de un paso de la guía (compartidos por la vista lista y paginada).
class _GuideStepData {
  const _GuideStepData({
    required this.section,
    required this.accent,
    required this.title,
    required this.description,
    required this.imageName,
    required this.mockup,
    this.tips = const [],
  });

  final _GuideSection section;
  final Color accent;
  final String title;
  final String description;
  final String imageName;
  final Widget mockup;
  final List<String> tips;
}

const List<_GuideStepData> _steps = [
  _GuideStepData(
    section: _secBefore,
    accent: AppColors.neonCyan,
    title: 'Elige el modo de juego',
    description: 'Define cómo se reparten los puntos en la partida.',
    tips: [
      'Equipo vs Equipo: dos bandos (A y B). Ideal para parejas.',
      'Individual: cada jugador lleva su propio puntaje (2 a 6).',
    ],
    imageName: 'guide_mode.png',
    mockup: _ModeMockup(),
  ),
  _GuideStepData(
    section: _secBefore,
    accent: AppColors.neonCyan,
    title: 'Cantidad de jugadores y nombres',
    description:
        'Ajusta cuántos juegan con los botones – / + y personaliza los '
        'nombres para identificarlos en el marcador.',
    tips: [
      'En equipos: 1 o 2 jugadores por equipo y nombre de cada equipo.',
      'Individual: de 2 a 6 jugadores, cada uno con su color.',
    ],
    imageName: 'guide_players.png',
    mockup: _PlayersMockup(),
  ),
  _GuideStepData(
    section: _secBefore,
    accent: AppColors.neonAmber,
    title: 'Define la meta de puntos',
    description:
        'Elige un atajo (100, 150, 200) o escribe un puntaje manual. '
        'Gana quien llegue primero a esa meta.',
    imageName: 'guide_target.png',
    mockup: _TargetMockup(),
  ),
  _GuideStepData(
    section: _secBefore,
    accent: AppColors.neonAmber,
    title: 'Compartir el marcador',
    description:
        'Decide si la partida se ve solo en tu celular o se comparte en '
        'vivo con otros.',
    tips: [
      'Solo local: el marcador vive únicamente en tu teléfono.',
      'WiFi local: tú anotas y los demás ven el marcador en la misma red '
          'WiFi escaneando tu QR.',
      'Nube: sincronización por internet — próximamente.',
    ],
    imageName: 'guide_connection.png',
    mockup: _ConnectionMockup(),
  ),
  _GuideStepData(
    section: _secBefore,
    accent: AppColors.neonAmber,
    title: 'Unirme como espectador',
    description:
        'Si otra persona lleva el marcador, no creas partida: toca «Unirme '
        'como espectador» y escanea su QR (o escribe IP y código). Verás el '
        'juego en vivo en modo solo lectura.',
    tips: [
      'Ambos celulares deben estar en la misma red WiFi.',
      'El espectador no puede anotar; solo observa.',
    ],
    imageName: 'guide_spectator.png',
    mockup: _SpectatorMockup(),
  ),
  _GuideStepData(
    section: _secDuring,
    accent: AppColors.neonCyan,
    title: 'La barra superior',
    description: 'Arriba ves el modo y la meta, más accesos rápidos.',
    tips: [
      'Reloj de tiro: cronómetro opcional; tócalo para iniciar/pausar.',
      'Bitácora: abre el historial de anotaciones de la mano.',
      'Terminar: cierra la partida; pide confirmación si hay juego en curso.',
    ],
    imageName: 'guide_toolbar.png',
    mockup: _ToolbarMockup(),
  ),
  _GuideStepData(
    section: _secDuring,
    accent: AppColors.neonCyan,
    title: 'Elige a quién anotar',
    description:
        'Toca la tarjeta del equipo o jugador para seleccionarlo (queda '
        'resaltado). Quien va ganando se marca como líder.',
    imageName: 'guide_select.png',
    mockup: _SelectMockup(),
  ),
  _GuideStepData(
    section: _secDuring,
    accent: AppColors.neonAmber,
    title: 'Anota los puntos',
    description:
        'Con el seleccionado, usa el teclado: el atajo +30 suma una mano de '
        'dominó, o escribe un número y confirma con ✓.',
    tips: [
      'El marcador se actualiza al instante.',
      'El botón ⌫ borra el último dígito escrito.',
    ],
    imageName: 'guide_score.png',
    mockup: _ScoreMockup(),
  ),
  _GuideStepData(
    section: _secDuring,
    accent: AppColors.capicua,
    title: 'Eventos especiales',
    description:
        'Antes de anotar, activa Capicúa o Tranque para esa jugada; quedan '
        'registrados en la bitácora.',
    tips: [
      'Capicúa: activa el chip y luego ingresa los puntos.',
      'Tranque: márcalo cuando el juego se cierra.',
    ],
    imageName: 'guide_events.png',
    mockup: _EventsMockup(),
  ),
  _GuideStepData(
    section: _secDuring,
    accent: AppColors.neonRose,
    title: 'Corrige un error',
    description:
        'Toca la barra «Anotaciones» para abrir la bitácora. Desliza o usa el '
        'botón de borrar para eliminar una anotación; el total se recalcula solo.',
    imageName: 'guide_fix.png',
    mockup: _FixMockup(),
  ),
  _GuideStepData(
    section: _secDuring,
    accent: AppColors.neonAmber,
    title: 'Comparte en vivo (WiFi)',
    description:
        'Si creaste la partida en modo WiFi local, toca el banner del QR para '
        'mostrarlo. Los demás lo escanean y siguen el marcador.',
    tips: [
      'Mantén pulsado el banner para copiar la IP y el código.',
      'Todos deben estar en la misma red WiFi.',
    ],
    imageName: 'guide_share.png',
    mockup: _ShareMockup(),
  ),
  _GuideStepData(
    section: _secDuring,
    accent: AppColors.capicua,
    title: 'Fin de la partida',
    description:
        'Al alcanzar la meta aparece la celebración del ganador. Puedes jugar '
        'revancha o cambiar de jugadores.',
    tips: [
      'Si sales con la partida en curso, se anula y no se guarda.',
    ],
    imageName: 'guide_end.png',
    mockup: _EndMockup(),
  ),
  _GuideStepData(
    section: _secAfter,
    accent: AppColors.neonCyan,
    title: 'Historial y estadísticas',
    description:
        'Las partidas terminadas se guardan. Desde el menú lateral revisa '
        'partidas ganadas y estadísticas de equipos y jugadores.',
    imageName: 'guide_stats.png',
    mockup: _StatsMockup(),
  ),
];

/// Guía de uso ilustrada con dos modos: lista completa o paso a paso.
class GuideScreen extends StatefulWidget {
  const GuideScreen({super.key, this.onFinish});

  /// Si se provee, la guía se muestra como tutorial de primera vez:
  /// agrega «Omitir» y un botón final. Si es null, es la pantalla del menú.
  final VoidCallback? onFinish;

  @override
  State<GuideScreen> createState() => _GuideScreenState();
}

class _GuideScreenState extends State<GuideScreen> {
  bool _pageMode = false;

  bool get _isFirstRun => widget.onFinish != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cómo usar la app'),
        automaticallyImplyLeading: !_isFirstRun,
        actions: _isFirstRun
            ? [
                TextButton(
                  onPressed: widget.onFinish,
                  child: const Text(
                    'Omitir',
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                ),
              ]
            : null,
      ),
      body: AppBackground(
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.sm,
                  AppSpacing.md,
                  AppSpacing.sm,
                ),
                child: _ViewModeToggle(
                  pageMode: _pageMode,
                  onChanged: (value) => setState(() => _pageMode = value),
                ),
              ),
              Expanded(
                child: _pageMode
                    ? _PagedGuide(
                        isFirstRun: _isFirstRun,
                        onFinish: widget.onFinish,
                      )
                    : _ListGuide(
                        isFirstRun: _isFirstRun,
                        onFinish: widget.onFinish,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Selector entre «Todo junto» (lista) y «Paso a paso» (paginado).
class _ViewModeToggle extends StatelessWidget {
  const _ViewModeToggle({required this.pageMode, required this.onChanged});

  final bool pageMode;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<bool>(
      segments: const [
        ButtonSegment(
          value: false,
          label: Text('Todo junto'),
          icon: Icon(Icons.view_agenda_outlined, size: 18),
        ),
        ButtonSegment(
          value: true,
          label: Text('Paso a paso'),
          icon: Icon(Icons.auto_stories_outlined, size: 18),
        ),
      ],
      selected: {pageMode},
      onSelectionChanged: (selection) => onChanged(selection.first),
      style: ButtonStyle(
        textStyle: WidgetStatePropertyAll(
          Theme.of(context).textTheme.bodySmall,
        ),
      ),
    );
  }
}

/// Vista "Todo junto": lista desplazable con todos los pasos.
class _ListGuide extends StatelessWidget {
  const _ListGuide({required this.isFirstRun, this.onFinish});

  final bool isFirstRun;
  final VoidCallback? onFinish;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[const _IntroHeader()];

    _GuideSection? current;
    for (var i = 0; i < _steps.length; i++) {
      final step = _steps[i];
      if (!identical(step.section, current)) {
        current = step.section;
        children.add(_SectionHeader(
          icon: current.icon,
          label: current.label,
          color: current.color,
        ));
      }
      children.add(_GuideStep(
        index: i + 1,
        accent: step.accent,
        title: step.title,
        description: step.description,
        tips: step.tips,
        imageName: step.imageName,
        mockup: step.mockup,
        isLast: i == _steps.length - 1,
      ));
    }

    if (isFirstRun) {
      children
        ..add(const SizedBox(height: 24))
        ..add(
          FilledButton(
            onPressed: onFinish,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.neonCyan,
              foregroundColor: AppColors.nightBackground,
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              '¡Entendido, empezar!',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
      children: children,
    );
  }
}

/// Vista "Paso a paso": una pantalla por paso con navegación.
class _PagedGuide extends StatefulWidget {
  const _PagedGuide({required this.isFirstRun, this.onFinish});

  final bool isFirstRun;
  final VoidCallback? onFinish;

  @override
  State<_PagedGuide> createState() => _PagedGuideState();
}

class _PagedGuideState extends State<_PagedGuide> {
  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_page >= _steps.length - 1) {
      if (widget.isFirstRun) {
        widget.onFinish?.call();
      } else {
        Navigator.of(context).maybePop();
      }
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  void _back() {
    if (_page == 0) return;
    _controller.previousPage(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _page == _steps.length - 1;

    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _controller,
            itemCount: _steps.length,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (context, index) => _GuidePage(
              data: _steps[index],
              index: index + 1,
              total: _steps.length,
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_steps.length, (i) {
            final active = i == _page;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: active ? 18 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: active
                    ? AppColors.neonCyan
                    : Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
          child: Row(
            children: [
              if (_page > 0)
                Expanded(
                  child: OutlinedButton(
                    onPressed: _back,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      side: BorderSide(
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text('Atrás'),
                  ),
                ),
              if (_page > 0) const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: FilledButton(
                  onPressed: _next,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.neonCyan,
                    foregroundColor: AppColors.nightBackground,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    isLast
                        ? (widget.isFirstRun ? '¡Entendido!' : 'Listo')
                        : 'Siguiente',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Una página individual del modo "Paso a paso".
class _GuidePage extends StatelessWidget {
  const _GuidePage({
    required this.data,
    required this.index,
    required this.total,
  });

  final _GuideStepData data;
  final int index;
  final int total;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(data.section.icon, size: 16, color: data.section.color),
              const SizedBox(width: 6),
              Text(
                data.section.label.toUpperCase(),
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: data.section.color,
                      letterSpacing: 1.5,
                      fontSize: 11,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: data.accent.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: data.accent.withValues(alpha: 0.5)),
                ),
                child: Text(
                  '$index',
                  style: TextStyle(
                    color: data.accent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Paso $index de $total',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textMuted,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            data.title,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontSize: 24,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            data.description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
          ),
          if (data.tips.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...data.tips.map((tip) => _TipRow(text: tip, accent: data.accent)),
          ],
          const SizedBox(height: 20),
          _IllustrationFrame(
            accent: data.accent,
            imageName: data.imageName,
            mockup: data.mockup,
          ),
        ],
      ),
    );
  }
}

class _IntroHeader extends StatelessWidget {
  const _IntroHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.neonCyan.withValues(alpha: 0.12),
            AppColors.neonAmber.withValues(alpha: 0.06),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        children: [
          const AppLogo(showName: false, height: 84),
          const SizedBox(height: 16),
          Text(
            AppConstants.appName,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 8),
          Text(
            AppConstants.appSlogan,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
          ),
          const SizedBox(height: 16),
          Text(
            'Doble Seis es tu marcador de dominó: crea la partida, anota los '
            'puntos y compártela en vivo. Sigue esta guía para dominarla.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textMuted,
                  height: 1.5,
                ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 28, 0, 16),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Text(
            label.toUpperCase(),
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: color,
                  letterSpacing: 1.5,
                  fontSize: 12,
                ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Divider(color: color.withValues(alpha: 0.18)),
          ),
        ],
      ),
    );
  }
}

class _GuideStep extends StatelessWidget {
  const _GuideStep({
    required this.index,
    required this.accent,
    required this.title,
    required this.description,
    required this.imageName,
    required this.mockup,
    this.tips = const [],
    this.isLast = false,
  });

  final int index;
  final Color accent;
  final String title;
  final String description;
  final String imageName;
  final Widget mockup;
  final List<String> tips;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.nightCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: accent.withValues(alpha: 0.5)),
                ),
                child: Text(
                  '$index',
                  style: TextStyle(
                    color: accent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
          ),
          if (tips.isNotEmpty) ...[
            const SizedBox(height: 10),
            ...tips.map((tip) => _TipRow(text: tip, accent: accent)),
          ],
          const SizedBox(height: 14),
          _IllustrationFrame(
            accent: accent,
            imageName: imageName,
            mockup: mockup,
          ),
        ],
      ),
    );
  }
}

class _TipRow extends StatelessWidget {
  const _TipRow({required this.text, required this.accent});

  final String text;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: accent,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.45,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Marco tipo "pantalla". Usa la captura real si existe; si no, el mockup.
class _IllustrationFrame extends StatelessWidget {
  const _IllustrationFrame({
    required this.accent,
    required this.imageName,
    required this.mockup,
  });

  final Color accent;
  final String imageName;
  final Widget mockup;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.nightSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withValues(alpha: 0.18)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        'assets/images/tutorial/$imageName',
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (_, _, _) => Padding(
          padding: const EdgeInsets.all(14),
          child: mockup,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Mini-mockups (respaldo cuando no hay capturas reales)
// ---------------------------------------------------------------------------

class _MockChip extends StatelessWidget {
  const _MockChip({
    required this.label,
    required this.color,
    this.filled = false,
  });

  final String label;
  final Color color;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: filled ? color.withValues(alpha: 0.18) : AppColors.nightCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: filled
              ? color.withValues(alpha: 0.6)
              : Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: filled ? color : AppColors.textSecondary,
          fontSize: 12,
          fontWeight: filled ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
    );
  }
}

class _ModeMockup extends StatelessWidget {
  const _ModeMockup();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(
          child: _MockChip(
            label: 'Equipo vs Equipo',
            color: AppColors.neonCyan,
            filled: true,
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: _MockChip(label: 'Individual', color: AppColors.neonCyan),
        ),
      ],
    );
  }
}

class _PlayersMockup extends StatelessWidget {
  const _PlayersMockup();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.remove_circle_outline,
                color: AppColors.neonCyan, size: 26),
            Container(
              width: 54,
              margin: const EdgeInsets.symmetric(horizontal: 12),
              padding: const EdgeInsets.symmetric(vertical: 8),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.nightCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
              ),
              child: const Text(
                '4',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const Icon(Icons.add_circle_outline,
                color: AppColors.neonCyan, size: 26),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: const [
            Expanded(child: _MockChip(label: 'Jugador 1', color: AppColors.teamA)),
            SizedBox(width: 8),
            Expanded(child: _MockChip(label: 'Jugador 2', color: AppColors.teamB)),
          ],
        ),
      ],
    );
  }
}

class _TargetMockup extends StatelessWidget {
  const _TargetMockup();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(child: _MockChip(label: '100', color: AppColors.neonAmber, filled: true)),
        SizedBox(width: 8),
        Expanded(child: _MockChip(label: '150', color: AppColors.neonAmber)),
        SizedBox(width: 8),
        Expanded(child: _MockChip(label: '200', color: AppColors.neonAmber)),
      ],
    );
  }
}

class _ConnectionMockup extends StatelessWidget {
  const _ConnectionMockup();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: _MockChip(label: 'Solo local', color: AppColors.neonCyan),
        ),
        const SizedBox(width: 8),
        const Expanded(
          child: _MockChip(
            label: 'WiFi local',
            color: AppColors.neonCyan,
            filled: true,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            children: const [
              _MockChip(label: 'Nube', color: AppColors.textMuted),
              SizedBox(height: 2),
              Text(
                'Pronto',
                style: TextStyle(fontSize: 9, color: AppColors.textMuted),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SpectatorMockup extends StatelessWidget {
  const _SpectatorMockup();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.neonAmber.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.neonAmber.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.neonAmber.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.qr_code_scanner_rounded,
              color: AppColors.neonAmber,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Unirme como espectador',
                  style: TextStyle(
                    color: AppColors.neonAmber,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Escanea el QR del anfitrión',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ToolbarMockup extends StatelessWidget {
  const _ToolbarMockup();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'DOBLE SEIS',
                style: TextStyle(
                  fontSize: 9,
                  letterSpacing: 2,
                  color: AppColors.textMuted,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Individual · a 100',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        _iconBox(Icons.timer_outlined, AppColors.neonCyan),
        const SizedBox(width: 6),
        _iconBox(Icons.history_rounded, AppColors.textSecondary),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.neonRose.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.neonRose.withValues(alpha: 0.45)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.flag_rounded, size: 13, color: AppColors.neonRose),
              SizedBox(width: 4),
              Text(
                'Terminar',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.neonRose,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _iconBox(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: AppColors.nightCard,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Icon(icon, size: 16, color: color),
    );
  }
}

class _SelectMockup extends StatelessWidget {
  const _SelectMockup();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _scorePanel('Equipo A', '75', AppColors.teamA, true)),
        const SizedBox(width: 10),
        Expanded(child: _scorePanel('Equipo B', '60', AppColors.teamB, false)),
      ],
    );
  }

  Widget _scorePanel(String name, String score, Color color, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: active ? 0.16 : 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: active ? 0.6 : 0.2),
          width: active ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          if (active)
            const Padding(
              padding: EdgeInsets.only(bottom: 2),
              child: Icon(Icons.emoji_events_rounded,
                  size: 14, color: AppColors.neonAmber),
            ),
          Text(name, style: TextStyle(color: color, fontSize: 12)),
          const SizedBox(height: 4),
          Text(
            score,
            style: TextStyle(
              color: color,
              fontSize: 28,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreMockup extends StatelessWidget {
  const _ScoreMockup();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.neonAmber.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: AppColors.neonAmber.withValues(alpha: 0.6)),
              ),
              child: const Text(
                '+30',
                style: TextStyle(
                  color: AppColors.neonAmber,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Atajo de una mano de dominó',
                style: TextStyle(color: AppColors.textMuted, fontSize: 11),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...List.generate(3, (i) => _key('${i + 1}')),
            _key('⌫', color: AppColors.neonRose),
            _key('0'),
            _key('✓', color: AppColors.neonCyan),
          ],
        ),
      ],
    );
  }

  Widget _key(String label, {Color? color}) {
    return Container(
      width: 42,
      height: 34,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.nightCard,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: (color ?? Colors.white).withValues(alpha: 0.12),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color ?? AppColors.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _EventsMockup extends StatelessWidget {
  const _EventsMockup();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(
          child: _MockChip(
            label: '✦ Capicúa ✓',
            color: AppColors.capicua,
            filled: true,
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: _MockChip(label: '✕ Tranque', color: AppColors.tranque),
        ),
      ],
    );
  }
}

class _FixMockup extends StatelessWidget {
  const _FixMockup();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _logRow('Equipo A', '+30', false),
        const SizedBox(height: 8),
        _logRow('Equipo B', '+25', true),
      ],
    );
  }

  Widget _logRow(String name, String pts, bool deleting) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: deleting
            ? AppColors.neonRose.withValues(alpha: 0.12)
            : AppColors.nightCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: deleting
              ? AppColors.neonRose.withValues(alpha: 0.5)
              : Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              name,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
          Text(
            pts,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 10),
          Icon(
            Icons.delete_outline_rounded,
            size: 18,
            color: deleting ? AppColors.neonRose : AppColors.textMuted,
          ),
        ],
      ),
    );
  }
}

class _ShareMockup extends StatelessWidget {
  const _ShareMockup();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.qr_code_2_rounded,
            size: 56,
            color: AppColors.nightBackground,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.wifi_rounded,
                      size: 16, color: AppColors.neonAmber),
                  const SizedBox(width: 6),
                  Text(
                    'Misma WiFi',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.neonAmber,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const _MockChip(
                label: '👁  Espectador',
                color: AppColors.neonAmber,
                filled: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EndMockup extends StatelessWidget {
  const _EndMockup();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Icon(Icons.emoji_events_rounded,
            size: 40, color: AppColors.neonAmber),
        const SizedBox(height: 8),
        const Text(
          '¡Equipo A gana!',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: const [
            Expanded(
              child: _MockChip(
                label: 'Revancha',
                color: AppColors.neonCyan,
                filled: true,
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: _MockChip(
                label: 'Cambiar jugadores',
                color: AppColors.neonAmber,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatsMockup extends StatelessWidget {
  const _StatsMockup();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Icon(Icons.emoji_events_rounded,
            size: 40, color: AppColors.neonAmber),
        const SizedBox(width: 18),
        _bar(0.5, AppColors.neonCyan),
        const SizedBox(width: 8),
        _bar(0.8, AppColors.neonAmber),
        const SizedBox(width: 8),
        _bar(0.35, AppColors.neonCyan),
        const SizedBox(width: 8),
        _bar(0.65, AppColors.neonAmber),
      ],
    );
  }

  Widget _bar(double factor, Color color) {
    return Expanded(
      child: Container(
        height: 60 * factor,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.7),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
        ),
      ),
    );
  }
}
