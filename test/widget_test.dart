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
import 'cliente_teste.dart';


const Palavra palavra_teste = Palavra(

  texto: 'mixin',
  dica: 'Reaproveita código',
  categoria: Categoria.dart,
  nivel: Nivel.facil,

);


Future<DadosAplicativo> abrir_aplicativo(WidgetTester tester, {ClienteTeste? cliente, String nome = ''}) async {

  DadosAplicativo dados = DadosAplicativo(ArmazenamentoMemoria(), cliente ?? ClienteTeste());

  await tester.runAsync(dados.carregar);
  dados.perfis.perfil.nome = nome;
  await tester.pumpWidget(Forca(dados: dados));

  return dados;

}


Future<void> tocar(WidgetTester tester, String texto) async {

  await tester.ensureVisible(find.text(texto));
  await tester.pumpAndSettle();
  await tester.tap(find.text(texto));
  await tester.pumpAndSettle();

}


Future<void> voltar(WidgetTester tester) async {

  await tester.tap(find.byType(BackButton));
  await tester.pumpAndSettle();

}


void main() {

  testWidgets('tela inicial mostra modos, leaderboard, usuário e configurações', (WidgetTester tester) async {

    await abrir_aplicativo(tester, nome: 'Ana');

    expect(find.text('Ana'), findsOneWidget);
    expect(find.text('Um aparelho'), findsOneWidget);
    expect(find.text('Desafio multiplayer'), findsOneWidget);
    expect(find.text('Leaderboard'), findsOneWidget);
    expect(find.byTooltip('Configurações'), findsOneWidget);
    expect(find.text('Forca da Programação'), findsOneWidget);
    expect(find.textContaining('pontos'), findsNothing);

  });


  testWidgets('exibe as opções de categoria', (WidgetTester tester) async {

    await abrir_aplicativo(tester);
    await tocar(tester, 'Um aparelho');

    expect(find.text('C'), findsOneWidget);
    expect(find.text('Dart'), findsOneWidget);
    expect(find.text('Lógica'), findsOneWidget);

  });


  testWidgets('abre a partida, o placar, o cadastro e o duelo', (WidgetTester tester) async {

    await abrir_aplicativo(tester);

    await tocar(tester, 'Um aparelho');
    await tocar(tester, 'Dart');
    expect(find.text('Forca: Dart'), findsOneWidget);
    await voltar(tester);

    await tocar(tester, 'Dois jogadores');
    expect(find.text('Começar duelo'), findsOneWidget);
    await voltar(tester);
    await voltar(tester);

    await tocar(tester, 'Estatísticas');
    expect(find.text('Suas vitórias por categoria e nível'), findsOneWidget);
    await voltar(tester);

    await tocar(tester, 'Cadastrar palavras');
    expect(find.text('Salvar palavra'), findsOneWidget);

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
    await tester.pumpAndSettle();
    expect(find.text('Digite a palavra.'), findsNothing);

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

    await tocar(tester, 'Um aparelho');
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

    await abrir_aplicativo(tester, nome: 'Nome com 15 let');

    for (String opcao in ['Um aparelho', 'Desafio multiplayer', 'Leaderboard', 'Estatísticas', 'Cadastrar palavras']) {

      await tocar(tester, opcao);
      expect(tester.takeException(), isNull, reason: opcao);
      await voltar(tester);

    }

  });

}
