import 'dart:js_interop';

import 'armazenamento.dart';


// Acesso à memória do navegador (localStorage)
@JS('localStorage')
external MemoriaNavegador get memoria_navegador;


extension type MemoriaNavegador(JSObject objeto) implements JSObject {

  @JS('getItem')
  external String? ler_item(String chave);

  @JS('setItem')
  external void gravar_item(String chave, String valor);

}


// Salva os JSON na memória do navegador
class ArmazenamentoLocal implements Armazenamento {

  // Lê o JSON guardado com esse nome
  @override
  Future<String?> ler(String nome_arquivo) async {

    try {

      return memoria_navegador.ler_item(nome_arquivo);

    } on Object {

      return null;

    }

  }


  // Guarda o JSON com esse nome
  @override
  Future<void> gravar(String nome_arquivo, String conteudo) async {

    memoria_navegador.gravar_item(nome_arquivo, conteudo);

  }

}
