import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../models/perfil.dart';
import 'armazenamento.dart';


class RepositorioPerfil extends ChangeNotifier {

  static const String nome_arquivo = 'perfil.json';

  final Armazenamento armazenamento;

  Perfil perfil = Perfil.novo();


  RepositorioPerfil(this.armazenamento);


  bool get tem_nome => perfil.nome.isNotEmpty;


  Future<void> carregar() async {

    String? conteudo = await armazenamento.ler(nome_arquivo);

    if (conteudo != null) {

      try {

        perfil = Perfil.de_json(jsonDecode(conteudo) as Map<String, dynamic>);

      } on Object {

        perfil = Perfil.novo();

      }

    }

    notifyListeners();

  }


  Future<void> mudar_nome(String nome) {

    perfil.nome = nome.trim().replaceAll(RegExp(r'\s+'), ' ');

    return gravar();

  }


  Future<void> alterar(void Function(Perfil perfil) mudanca) {

    mudanca(perfil);

    return gravar();

  }


  Future<void> gravar() async {

    notifyListeners();

    await armazenamento.gravar(nome_arquivo, jsonEncode(perfil.para_json()));

  }

}
