import 'dart:convert';

import 'package:flutter/services.dart';

import '../modelos/linguagem.dart';


Future<List<String>> carregar_palavras(Linguagem linguagem) async {

  String conteudo = await rootBundle.loadString(linguagem.caminho_arquivo);
  Map<String, dynamic> dados = jsonDecode(conteudo);

  return List<String>.from(dados['palavras']);

}
