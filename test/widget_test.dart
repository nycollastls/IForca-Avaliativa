import 'package:flutter_test/flutter_test.dart';

import 'package:forca/main.dart';
import 'package:forca/modelos/linguagem.dart';
import 'package:forca/servicos/carregador_palavras.dart';


void main() {

  TestWidgetsFlutterBinding.ensureInitialized();


  testWidgets('exibe as opções de linguagem', (WidgetTester tester) async {

    await tester.pumpWidget(const Forca());

    expect(find.text('C'), findsOneWidget);
    expect(find.text('Dart'), findsOneWidget);

  });


  test('cada linguagem possui 5 palavras', () async {

    for (Linguagem linguagem in Linguagem.values) {

      List<String> palavras = await carregar_palavras(linguagem);

      expect(palavras.length, 5);

    }

  });

}
