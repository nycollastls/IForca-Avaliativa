import 'dart:convert';
import 'dart:io';

import 'cliente_http.dart';


class ClienteHttpLocal implements ClienteHttp {

  final HttpClient cliente = HttpClient();


  @override
  Future<RespostaHttp> enviar(String endereco, String corpo) async {

    HttpClientRequest pedido = await cliente.postUrl(Uri.parse(endereco));

    pedido.headers.contentType = ContentType.text;
    pedido.add(utf8.encode(corpo));

    HttpClientResponse resposta = await pedido.close();
    String texto = await resposta.transform(utf8.decoder).join();

    return RespostaHttp(resposta.statusCode, texto);

  }

}
