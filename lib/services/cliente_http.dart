// Resposta do servidor: código e texto
class RespostaHttp {

  final int codigo;
  final String corpo;


  const RespostaHttp(this.codigo, this.corpo);

}


// O que todo cliente HTTP precisa saber fazer
abstract interface class ClienteHttp {

  Future<RespostaHttp> enviar(String endereco, String corpo);

}
