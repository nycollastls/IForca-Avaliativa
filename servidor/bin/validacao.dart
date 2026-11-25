const int maximo_nome = 15;
const int maximo_palavra = 18;
const int maximo_dica = 100;


class ErroRegra implements Exception {

  final int codigo_http;
  final String mensagem;


  const ErroRegra(this.codigo_http, this.mensagem);

}


String ler_texto(Map<String, dynamic> dados, String campo) {

  Object? valor = dados[campo];

  if (valor is! String) {

    throw ErroRegra(400, 'Campo inválido: $campo.');

  }

  return valor.replaceAll(RegExp(r'[\x00-\x1F\x7F]'), ' ').replaceAll(RegExp(r'\s+'), ' ').trim();

}


int ler_numero(Map<String, dynamic> dados, String campo, int minimo, int maximo) {

  Object? valor = dados[campo];

  if (valor is! int) {

    throw ErroRegra(400, 'Campo inválido: $campo.');

  }

  return valor.clamp(minimo, maximo);

}


bool ler_opcao(Map<String, dynamic> dados, String campo) {

  Object? valor = dados[campo];

  if (valor is! bool) {

    throw ErroRegra(400, 'Campo inválido: $campo.');

  }

  return valor;

}


String ler_id(Map<String, dynamic> dados) {

  String id = ler_texto(dados, 'id');

  if (!RegExp(r'^[0-9a-f]{32}$').hasMatch(id)) {

    throw const ErroRegra(400, 'Identificação inválida.');

  }

  return id;

}


String ler_nome(Map<String, dynamic> dados) {

  String nome = ler_texto(dados, 'nome');

  if (nome.isEmpty || nome.length > maximo_nome) {

    throw const ErroRegra(400, 'O nome precisa ter de 1 a $maximo_nome caracteres.');

  }

  return nome;

}


String ler_palavra(Map<String, dynamic> dados) {

  String palavra = ler_texto(dados, 'palavra');
  RegExp formato = RegExp(r'^[A-Za-zÀ-ÖØ-öø-ÿ][A-Za-zÀ-ÖØ-öø-ÿ -]+$');

  if (palavra.length > maximo_palavra || !formato.hasMatch(palavra)) {

    throw const ErroRegra(400, 'Palavra inválida.');

  }

  return palavra;

}


String ler_dica(Map<String, dynamic> dados) {

  String dica = ler_texto(dados, 'dica');

  if (dica.isEmpty || dica.length > maximo_dica) {

    throw const ErroRegra(400, 'Dica inválida.');

  }

  return dica;

}
