class RespostaHttp {

  final int codigo;
  final String corpo;


  const RespostaHttp(this.codigo, this.corpo);

}


abstract interface class ClienteHttp {

  Future<RespostaHttp> enviar(String endereco, String corpo);

}
