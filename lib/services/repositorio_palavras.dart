import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';

import '../models/categoria.dart';
import '../models/nivel.dart';
import '../models/palavra.dart';
import 'armazenamento.dart';


class RepositorioPalavras {

  static const String nome_arquivo = 'palavras_cadastradas.json';

  final Armazenamento armazenamento;
  final Random sorteador = Random();

  final List<Palavra> palavras_iniciais = [];
  final List<Palavra> palavras_cadastradas = [];


  RepositorioPalavras(this.armazenamento);


  List<Palavra> get todas => [...palavras_iniciais, ...palavras_cadastradas];


  Future<void> carregar() async {

    palavras_iniciais.clear();
    palavras_cadastradas.clear();

    for (Categoria categoria in Categoria.values) {

      palavras_iniciais.addAll(await carregar_palavras(categoria));

    }

    palavras_cadastradas.addAll(await ler_cadastradas());

  }


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


  Future<void> adicionar(Palavra palavra) async {

    await gravar([...palavras_cadastradas, palavra]);

    palavras_cadastradas.add(palavra);

  }


  Future<void> remover(Palavra palavra) async {

    List<Palavra> restantes = [...palavras_cadastradas]..remove(palavra);

    await gravar(restantes);

    palavras_cadastradas.remove(palavra);

  }


  Future<void> gravar(List<Palavra> palavras) async {

    List<Map<String, dynamic>> lista = [for (Palavra palavra in palavras) palavra.para_json()];

    await armazenamento.gravar(nome_arquivo, jsonEncode(lista));

  }


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


Future<List<Palavra>> carregar_palavras(Categoria categoria) async {

  String conteudo = await rootBundle.loadString(categoria.caminho_arquivo);

  return converter_lista(conteudo);

}


List<Palavra> converter_lista(String conteudo) {

  List<dynamic> itens = jsonDecode(conteudo) as List<dynamic>;

  return [

    for (dynamic item in itens)

      Palavra.de_json(item as Map<String, dynamic>),

  ];

}
