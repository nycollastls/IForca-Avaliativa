import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'leaderboard.dart';
import 'sala.dart';
import 'validacao.dart';


const int maximo_salas = 300;
const int maximo_bytes = 4096;
const int tamanho_codigo = 5;
const int tamanho_id_partida = 16;
const String letras_codigo = 'ABCDEFGHJKLMNPQRSTUVWXYZ';

const Duration tempo_sala_vazia = Duration(minutes: 30);


class Aplicacao {

  final Leaderboard leaderboard;
  final DateTime Function() relogio;
  final Map<String, Sala> salas = {};
  final Random sorteador = Random.secure();


  Aplicacao({required this.leaderboard, this.relogio = DateTime.now});


  Future<void> atender(HttpRequest requisicao) async {

    int codigo_http = 200;
    Map<String, dynamic> conteudo;

    try {

      conteudo = await tratar(requisicao);

    } on ErroRegra catch (erro) {

      codigo_http = erro.codigo_http;
      conteudo = {'erro': erro.mensagem};

    } on FormatException {

      codigo_http = 400;
      conteudo = {'erro': 'Pedido inválido.'};

    } on Object catch (erro) {

      stderr.writeln('Erro inesperado: $erro');
      codigo_http = 500;
      conteudo = {'erro': 'O servidor encontrou um erro.'};

    }

    try {

      await responder(requisicao.response, codigo_http, conteudo);

    } on Object catch (erro) {

      stderr.writeln('Falha ao responder: $erro');

    }

  }


  Future<void> responder(HttpResponse resposta, int codigo_http, Map<String, dynamic> conteudo) async {

    List<int> bytes = utf8.encode(jsonEncode(conteudo));

    resposta.statusCode = codigo_http;
    resposta.headers.contentType = ContentType.json;
    resposta.headers.set('Access-Control-Allow-Origin', '*');
    resposta.headers.set('Cache-Control', 'no-store');
    resposta.contentLength = bytes.length;
    resposta.add(bytes);

    await resposta.close();

  }


  Future<Map<String, dynamic>> tratar(HttpRequest requisicao) async {

    List<String> partes = requisicao.uri.pathSegments.where((parte) => parte.isNotEmpty).toList();

    if (partes.length == 1 && partes.first == 'saude') {

      return {'situacao': 'ok'};

    }

    if (requisicao.method != 'POST') {

      throw const ErroRegra(405, 'Método não aceito.');

    }

    return processar(partes, await ler_corpo(requisicao));

  }


  Map<String, dynamic> processar(List<String> partes, Map<String, dynamic> dados) {

    String id = ler_id(dados);

    remover_salas_antigas();

    if (partes.isNotEmpty && partes.first == 'leaderboard') {

      return tratar_leaderboard(partes, id, dados);

    }

    if (partes.isNotEmpty && partes.first == 'salas') {

      return tratar_sala(partes, id, dados);

    }

    throw const ErroRegra(404, 'Endereço não encontrado.');

  }


  Future<Map<String, dynamic>> ler_corpo(HttpRequest requisicao) async {

    List<int> bytes = [];

    await for (List<int> parte in requisicao) {

      bytes.addAll(parte);

      if (bytes.length > maximo_bytes) {

        throw const ErroRegra(413, 'Pedido grande demais.');

      }

    }

    Object? dados = jsonDecode(utf8.decode(bytes));

    if (dados is! Map<String, dynamic>) {

      throw const ErroRegra(400, 'Pedido inválido.');

    }

    return dados;

  }


  Map<String, dynamic> tratar_leaderboard(List<String> partes, String id, Map<String, dynamic> dados) {

    String acao = partes.length == 2 ? partes[1] : '';

    if (acao == 'nome') {

      mudar_nome(id, ler_opcao(dados, 'mostrar_nome'));

      return {'mudou': true};

    }

    if (acao == 'listar') {

      Set<String> abertas = {for (Sala sala in salas.values) sala.id_partida};

      return {'partidas': leaderboard.listar(id, ler_opcao(dados, 'por_pontos'), abertas)};

    }

    throw const ErroRegra(404, 'Endereço não encontrado.');

  }


