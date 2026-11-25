import 'dart:convert';

import '../models/duelo.dart';
import '../models/placar.dart';
import '../models/resultado.dart';
import 'armazenamento.dart';
import 'regras_pontuacao.dart';


// Guarda o placar do jogo solo e o duelo
class RepositorioPlacar {

  static const String arquivo_placar = 'placar.json';
  static const String arquivo_duelo = 'duelo.json';

  final Armazenamento armazenamento;

  Placar placar = Placar();
  Duelo? duelo;


  RepositorioPlacar(this.armazenamento);


  // Carrega o placar e o duelo salvos
  Future<void> carregar() async {

    placar = await ler_dados(arquivo_placar, Placar.de_json) ?? Placar();
    duelo = await ler_dados(arquivo_duelo, Duelo.de_json);

  }


  // Lê um JSON salvo; se estiver quebrado, ignora
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


  // Registra o fim de uma partida solo
  Future<void> registrar_partida(Resultado resultado) async {

    aplicar_resultado(placar, resultado);

    await gravar_placar();

  }


  // Zera o placar
  Future<void> zerar_placar() async {

    placar = Placar();

    await gravar_placar();

  }


  // Grava o placar em JSON
  Future<void> gravar_placar() async {

    await armazenamento.gravar(arquivo_placar, jsonEncode(placar.para_json()));

  }


  // Começa um duelo novo
  Future<void> iniciar_duelo(String primeiro_nome, String segundo_nome) async {

    duelo = Duelo(nomes: [primeiro_nome.trim(), segundo_nome.trim()]);

    await gravar_duelo();

  }


  // Soma os pontos da rodada e troca a vez no duelo
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


  // Encerra o duelo
  Future<void> encerrar_duelo() async {

    duelo = null;

    await gravar_duelo();

  }


  // Grava o duelo em JSON
  Future<void> gravar_duelo() async {

    await armazenamento.gravar(arquivo_duelo, jsonEncode(duelo?.para_json()));

  }

}
