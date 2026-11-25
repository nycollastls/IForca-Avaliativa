import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';

import '../models/categoria.dart';
import '../models/nivel.dart';
import '../models/palavra.dart';
import 'armazenamento.dart';


// Banco de palavras: as que vêm com o jogo e as cadastradas
class RepositorioPalavras {

  static const String nome_arquivo = 'palavras_cadastradas.json';

  final Armazenamento armazenamento;
  final Random sorteador = Random();

  final List<Palavra> palavras_iniciais = [];
  final List<Palavra> palavras_cadastradas = [];


  RepositorioPalavras(this.armazenamento);


  List<Palavra> get todas => [...palavras_iniciais, ...palavras_cadastradas];


  // Carrega as palavras de cada categoria e as cadastradas
  Future<void> carregar() async {

    palavras_iniciais.clear();
    palavras_cadastradas.clear();

    for (Categoria categoria in Categoria.values) {

      palavras_iniciais.addAll(await carregar_palavras(categoria));

    }

    palavras_cadastradas.addAll(await ler_cadastradas());

  }


  // Lê as palavras cadastradas; se o arquivo estiver quebrado, ignora
  Future<List<Palavra>> ler_cadastradas() async {

    String? conteudo = await armazenamento.ler(nome_arquivo);

    if (conteudo == null) {

      return [];

    }

    try {

      return converter_lista(conteudo);

    } on Object {

      return [];

    }

  }


  // Salva uma palavra nova
  Future<void> adicionar(Palavra palavra) async {

    await gravar([...palavras_cadastradas, palavra]);

    palavras_cadastradas.add(palavra);

  }


  // Exclui uma palavra cadastrada
  Future<void> remover(Palavra palavra) async {

    List<Palavra> restantes = [...palavras_cadastradas]..remove(palavra);

    await gravar(restantes);

    palavras_cadastradas.remove(palavra);

  }


  // Grava as palavras cadastradas em JSON
  Future<void> gravar(List<Palavra> palavras) async {

    List<Map<String, dynamic>> lista = [for (Palavra palavra in palavras) palavra.para_json()];

    await armazenamento.gravar(nome_arquivo, jsonEncode(lista));

  }


  // Separa as palavras de uma categoria e de um nível
  List<Palavra> filtrar(Categoria categoria, Nivel? nivel) {

    List<Palavra> selecionadas = [];

    for (Palavra palavra in todas) {

      bool mesmo_nivel = nivel == null || palavra.nivel == nivel;

      if (palavra.categoria == categoria && mesmo_nivel) {

        selecionadas.add(palavra);

      }

    }

    return selecionadas;

  }


  // Sorteia uma palavra sem repetir a anterior
  Palavra? sortear(Categoria categoria, Nivel? nivel, {Palavra? anterior}) {

    List<Palavra> candidatas = filtrar(categoria, nivel);

    if (candidatas.length > 1) {

      candidatas.remove(anterior);

    }

    if (candidatas.isEmpty) {

      return null;

    }

    return candidatas[sorteador.nextInt(candidatas.length)];

  }

}


// Lê o arquivo JSON de uma categoria
Future<List<Palavra>> carregar_palavras(Categoria categoria) async {

  String conteudo = await rootBundle.loadString(categoria.caminho_arquivo);

  return converter_lista(conteudo);

}


// Converte o texto JSON em lista de palavras
List<Palavra> converter_lista(String conteudo) {

  List<dynamic> itens = jsonDecode(conteudo) as List<dynamic>;

  return [

    for (dynamic item in itens)

      Palavra.de_json(item as Map<String, dynamic>),

  ];

}
