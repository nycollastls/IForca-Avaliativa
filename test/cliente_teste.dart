import 'dart:convert';

import 'package:forca/services/cliente_http.dart';

import '../servidor/bin/aplicacao.dart';
import '../servidor/bin/leaderboard.dart';
import '../servidor/bin/validacao.dart';


class ClienteTeste implements ClienteHttp {

  final Aplicacao aplicacao;

  bool fora_do_ar = false;
  int total_pedidos = 0;
  int respostas_vazias = 0;


  ClienteTeste({Aplicacao? aplicacao}) : aplicacao = aplicacao ?? Aplicacao(leaderboard: Leaderboard());


  @override
  Future<RespostaHttp> enviar(String endereco, String corpo) async {

    total_pedidos++;

    if (fora_do_ar) {

      throw Exception('Sem rede');

    }

    Map<String, dynamic> dados = jsonDecode(corpo) as Map<String, dynamic>;

    try {

      String conteudo = jsonEncode(aplicacao.processar(Uri.parse(endereco).pathSegments, dados));

      if (respostas_vazias > 0) {

        respostas_vazias--;

        return const RespostaHttp(200, '');

      }

      return RespostaHttp(200, conteudo);

    } on ErroRegra catch (erro) {

      return RespostaHttp(erro.codigo_http, jsonEncode({'erro': erro.mensagem}));

    }

  }

}
