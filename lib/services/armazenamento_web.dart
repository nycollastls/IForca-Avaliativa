import 'dart:js_interop';

import 'armazenamento.dart';


@JS('localStorage')
external MemoriaNavegador get memoria_navegador;


extension type MemoriaNavegador(JSObject objeto) implements JSObject {

  @JS('getItem')
  external String? ler_item(String chave);

  @JS('setItem')
  external void gravar_item(String chave, String valor);

}


class ArmazenamentoLocal implements Armazenamento {

  @override
  Future<String?> ler(String nome_arquivo) async {

    try {

      return memoria_navegador.ler_item(nome_arquivo);

    } on Object {

      return null;

    }

  }


  @override
  Future<void> gravar(String nome_arquivo, String conteudo) async {

    memoria_navegador.gravar_item(nome_arquivo, conteudo);

  }

}
