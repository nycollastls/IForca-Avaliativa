import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:forca/main.dart';
import 'package:forca/models/perfil.dart';
import 'package:forca/models/tamanho_texto.dart';
import 'package:forca/services/dados_aplicativo.dart';
import 'package:forca/widgets/estilo_caderno.dart';
import 'package:forca/widgets/tema_caderno.dart';

import 'armazenamento_memoria.dart';
import 'cliente_teste.dart';


Future<DadosAplicativo> abrir_aplicativo(WidgetTester tester) async {

  DadosAplicativo dados = DadosAplicativo(ArmazenamentoMemoria(), ClienteTeste());

  await tester.runAsync(dados.carregar);

  dados.perfis.perfil.nome = 'Nome com 15 let';

  await tester.pumpWidget(Forca(dados: dados));

  return dados;

}


Future<void> tocar(WidgetTester tester, Finder alvo) async {

  await tester.ensureVisible(alvo);
  await tester.pumpAndSettle();
  await tester.tap(alvo);
  await tester.pumpAndSettle();

}


Future<void> voltar(WidgetTester tester) async {

  await tester.tap(find.byType(BackButton));
  await tester.pumpAndSettle();

}


double calcular_contraste(Color primeira, Color segunda) {

  double maior = primeira.computeLuminance();
  double menor = segunda.computeLuminance();

  if (menor > maior) {

    double troca = maior;

    maior = menor;
    menor = troca;

  }

  return (maior + 0.05) / (menor + 0.05);

}


void main() {

  testWidgets('faixa do topo é azul em todas as telas', (WidgetTester tester) async {

    await abrir_aplicativo(tester);

    Color cor_esperada = const EstiloCaderno().tinta;

    for (String opcao in ['Um aparelho', 'Desafio multiplayer', 'Leaderboard', 'Estatísticas', 'Cadastrar palavras']) {

      await tocar(tester, find.text(opcao));

      AppBar faixa = tester.widget<AppBar>(find.byType(AppBar));
      BuildContext contexto = tester.element(find.byType(AppBar));

      expect(faixa.backgroundColor ?? Theme.of(contexto).appBarTheme.backgroundColor, cor_esperada, reason: opcao);

      await voltar(tester);

    }

  });


  testWidgets('opções de acessibilidade mudam o app na hora', (WidgetTester tester) async {

    DadosAplicativo dados = await abrir_aplicativo(tester);

    await tocar(tester, find.byTooltip('Configurações'));

    for (String opcao in ['Alto contraste', 'Espaçar letras', 'Marcas no teclado', 'Teclado em ordem alfabética', 'Reduzir animações']) {

      await tocar(tester, find.text(opcao));

    }

    await tocar(tester, find.text('Alto contraste'));
    expect(EstiloCaderno.de(tester.element(find.text('Alto contraste'))).tinta, const EstiloCaderno().tinta);
    expect(DefaultTextStyle.of(tester.element(find.text('Acessibilidade'))).style.color, const EstiloCaderno().tinta);

    await tocar(tester, find.text('Alto contraste'));
    expect(DefaultTextStyle.of(tester.element(find.text('Acessibilidade'))).style.color, Colors.black);

    await tocar(tester, find.text('Muito grande'));

    BuildContext contexto = tester.element(find.text('Alto contraste'));
    Perfil perfil = dados.perfis.perfil;

    expect(EstiloCaderno.de(contexto).tinta, Colors.black);
    expect(EstiloCaderno.de(contexto).teclado_alfabetico, isTrue);
    expect(EstiloCaderno.de(contexto).marcas_teclado, isTrue);
    expect(Theme.of(contexto).textTheme.bodyMedium!.letterSpacing, 1.4);
    expect(MediaQuery.textScalerOf(contexto).scale(10), 14);
    expect(MediaQuery.disableAnimationsOf(contexto), isTrue);
    expect(perfil.tamanho_texto, TamanhoTexto.muito_grande);

  });


  testWidgets('teclado alfabético e marcas aparecem na partida', (WidgetTester tester) async {

    DadosAplicativo dados = await abrir_aplicativo(tester);

    dados.perfis.perfil.teclado_alfabetico = true;
    dados.perfis.perfil.marcas_teclado = true;
    await tester.runAsync(dados.perfis.gravar);
    await tester.pumpAndSettle();

    await tocar(tester, find.text('Um aparelho'));
    await tocar(tester, find.text('C'));

    Offset posicao_a = tester.getCenter(find.widgetWithText(OutlinedButton, 'A'));
    Offset posicao_b = tester.getCenter(find.widgetWithText(OutlinedButton, 'B'));

    expect(posicao_a.dy, posicao_b.dy);
    expect(posicao_a.dx, lessThan(posicao_b.dx));

    for (String letra in ['Z', 'E', 'P']) {

      await tocar(tester, find.widgetWithText(OutlinedButton, letra));

    }

    int total_marcas = find.byIcon(Icons.check).evaluate().length + find.byIcon(Icons.close).evaluate().length;

    expect(total_marcas, 3);

  });


  testWidgets('tudo ligado cabe em celular estreito', (WidgetTester tester) async {

    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    DadosAplicativo dados = await abrir_aplicativo(tester);

    dados.perfis.perfil
      ..tamanho_texto = TamanhoTexto.muito_grande
      ..alto_contraste = true
      ..letras_espacadas = true
      ..teclado_alfabetico = true
      ..marcas_teclado = true;

    await tester.runAsync(dados.perfis.gravar);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'Início');

    for (String opcao in ['Um aparelho', 'Desafio multiplayer', 'Leaderboard', 'Estatísticas', 'Cadastrar palavras']) {

      await tocar(tester, find.text(opcao));
      expect(tester.takeException(), isNull, reason: opcao);
      await voltar(tester);

    }

    await tocar(tester, find.byTooltip('Configurações'));
    expect(tester.takeException(), isNull, reason: 'Configurações');
    await voltar(tester);

    await tocar(tester, find.text('Um aparelho'));
    await tocar(tester, find.text('Lógica'));
    await tocar(tester, find.widgetWithText(OutlinedButton, 'A'));
    expect(tester.takeException(), isNull, reason: 'Partida');
    await voltar(tester);
    await voltar(tester);

    await tocar(tester, find.text('Desafio multiplayer'));
    await tocar(tester, find.text('Criar sala'));
    expect(tester.takeException(), isNull, reason: 'Sala');

  });


  test('cores têm contraste suficiente nos dois modos', () {

    Perfil perfil_comum = Perfil(id: 'a');
    Perfil perfil_contraste = Perfil(id: 'a', alto_contraste: true);

    for (Perfil perfil in [perfil_comum, perfil_contraste]) {

      EstiloCaderno estilo = criar_estilo(perfil);
      double minimo = perfil.alto_contraste ? 7 : 4.5;

      expect(calcular_contraste(estilo.tinta, estilo.papel), greaterThan(minimo));
      expect(calcular_contraste(estilo.tinta, estilo.marca_texto), greaterThan(minimo));
      expect(calcular_contraste(Colors.white, estilo.tinta), greaterThan(minimo));
      expect(calcular_contraste(estilo.vermelha, estilo.papel), greaterThan(minimo));
      expect(calcular_contraste(estilo.acerto, estilo.papel), greaterThan(minimo));

    }

  });


  testWidgets('leitor de tela encontra botões com nome e tamanho de toque', (WidgetTester tester) async {

    SemanticsHandle leitor = tester.ensureSemantics();

    await abrir_aplicativo(tester);

    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));

    await tocar(tester, find.byTooltip('Configurações'));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));

    leitor.dispose();

  });

}
