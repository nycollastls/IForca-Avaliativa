import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:forca/main.dart';
import 'package:forca/models/perfil.dart';
import 'package:forca/models/sala_desafio.dart';
import 'package:forca/screens/tela_sala.dart';
import 'package:forca/services/dados_aplicativo.dart';
import 'package:forca/services/servico_online.dart';

import 'armazenamento_memoria.dart';
import 'cliente_teste.dart';


Future<DadosAplicativo> abrir_aplicativo(WidgetTester tester, ClienteTeste cliente, String nome) async {

  DadosAplicativo dados = DadosAplicativo(ArmazenamentoMemoria(), cliente);

  await tester.runAsync(dados.carregar);

  dados.perfis.perfil.nome = nome;

  await tester.pumpWidget(Forca(dados: dados));

  return dados;

}


Future<void> tocar(WidgetTester tester, Finder alvo) async {

  await tester.ensureVisible(alvo);
  await tester.pumpAndSettle();
  await tester.tap(alvo);
  await tester.pumpAndSettle();

}


Future<void> esperar_consulta(WidgetTester tester) async {

  await tester.pump(intervalo_consulta);
  await tester.pumpAndSettle();

}


Perfil criar_amigo() => Perfil(id: 'a' * 32, nome: 'Beto');


void main() {

  testWidgets('pede o nome antes do desafio e mostra na tela inicial', (WidgetTester tester) async {

    await abrir_aplicativo(tester, ClienteTeste(), '');

    await tocar(tester, find.text('Desafio multiplayer'));
    expect(find.text('Seu nome no jogo'), findsOneWidget);

    await tocar(tester, find.text('Salvar nome'));
    expect(find.text('Digite o nome do jogador.'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), 'Ana');
    await tocar(tester, find.text('Salvar nome'));
    expect(find.text('Criar sala'), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('Ana'), findsOneWidget);

  });


  testWidgets('desafio completo entre dois aparelhos', (WidgetTester tester) async {

    ClienteTeste cliente = ClienteTeste();
    ServicoOnline servico_amigo = ServicoOnline(cliente);
    Perfil amigo = criar_amigo();

    await abrir_aplicativo(tester, cliente, 'Ana');
    await tocar(tester, find.text('Desafio multiplayer'));
    await tocar(tester, find.text('Criar sala'));

    String codigo = cliente.aplicacao.salas.keys.single;

    expect(find.text('Sala $codigo'), findsOneWidget);
    expect(find.text('Falta pelo menos mais uma pessoa entrar.'), findsOneWidget);

    await servico_amigo.entrar_sala(amigo, codigo);
    await esperar_consulta(tester);
    expect(find.text('Beto'), findsOneWidget);

    await tocar(tester, find.text('Começar desafio'));
    await tester.enterText(find.byType(TextFormField).first, 'laço');
    await tester.enterText(find.byType(TextFormField).last, 'Repete instruções');
    await tocar(tester, find.text('Enviar palavra'));
    expect(find.text('Estão tentando adivinhar "laço".'), findsOneWidget);

    await servico_amigo.pedir_sala(
      'salas/$codigo/resultado',
      {'id': amigo.id, 'rodada': 1, 'venceu': true, 'pontos': 37},
      limite_rapido,
    );
    await esperar_consulta(tester);
    expect(find.text('A palavra era LAÇO.'), findsOneWidget);
    expect(find.text('Acertou e ganhou 37 pontos'), findsOneWidget);

    await tocar(tester, find.text('Próxima rodada'));
    expect(find.text('Rodada 2. Beto está escrevendo a palavra.'), findsOneWidget);

    await servico_amigo.enviar_palavra(amigo, codigo, 'oi', 'Cumprimento curto');
    await esperar_consulta(tester);
    expect(find.text('Erros: 0 de 6'), findsOneWidget);

    await tocar(tester, find.text('Ver dica (custa 10 pontos)'));
    await tocar(tester, find.widgetWithText(OutlinedButton, 'O'));
    await esperar_consulta(tester);
    expect(find.text('Cumprimento curto'), findsOneWidget);

    await tocar(tester, find.widgetWithText(OutlinedButton, 'I'));
    await esperar_consulta(tester);

    SalaDesafio visao_amigo = await servico_amigo.consultar_sala(amigo, codigo);

    expect(visao_amigo.fase, FaseSala.resultado);
    expect(visao_amigo.jogadores.first.pontos, 30);
    expect(find.text('Acertou e ganhou 30 pontos'), findsOneWidget);
    expect(find.text('Você acertou!'), findsOneWidget);

  });


  testWidgets('sala avisa falta de rede, envia o resultado depois e confirma a saída', (WidgetTester tester) async {

    ClienteTeste cliente = ClienteTeste();
    ServicoOnline servico_amigo = ServicoOnline(cliente);
    Perfil amigo = criar_amigo();

    await abrir_aplicativo(tester, cliente, 'Ana');

    String codigo = (await servico_amigo.criar_sala(amigo, false)).codigo;

    await tocar(tester, find.text('Desafio multiplayer'));
    await tester.enterText(find.byType(TextFormField), codigo.toLowerCase());
    await tocar(tester, find.text('Entrar na sala'));

    await servico_amigo.iniciar_sala(amigo, codigo);
    await servico_amigo.enviar_palavra(amigo, codigo, 'oi', 'Cumprimento curto');
    await esperar_consulta(tester);

    cliente.fora_do_ar = true;
    await tocar(tester, find.widgetWithText(OutlinedButton, 'O'));
    await tocar(tester, find.widgetWithText(OutlinedButton, 'I'));
    await esperar_consulta(tester);
    expect(find.text('Sem conexão com o servidor. Tentando de novo.'), findsOneWidget);

    cliente.fora_do_ar = false;
    await esperar_consulta(tester);
    expect(find.text('Acertou e ganhou 40 pontos'), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('Sair da sala?'), findsOneWidget);

    await tocar(tester, find.widgetWithText(FilledButton, 'Sair da sala'));
    expect(find.text('Criar sala'), findsOneWidget);
    expect(cliente.aplicacao.salas[codigo]!.jogadores.length, 1);

  });


  testWidgets('código errado e sala encerrada são avisados', (WidgetTester tester) async {

    ClienteTeste cliente = ClienteTeste();

    await abrir_aplicativo(tester, cliente, 'Ana');
    await tocar(tester, find.text('Desafio multiplayer'));

    await tester.enterText(find.byType(TextFormField), 'AB');
    await tocar(tester, find.text('Entrar na sala'));
    expect(find.text('O código tem 5 letras.'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), 'AAAAA');
    await tocar(tester, find.text('Entrar na sala'));
    expect(find.text('Sala não encontrada. Confira o código.'), findsOneWidget);

    await tocar(tester, find.text('Criar sala'));
    cliente.aplicacao.salas.clear();
    await esperar_consulta(tester);
    expect(find.textContaining('Esta sala foi encerrada'), findsOneWidget);

    await tocar(tester, find.text('Voltar'));
    expect(find.text('Criar sala'), findsOneWidget);

  });


  testWidgets('quem cria a sala decide se a partida vai para o leaderboard', (WidgetTester tester) async {

    ClienteTeste cliente = ClienteTeste();
    ServicoOnline servico_amigo = ServicoOnline(cliente);
    Perfil amigo = criar_amigo();

    await abrir_aplicativo(tester, cliente, 'Ana');
    await tocar(tester, find.text('Desafio multiplayer'));

    expect(tester.widget<SwitchListTile>(find.byType(SwitchListTile)).value, isFalse);

    await tocar(tester, find.text('Mostrar no leaderboard geral'));
    await tocar(tester, find.text('Criar sala'));
    expect(find.text('Esta partida vai aparecer no leaderboard geral.'), findsOneWidget);

    String codigo = cliente.aplicacao.salas.keys.single;

    await servico_amigo.entrar_sala(amigo, codigo);
    await esperar_consulta(tester);
    await tocar(tester, find.text('Começar desafio'));
    await tester.enterText(find.byType(TextFormField).first, 'laço');
    await tester.enterText(find.byType(TextFormField).last, 'Repete instruções');
    await tocar(tester, find.text('Enviar palavra'));
    await servico_amigo.pedir_sala(
      'salas/$codigo/resultado',
      {'id': amigo.id, 'rodada': 1, 'venceu': true, 'pontos': 37},
      limite_rapido,
    );
    await esperar_consulta(tester);

    await tocar(tester, find.byType(BackButton));
    await tocar(tester, find.widgetWithText(FilledButton, 'Sair da sala'));
    await tocar(tester, find.byType(BackButton));
    await tocar(tester, find.text('Leaderboard'));

    expect(find.text('Beto está na frente'), findsOneWidget);
    expect(find.text('37 pontos'), findsOneWidget);
    expect(find.text('Ana (você)'), findsOneWidget);

    await servico_amigo.sair_sala(amigo, codigo);
    await tocar(tester, find.text('Mais recentes'));
    expect(find.text('Beto venceu'), findsOneWidget);

  });


  testWidgets('sala comum avisa que não vai para o leaderboard', (WidgetTester tester) async {

    ClienteTeste cliente = ClienteTeste();

    await abrir_aplicativo(tester, cliente, 'Ana');
    await tocar(tester, find.text('Desafio multiplayer'));
    await tocar(tester, find.text('Criar sala'));

    expect(find.text('Esta partida não aparece no leaderboard geral.'), findsOneWidget);
    expect(cliente.aplicacao.salas.values.single.publica, isFalse);

  });


  testWidgets('partida de um aparelho não fala com o servidor', (WidgetTester tester) async {

    ClienteTeste cliente = ClienteTeste();
    DadosAplicativo dados = await abrir_aplicativo(tester, cliente, 'Ana');

    await tocar(tester, find.text('Um aparelho'));
    await tocar(tester, find.text('C'));

    for (String letra in 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('')) {

      Finder tecla = find.widgetWithText(OutlinedButton, letra);

      if (tecla.evaluate().isNotEmpty) {

        await tocar(tester, tecla);

      }

    }

    expect(dados.placares.placar.vitorias + dados.placares.placar.derrotas, 1);
    expect(cliente.total_pedidos, 0);

  });


  testWidgets('configurações escondem o nome e os textos do sistema ficam em português', (WidgetTester tester) async {

    ClienteTeste cliente = ClienteTeste();
    DadosAplicativo dados = await abrir_aplicativo(tester, cliente, 'Ana');

    await tocar(tester, find.byTooltip('Configurações'));
    expect(find.byTooltip('Voltar'), findsOneWidget);

    await tocar(tester, find.text('Mostrar meu nome no leaderboard'));
    expect(dados.perfis.perfil.aparecer_leaderboard, isFalse);
    expect(cliente.total_pedidos, 1);

    cliente.fora_do_ar = true;
    await tocar(tester, find.text('Mostrar meu nome no leaderboard'));
    expect(find.textContaining('Sem conexão com o servidor'), findsOneWidget);

  });


  testWidgets('leaderboard sem rede oferece nova tentativa', (WidgetTester tester) async {

    ClienteTeste cliente = ClienteTeste();

    cliente.fora_do_ar = true;

    await abrir_aplicativo(tester, cliente, 'Ana');
    await tocar(tester, find.text('Leaderboard'));
    expect(find.textContaining('Não foi possível falar com o servidor'), findsOneWidget);

    cliente.fora_do_ar = false;
    await tocar(tester, find.text('Tentar de novo'));
    expect(find.textContaining('Nenhuma partida por aqui'), findsOneWidget);

  });

}
