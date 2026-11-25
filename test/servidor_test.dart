import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../servidor/bin/aplicacao.dart';
import '../servidor/bin/leaderboard.dart';
import '../servidor/bin/sala.dart';
import '../servidor/bin/validacao.dart';


String criar_id(int numero) => numero.toRadixString(16).padLeft(32, '0');


class Cenario {

  DateTime agora = DateTime(2026, 11, 26);

  late final Aplicacao aplicacao = Aplicacao(leaderboard: Leaderboard(), relogio: () => agora);
  late final String codigo;


  Map<String, dynamic> pedir(int jogador, String caminho, [Map<String, dynamic> dados = const {}]) {

    return aplicacao.processar(caminho.split('/'), {'id': criar_id(jogador), ...dados});

  }


  Map<String, dynamic> agir(int jogador, String acao, [Map<String, dynamic> dados = const {}]) {

    return pedir(jogador, 'salas/$codigo/$acao', dados);

  }


  void montar_sala(int total, {bool publica = false}) {

    codigo = pedir(1, 'salas', {'nome': 'Jogador1', 'mostrar_nome': true, 'publica': publica})['codigo'] as String;

    for (int jogador = 2; jogador <= total; jogador++) {

      entrar(jogador);

    }

  }


  Map<String, dynamic> entrar(int jogador, {bool mostrar_nome = true}) {

    return agir(jogador, 'entrar', {'nome': 'Jogador$jogador', 'mostrar_nome': mostrar_nome});

  }


  List<dynamic> listar({int jogador = 1, bool por_pontos = true}) {

    return pedir(jogador, 'leaderboard/listar', {'por_pontos': por_pontos})['partidas'] as List<dynamic>;

  }


  void comecar_rodada() {

    agir(1, 'iniciar');
    agir(1, 'palavra', {'palavra': 'laço', 'dica': 'Repete instruções'});

  }


  Map<String, dynamic> terminar(int jogador, {bool venceu = true, int pontos = 40, int rodada = 1}) {

    return agir(jogador, 'resultado', {'rodada': rodada, 'venceu': venceu, 'pontos': pontos});

  }

}


Matcher lanca_erro(int codigo_http) {

  return throwsA(isA<ErroRegra>().having((erro) => erro.codigo_http, 'codigo_http', codigo_http));

}