  void mudar_nome(String id, bool mostrar) {

    for (Sala sala in salas.values) {

      sala.historico[id]?.mostrar_nome = mostrar;

    }

    leaderboard.mudar_nome(id, mostrar);

  }


  void publicar(Sala sala, DateTime agora) {

    if (!sala.publica || sala.rodadas_publicadas == sala.rodadas_concluidas) {

      return;

    }

    sala.rodadas_publicadas = sala.rodadas_concluidas;
    leaderboard.registrar(sala, agora);

  }


  Map<String, dynamic> tratar_sala(List<String> partes, String id, Map<String, dynamic> dados) {

    DateTime agora = relogio();

    if (partes.length == 1) {

      return criar_sala(id, dados, agora).montar_visao(id, agora);

    }

    Sala? sala = salas[partes[1].toUpperCase()];

    if (sala == null || partes.length != 3) {

      throw const ErroRegra(404, 'Sala não encontrada. Confira o código.');

    }

    String acao = partes[2];

    if (acao == 'sair') {

      sala.sair(id, agora);
      publicar(sala, agora);

      if (sala.jogadores.isEmpty) {

        salas.remove(sala.codigo);

      }

      return {'saiu': true};

    }

    if (acao == 'entrar') {

      sala.atualizar(agora);
      sala.entrar(id, ler_nome(dados), ler_opcao(dados, 'mostrar_nome'), agora);

    }

    sala.marcar_presenca(id, agora);

    executar_acao(sala, acao, id, dados, agora);
    publicar(sala, agora);

    return sala.montar_visao(id, agora);

  }


  void executar_acao(Sala sala, String acao, String id, Map<String, dynamic> dados, DateTime agora) {

    switch (acao) {

      case 'entrar':
      case 'estado':

        return;

      case 'iniciar':

        sala.iniciar(id, agora);

      case 'palavra':

        sala.definir_palavra(id, ler_palavra(dados), ler_dica(dados), agora);

      case 'resultado':

        int rodada = ler_numero(dados, 'rodada', 0, 1 << 30);
        int pontos = ler_numero(dados, 'pontos', -desconto_maximo_rodada, pontos_maximos_rodada);

        sala.registrar_resultado(id, rodada, dados['venceu'] == true, pontos, agora);

      case 'encerrar':

        sala.encerrar_rodada(id, ler_numero(dados, 'rodada', 0, 1 << 30), agora);

      case 'proxima':

        sala.proxima_rodada(id, ler_numero(dados, 'rodada', 0, 1 << 30), agora);

      default:

        throw const ErroRegra(404, 'Ação não encontrada.');

    }

  }


  Sala criar_sala(String id, Map<String, dynamic> dados, DateTime agora) {

    String nome = ler_nome(dados);
    bool mostrar_nome = ler_opcao(dados, 'mostrar_nome');

    if (salas.length >= maximo_salas) {

      throw const ErroRegra(503, 'Há salas demais abertas. Tente de novo em alguns minutos.');

    }

    String codigo = sortear_letras(tamanho_codigo);

    while (salas.containsKey(codigo)) {

      codigo = sortear_letras(tamanho_codigo);

    }

    Sala sala = Sala(

      codigo: codigo,
      id_partida: sortear_letras(tamanho_id_partida),
      publica: ler_opcao(dados, 'publica'),
      criada_em: agora,

    );

    sala.entrar(id, nome, mostrar_nome, agora);
    salas[codigo] = sala;

    return sala;

  }


  String sortear_letras(int total) {

    String letras = '';

    for (int indice = 0; indice < total; indice++) {

      letras += letras_codigo[sorteador.nextInt(letras_codigo.length)];

    }

    return letras;

  }


  void remover_salas_antigas() {

    DateTime agora = relogio();

    salas.removeWhere((codigo, sala) => agora.difference(sala.usada_em) > tempo_sala_vazia);

  }

}
