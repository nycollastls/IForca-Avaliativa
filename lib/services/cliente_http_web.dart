import 'dart:js_interop';

import 'cliente_http.dart';


// Acesso ao fetch do navegador
@JS('fetch')
external JSPromise<RespostaNavegador> buscar_endereco(String endereco, JSObject opcoes);


// Resposta do fetch
extension type RespostaNavegador(JSObject objeto) implements JSObject {

  @JS('status')
  external int get codigo;

  @JS('text')
  external JSPromise<JSString> ler_texto();

}


// Cliente HTTP da versão web
class ClienteHttpLocal implements ClienteHttp {

  // Envia o pedido pelo fetch e devolve a resposta
  @override
  Future<RespostaHttp> enviar(String endereco, String corpo) async {

    JSObject opcoes = {

      'method': 'POST',
      'headers': {'Content-Type': 'text/plain'},
      'body': corpo,
      'cache': 'no-store',

    }.jsify()! as JSObject;

    RespostaNavegador resposta = await buscar_endereco(endereco, opcoes).toDart;
    JSString texto = await resposta.ler_texto().toDart;

    return RespostaHttp(resposta.codigo, texto.toDart);

  }

}
