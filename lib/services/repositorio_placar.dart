import 'dart:convert';

import '../models/duelo.dart';
import '../models/placar.dart';
import '../models/resultado.dart';
import 'armazenamento.dart';
import 'regras_pontuacao.dart';


class RepositorioPlacar {

  static const String arquivo_placar = 'placar.json';
  static const String arquivo_duelo = 'duelo.json';

  final Armazenamento armazenamento;

  Placar placar = Placar();
  Duelo? duelo;


  RepositorioPlacar(this.armazenamento);


  Future<void> carregar() async {

    placar = await ler_dados(arquivo_placar, Placar.de_json) ?? Placar();
    duelo = await ler_dados(arquivo_duelo, Duelo.de_json);

  }


  Future<T?> ler_dados<T>(String nome_arquivo, T Function(Map<String, dynamic>) converter) async {

    String? conteudo = await armazenamento.ler(nome_arquivo);

    if (conteudo == null) {

      return null;

    }

    try {

      return converter(jsonDecode(conteudo) as Map<String, dynamic>);

    } on Object {

      return null;

    }

  }


  Future<void> registrar_partida(Resultado resultado) async {

    aplicar_resultado(placar, resultado);

    await gravar_placar();

  }


  Future<void> zerar_placar() async {

    placar = Placar();

    await gravar_placar();

  }


  Future<void> gravar_placar() async {

    await armazenamento.gravar(arquivo_placar, jsonEncode(placar.para_json()));

  }


  Future<void> iniciar_duelo(String primeiro_nome, String segundo_nome) async {

    duelo = Duelo(nomes: [primeiro_nome.trim(), segundo_nome.trim()]);

    await gravar_duelo();

  }


  Future<void> registrar_rodada(Resultado resultado) async {

    Duelo? duelo_atual = duelo;

    if (duelo_atual == null) {

      return;

    }

    int indice = duelo_atual.indice_adivinhador;

    duelo_atual.pontos[indice] = somar_pontos(duelo_atual.pontos[indice], resultado.pontos);
    duelo_atual.indice_desafiante = indice;

    await gravar_duelo();

  }


  Future<void> encerrar_duelo() async {

    duelo = null;

    await gravar_duelo();

  }


  Future<void> gravar_duelo() async {

    await armazenamento.gravar(arquivo_duelo, jsonEncode(duelo?.para_json()));

  }

}
