import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:forca/main.dart';
import 'package:forca/models/categoria.dart';
import 'package:forca/models/nivel.dart';
import 'package:forca/models/palavra.dart';
import 'package:forca/models/resultado.dart';
import 'package:forca/screens/tela_jogo.dart';
import 'package:forca/services/dados_aplicativo.dart';

import 'armazenamento_memoria.dart';


const Palavra palavra_teste = Palavra(

  texto: 'mixin',
  dica: 'Reaproveita código',
  categoria: Categoria.dart,
  nivel: Nivel.facil,

);


Future<DadosAplicativo> abrir_aplicativo(WidgetTester tester) async {

  DadosAplicativo dados = DadosAplicativo(ArmazenamentoMemoria());

  await tester.runAsync(dados.carregar);
  await tester.pumpWidget(Forca(dados: dados));

  return dados;

}


Future<void> tocar(WidgetTester tester, String texto) async {

  await tester.ensureVisible(find.text(texto));
  await tester.pumpAndSettle();
  await tester.tap(find.text(texto));
  await tester.pumpAndSettle();

}


void main() {

  testWidgets('exibe as opções de categoria', (WidgetTester tester) async {

    await abrir_aplicativo(tester);

    expect(find.text('C'), findsOneWidget);
    expect(find.text('Dart'), findsOneWidget);
    expect(find.text('Lógica'), findsOneWidget);

  });


  testWidgets('abre a partida, o placar, o cadastro e o duelo', (WidgetTester tester) async {

    await abrir_aplicativo(tester);

    await tocar(tester, 'Dart');
    expect(find.text('Forca: Dart'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tocar(tester, 'Ver placar');
    expect(find.text('Vitórias por categoria e nível'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tocar(tester, 'Cadastrar palavras');
    expect(find.text('Salvar palavra'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tocar(tester, 'Dois jogadores');
    expect(find.text('Começar duelo'), findsOneWidget);

  });


  testWidgets('joga até vencer usando teclado virtual e físico', (WidgetTester tester) async {

    List<Resultado> resultados = [];

    await tester.pumpWidget(

      MaterialApp(

        home: TelaJogo(

          titulo: 'Teste',
          palavra: palavra_teste,
          ao_terminar: (resultado) async => resultados.add(resultado),

        ),

      ),

    );

    await tocar(tester, 'Ver dica (custa 10 pontos)');
    expect(find.text('Reaproveita código'), findsOneWidget);

    await tocar(tester, 'Z');
    expect(find.text('Erros: 1 de 6'), findsOneWidget);

    await tocar(tester, 'M');
    await tester.sendKeyEvent(LogicalKeyboardKey.keyI, character: 'i');
    await tester.sendKeyEvent(LogicalKeyboardKey.keyX, character: 'x');
    await tester.sendKeyEvent(LogicalKeyboardKey.keyN, character: 'n');
    await tester.pumpAndSettle();

    expect(find.text('Você acertou e ganhou 17 pontos.'), findsOneWidget);
    expect(resultados.single.venceu, isTrue);

  });


  testWidgets('seis erros encerram a partida', (WidgetTester tester) async {

    List<Resultado> resultados = [];

    await tester.pumpWidget(

      MaterialApp(

        home: TelaJogo(

          titulo: 'Teste',
          palavra: palavra_teste,
          ao_terminar: (resultado) async => resultados.add(resultado),

        ),

      ),

    );

    for (String letra in ['Q', 'W', 'E', 'R', 'T', 'Y']) {

      await tocar(tester, letra);

    }

    expect(find.textContaining('A palavra era MIXIN.'), findsOneWidget);
    expect(resultados.single.venceu, isFalse);

  });


  testWidgets('cadastro mostra erros e salva palavra válida', (WidgetTester tester) async {

    DadosAplicativo dados = await abrir_aplicativo(tester);

    await tocar(tester, 'Cadastrar palavras');
    await tocar(tester, 'Salvar palavra');
    expect(find.text('Digite a palavra.'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).first, 'printf');
    await tester.enterText(find.byType(TextFormField).last, 'Mostra texto');
    await tocar(tester, 'Salvar palavra');
    expect(find.textContaining('já está cadastrada'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).first, 'herança');
    await tocar(tester, 'Salvar palavra');
    expect(dados.palavras.palavras_cadastradas.single.texto, 'herança');
    expect(find.text('Digite a palavra.'), findsNothing);

  });


  testWidgets('duelo troca os papéis e soma pontos', (WidgetTester tester) async {

    DadosAplicativo dados = await abrir_aplicativo(tester);

    await tocar(tester, 'Dois jogadores');
    await tester.enterText(find.byType(TextFormField).first, 'Ana');
    await tester.enterText(find.byType(TextFormField).last, 'Beto');
    await tocar(tester, 'Começar duelo');

    await tester.enterText(find.byType(TextFormField).first, 'oi');
    await tester.enterText(find.byType(TextFormField).last, 'Cumprimento curto');
    await tocar(tester, 'Passar para Beto');
    await tocar(tester, 'Começar rodada');

    await tocar(tester, 'O');
    await tocar(tester, 'I');
    await tocar(tester, 'Voltar');

    expect(dados.placares.duelo!.pontos, [0, 40]);
    expect(find.text('Beto, escreva a palavra para Ana'), findsOneWidget);

  });


  testWidgets('telas cabem em celular estreito', (WidgetTester tester) async {

    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await abrir_aplicativo(tester);

    for (String opcao in ['Lógica', 'Ver placar', 'Cadastrar palavras', 'Dois jogadores']) {

      await tocar(tester, opcao);
      expect(tester.takeException(), isNull, reason: opcao);
      await tester.pageBack();
      await tester.pumpAndSettle();

    }

  });

}
