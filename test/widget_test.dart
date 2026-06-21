import 'package:domino_score/app.dart';
import 'package:domino_score/data/repositories/game_repository.dart';
import 'package:domino_score/features/live_room/live_room_manager.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Carga la pantalla de configuración', (WidgetTester tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();

    final repository = GameRepository();
    await repository.init();
    final liveRoomManager = LiveRoomManager();

    await tester.pumpWidget(DominoApp(
      repository: repository,
      liveRoomManager: liveRoomManager,
    ));
    await tester.pumpAndSettle();

    expect(find.textContaining('DOBLE SEIS'), findsOneWidget);
    expect(find.text('Modo de juego'), findsOneWidget);
    expect(find.text('Equipo vs Equipo'), findsOneWidget);
    expect(find.text('Individual'), findsOneWidget);
    expect(find.text('Puntaje manual'), findsOneWidget);
    expect(find.text('Comenzar partida'), findsOneWidget);
  });
}