void main() {

  test('rodada completa soma pontos e troca quem escreve', () {

    Cenario cenario = Cenario();

    cenario.montar_sala(3);
    cenario.comecar_rodada();

    expect(cenario.terminar(2)['fase'], 'jogando');

    Map<String, dynamic> visao = cenario.terminar(3, venceu: false, pontos: 0);

    expect(visao['fase'], 'resultado');
    expect(visao['jogadores'][1]['pontos'], 40);
    expect(visao['jogadores'][2]['pontos'], 0);

    visao = cenario.agir(3, 'proxima', {'rodada': 1});

    expect(visao['fase'], 'escrevendo');
    expect(visao['numero_desafiante'], 2);
    expect(cenario.agir(1, 'proxima', {'rodada': 1})['rodada'], 2);

  });


  test('palavra fica escondida de quem não pode ver', () {

    Cenario cenario = Cenario();

    cenario.montar_sala(2);
    cenario.comecar_rodada();

    expect(cenario.agir(2, 'estado')['palavra'], 'laço');

    cenario.entrar(3);

    expect(cenario.agir(3, 'estado')['palavra'], '');
    expect(cenario.agir(3, 'estado').toString(), isNot(contains(criar_id(1))));

  });


  test('só o anfitrião começa e só com duas pessoas', () {

    Cenario cenario = Cenario();

    cenario.montar_sala(1);
    expect(() => cenario.agir(1, 'iniciar'), lanca_erro(409));

    cenario.entrar(2);
    expect(() => cenario.agir(2, 'iniciar'), lanca_erro(403));

  });


  test('só quem está na vez escreve a palavra', () {

    Cenario cenario = Cenario();

    cenario.montar_sala(2);
    cenario.agir(1, 'iniciar');

    expect(() => cenario.agir(2, 'palavra', {'palavra': 'laço', 'dica': 'dica'}), lanca_erro(409));
    expect(() => cenario.agir(1, 'palavra', {'palavra': 'a1', 'dica': 'dica'}), lanca_erro(400));

  });


  test('resultado repetido, exagerado ou de outra rodada não vale', () {

    Cenario cenario = Cenario();

    cenario.montar_sala(3);
    cenario.comecar_rodada();

    expect(cenario.terminar(2, rodada: 9)['jogadores'][1]['terminou'], isFalse);
    expect(cenario.terminar(2, pontos: 9999)['jogadores'][1]['pontos'], 40);
    expect(cenario.terminar(2)['jogadores'][1]['pontos'], 40);
    expect(cenario.terminar(3, venceu: false, pontos: 40)['jogadores'][2]['pontos'], 0);

  });


  test('sala aceita até seis jogadores', () {

    Cenario cenario = Cenario();

    cenario.montar_sala(6);

    expect(() => cenario.entrar(7), lanca_erro(409));
    expect(cenario.entrar(6)['jogadores'].length, 6);

  });


  test('quem perde a conexão não trava a rodada e volta com os pontos', () {

    Cenario cenario = Cenario();

    cenario.montar_sala(3);
    cenario.comecar_rodada();
    cenario.terminar(2);

    cenario.agora = cenario.agora.add(tempo_ausencia + const Duration(seconds: 1));

    expect(cenario.agir(1, 'estado')['fase'], 'resultado');

    Map<String, dynamic> visao = cenario.agir(2, 'estado');

    expect(visao['jogadores'][1]['pontos'], 40);
    expect(visao['jogadores'][1]['ausente'], isFalse);

  });


  test('passa a vez se quem escreve perde a conexão', () {

    Cenario cenario = Cenario();

    cenario.montar_sala(2);
    cenario.agir(1, 'iniciar');
    cenario.agora = cenario.agora.add(tempo_ausencia + const Duration(seconds: 1));

    expect(cenario.agir(2, 'estado')['numero_desafiante'], 2);

  });


  test('sala volta à espera quando sobra uma pessoa e some quando esvazia', () {

    Cenario cenario = Cenario();

    cenario.montar_sala(2);
    cenario.comecar_rodada();
    cenario.agir(1, 'sair');

    expect(cenario.agir(2, 'estado')['fase'], 'espera');

    cenario.agir(2, 'sair');

    expect(() => cenario.agir(2, 'estado'), lanca_erro(404));

  });


  test('só quem escreveu ou o anfitrião encerra a rodada', () {

    Cenario cenario = Cenario();

    cenario.montar_sala(3);
    cenario.comecar_rodada();

    expect(() => cenario.agir(2, 'encerrar', {'rodada': 1}), lanca_erro(403));
    expect(cenario.agir(1, 'encerrar', {'rodada': 1})['fase'], 'resultado');

  });


  test('só partida pública com rodada concluída aparece no leaderboard', () {

    Cenario privada = Cenario();

    privada.montar_sala(2);
    privada.comecar_rodada();
    privada.terminar(2);

    expect(privada.listar(), isEmpty);

    Cenario publica = Cenario();

    publica.montar_sala(2, publica: true);
    publica.comecar_rodada();

    expect(publica.listar(), isEmpty);

    publica.terminar(2);

    Map<String, dynamic> partida = publica.listar(jogador: 2).single as Map<String, dynamic>;

    expect(partida['rodadas'], 1);
    expect(partida['em_andamento'], isTrue);
    expect(partida['jogadores'], [

      {'nome': 'Jogador2', 'pontos': 40, 'sou_eu': true},
      {'nome': 'Jogador1', 'pontos': 0, 'sou_eu': false},

    ]);

  });


  test('partida pública é atualizada a cada rodada e continua depois que a sala fecha', () {

    Cenario cenario = Cenario();

    cenario.montar_sala(2, publica: true);
    cenario.comecar_rodada();
    cenario.terminar(2);
    cenario.agir(1, 'proxima', {'rodada': 1});
    cenario.agir(2, 'palavra', {'palavra': 'vetor', 'dica': 'Uma dimensão'});
    cenario.terminar(1, pontos: 31, rodada: 2);
    cenario.agir(1, 'sair');
    cenario.agir(2, 'sair');

    Map<String, dynamic> partida = cenario.listar(jogador: 9).single as Map<String, dynamic>;

    expect(cenario.aplicacao.salas, isEmpty);
    expect(partida['rodadas'], 2);
    expect(partida['em_andamento'], isFalse);
    expect(partida['jogadores'].map((jogador) => jogador['pontos']), [40, 31]);
    expect(partida.toString(), isNot(contains(criar_id(1))));
    expect(partida.toString(), isNot(contains(cenario.codigo)));

  });


  test('rodada em que ninguém terminou não entra no leaderboard', () {

    Cenario cenario = Cenario();

    cenario.montar_sala(2, publica: true);
    cenario.comecar_rodada();
    cenario.agir(1, 'encerrar', {'rodada': 1});

    expect(cenario.listar(), isEmpty);

  });


  test('quem só assistiu não aparece na partida', () {

    Cenario cenario = Cenario();

    cenario.montar_sala(2, publica: true);
    cenario.comecar_rodada();
    cenario.entrar(3);
    cenario.terminar(2);

    expect(cenario.listar().single['jogadores'].length, 2);

  });


  test('nome pode ser escondido antes e depois da partida', () {

    Cenario cenario = Cenario();

    cenario.montar_sala(1, publica: true);
    cenario.entrar(2, mostrar_nome: false);
    cenario.comecar_rodada();
    cenario.terminar(2);

    expect(cenario.listar().single['jogadores'].first['nome'], 'Anônimo');

    cenario.pedir(1, 'leaderboard/nome', {'mostrar_nome': false});
    expect(cenario.listar().single['jogadores'].last['nome'], 'Anônimo');

    cenario.pedir(2, 'leaderboard/nome', {'mostrar_nome': true});
    expect(cenario.listar().single['jogadores'].first['nome'], 'Jogador2');

  });


  test('quem sai e volta recupera os pontos sem jogar a mesma palavra de novo', () {

    Cenario cenario = Cenario();

    cenario.montar_sala(3);
    cenario.comecar_rodada();
    cenario.terminar(2);
    cenario.agir(2, 'sair');

    Map<String, dynamic> visao = cenario.entrar(2);

    expect(visao['meu_numero'], 2);
    expect(visao['jogadores'][1]['pontos'], 40);
    expect(visao['jogadores'][1]['participa'], isFalse);
    expect(visao['palavra'], '');

  });


  test('leaderboard ordena por pontos ou por data e mostra vinte', () {

    Cenario cenario = Cenario();

    for (int numero = 1; numero <= 25; numero++) {

      Sala sala = Sala(codigo: 'A', id_partida: 'p$numero', publica: true, criada_em: cenario.agora);

      sala.entrar(criar_id(1), 'Jogador1', true, cenario.agora);
      sala.jogadores.single.jogou = true;
      sala.jogadores.single.pontos = 100 - numero;

      cenario.aplicacao.leaderboard.registrar(sala, cenario.agora.add(Duration(minutes: numero)));

    }

    expect(cenario.listar().length, 20);
    expect(cenario.listar().first['jogadores'].first['pontos'], 99);
    expect(cenario.listar(por_pontos: false).first['jogadores'].first['pontos'], 75);

  });


  test('recusa identificação e nome inválidos', () {

    Cenario cenario = Cenario();

    expect(() => cenario.aplicacao.processar(['salas'], {'id': 'x', 'nome': 'Ana', 'mostrar_nome': true, 'publica': false}), lanca_erro(400));
    expect(() => cenario.pedir(1, 'salas', {'nome': ' ', 'mostrar_nome': true, 'publica': false}), lanca_erro(400));
    expect(() => cenario.pedir(1, 'salas', {'nome': 'a' * 16, 'mostrar_nome': true, 'publica': false}), lanca_erro(400));

  });


  test('servidor responde por HTTP com permissão para o site', () async {

    HttpServer servidor = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);

    addTearDown(() => servidor.close(force: true));
    servidor.listen(Aplicacao(leaderboard: Leaderboard()).atender);

    HttpClient cliente = HttpClient();
    HttpClientRequest pedido = await cliente.post('127.0.0.1', servidor.port, '/salas');

    pedido.write(jsonEncode({'id': criar_id(1), 'nome': 'Ana', 'mostrar_nome': true, 'publica': false}));

    HttpClientResponse resposta = await pedido.close();
    Map<String, dynamic> dados = jsonDecode(await resposta.transform(utf8.decoder).join()) as Map<String, dynamic>;

    expect(resposta.statusCode, 200);
    expect(resposta.headers.value('access-control-allow-origin'), '*');
    expect(resposta.headers.contentLength, greaterThan(0));
    expect(dados['codigo'], matches(RegExp(r'^[A-Z]{5}$')));

    HttpClientRequest pedido_invalido = await cliente.post('127.0.0.1', servidor.port, '/salas');

    pedido_invalido.write('quebrado');

    expect((await pedido_invalido.close()).statusCode, 400);

  });


  test('leaderboard continua salvo em arquivo', () async {

    Directory pasta = await Directory.systemTemp.createTemp('leaderboard_teste');

    addTearDown(() => pasta.delete(recursive: true));

    File arquivo = File('${pasta.path}/dados/partidas.json');
    Leaderboard primeiro = Leaderboard(arquivo: arquivo);
    DateTime agora = DateTime(2026, 11, 26);
    Sala sala = Sala(codigo: 'A', id_partida: 'p1', publica: true, criada_em: agora);

    sala.entrar(criar_id(1), 'Ana', true, agora);
    sala.jogadores.single.jogou = true;
    primeiro.registrar(sala, agora);

    await primeiro.fila_gravacao;

    Leaderboard segundo = Leaderboard(arquivo: arquivo);

    await segundo.carregar();

    expect(segundo.partidas.single.jogadores.single.nome, 'Ana');

  });

}
