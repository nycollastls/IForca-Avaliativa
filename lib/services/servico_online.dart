import 'dart:convert';

import '../models/partida_leaderboard.dart';
import '../models/perfil.dart';
import '../models/resultado.dart';
import '../models/sala_desafio.dart';
import 'cliente_http.dart';


const String endereco_servidor = String.fromEnvironment(

  'ENDERECO_SERVIDOR',
  defaultValue: 'http://localhost:8124',

);

const Duration limite_inicial = Duration(seconds: 80);
const Duration limite_rapido = Duration(seconds: 12);


class ErroServidor implements Exception {

  final String mensagem;
  final int codigo;


  const ErroServidor(this.mensagem, {this.codigo = 0});


  bool get sala_perdida => codigo == 404;

}


class ServicoOnline {

  final ClienteHttp cliente;


  ServicoOnline(this.cliente);


  Future<Map<String, dynamic>> pedir(String caminho, Map<String, dynamic> dados, Duration limite) async {

    RespostaHttp resposta;

    try {

      resposta = await cliente.enviar('$endereco_servidor/$caminho', jsonEncode(dados)).timeout(limite);

    } on Object {

      throw const ErroServidor('Não foi possível falar com o servidor. Confira a internet e tente de novo.');

    }

    Map<String, dynamic> conteudo;

    try {

      conteudo = jsonDecode(resposta.corpo) as Map<String, dynamic>;

    } on Object {

      throw const ErroServidor('O servidor não respondeu como esperado. Tente de novo em instantes.');

    }

    if (resposta.codigo != 200) {

      Object? mensagem = conteudo['erro'];

      throw ErroServidor(mensagem is String ? mensagem : 'O servidor recusou o pedido.', codigo: resposta.codigo);

    }

    return conteudo;

  }


  Future<SalaDesafio> pedir_sala(String caminho, Map<String, dynamic> dados, Duration limite) async {

    return SalaDesafio.de_json(await pedir(caminho, dados, limite));

  }


  Map<String, dynamic> identificar(Perfil perfil) {

    return {'id': perfil.id, 'nome': perfil.nome, 'mostrar_nome': perfil.aparecer_leaderboard};

  }


  Future<SalaDesafio> criar_sala(Perfil perfil, bool publica) {

    return pedir_sala('salas', {...identificar(perfil), 'publica': publica}, limite_inicial);

  }


  Future<SalaDesafio> entrar_sala(Perfil perfil, String codigo) {

    return pedir_sala('salas/$codigo/entrar', identificar(perfil), limite_inicial);

  }


  Future<SalaDesafio> consultar_sala(Perfil perfil, String codigo) {

    return pedir_sala('salas/$codigo/estado', {'id': perfil.id}, limite_rapido);

  }


  Future<SalaDesafio> iniciar_sala(Perfil perfil, String codigo) {

    return pedir_sala('salas/$codigo/iniciar', {'id': perfil.id}, limite_rapido);

  }


  Future<SalaDesafio> enviar_palavra(Perfil perfil, String codigo, String palavra, String dica) {

    return pedir_sala('salas/$codigo/palavra', {'id': perfil.id, 'palavra': palavra, 'dica': dica}, limite_rapido);

  }


  Future<SalaDesafio> enviar_resultado(Perfil perfil, String codigo, int rodada, Resultado resultado) {

    return pedir_sala(

      'salas/$codigo/resultado',
      {'id': perfil.id, 'rodada': rodada, 'venceu': resultado.venceu, 'pontos': resultado.pontos},
      limite_rapido,

    );

  }


  Future<SalaDesafio> encerrar_rodada(Perfil perfil, String codigo, int rodada) {

    return pedir_sala('salas/$codigo/encerrar', {'id': perfil.id, 'rodada': rodada}, limite_rapido);

  }


  Future<SalaDesafio> proxima_rodada(Perfil perfil, String codigo, int rodada) {

    return pedir_sala('salas/$codigo/proxima', {'id': perfil.id, 'rodada': rodada}, limite_rapido);

  }


  Future<void> sair_sala(Perfil perfil, String codigo) async {

    await pedir('salas/$codigo/sair', {'id': perfil.id}, limite_rapido);

  }


  Future<void> mudar_nome(Perfil perfil) async {

    await pedir('leaderboard/nome', {'id': perfil.id, 'mostrar_nome': perfil.aparecer_leaderboard}, limite_inicial);

  }


  Future<List<PartidaLeaderboard>> listar_partidas(Perfil perfil, bool por_pontos) async {

    Map<String, dynamic> dados = await pedir(

      'leaderboard/listar',
      {'id': perfil.id, 'por_pontos': por_pontos},
      limite_inicial,

    );

    return [

      for (dynamic item in dados['partidas'] as List<dynamic>)

        PartidaLeaderboard.de_json(item as Map<String, dynamic>),

    ];

  }

}
