import 'package:domino_score/app.dart';
import 'package:domino_score/data/repositories/game_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Carga la pantalla del marcador', (WidgetTester tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();

    final repository = GameRepository();
    await repository.init();

    await tester.pumpWidget(DominoApp(repository: repository));
    await tester.pumpAndSettle();

    expect(find.textContaining('DOBLE SEIS'), findsOneWidget);
    expect(find.text('Equipo A'), findsOneWidget);
    expect(find.text('Equipo B'), findsOneWidget);
  });
}
