// Limites dos textos recebidos
const int maximo_nome = 15;
const int maximo_palavra = 18;
const int maximo_dica = 100;


// Erro com o código HTTP e a mensagem
class ErroRegra implements Exception {

  final int codigo_http;
  final String mensagem;


  const ErroRegra(this.codigo_http, this.mensagem);

}


// Lê um texto do pedido e tira caracteres estranhos
String ler_texto(Map<String, dynamic> dados, String campo) {

  Object? valor = dados[campo];

  if (valor is! String) {

    throw ErroRegra(400, 'Campo inválido: $campo.');

  }

  return valor.replaceAll(RegExp(r'[\x00-\x1F\x7F]'), ' ').replaceAll(RegExp(r'\s+'), ' ').trim();

}


// Lê um número do pedido dentro de um limite
int ler_numero(Map<String, dynamic> dados, String campo, int minimo, int maximo) {

  Object? valor = dados[campo];

  if (valor is! int) {

    throw ErroRegra(400, 'Campo inválido: $campo.');

  }

  return valor.clamp(minimo, maximo);

}


// Lê um verdadeiro ou falso do pedido
bool ler_opcao(Map<String, dynamic> dados, String campo) {

  Object? valor = dados[campo];

  if (valor is! bool) {

    throw ErroRegra(400, 'Campo inválido: $campo.');

  }

  return valor;

}


// Lê a identificação do jogador
String ler_id(Map<String, dynamic> dados) {

  String id = ler_texto(dados, 'id');

  if (!RegExp(r'^[0-9a-f]{32}$').hasMatch(id)) {

    throw const ErroRegra(400, 'Identificação inválida.');

  }

  return id;

}


// Lê o nome do jogador
String ler_nome(Map<String, dynamic> dados) {

  String nome = ler_texto(dados, 'nome');

  if (nome.isEmpty || nome.length > maximo_nome) {

    throw const ErroRegra(400, 'O nome precisa ter de 1 a $maximo_nome caracteres.');

  }

  return nome;

}


// Lê a palavra secreta
String ler_palavra(Map<String, dynamic> dados) {

  String palavra = ler_texto(dados, 'palavra');
  RegExp formato = RegExp(r'^[A-Za-zÀ-ÖØ-öø-ÿ][A-Za-zÀ-ÖØ-öø-ÿ -]+$');

  if (palavra.length > maximo_palavra || !formato.hasMatch(palavra)) {

    throw const ErroRegra(400, 'Palavra inválida.');

  }

  return palavra;

}


// Lê a dica
String ler_dica(Map<String, dynamic> dados) {

  String dica = ler_texto(dados, 'dica');

  if (dica.isEmpty || dica.length > maximo_dica) {

    throw const ErroRegra(400, 'Dica inválida.');

  }

  return dica;

}


// Letras com acento e a versão sem acento
const Map<String, String> letras_sem_acento = {

  'Á': 'A', 'À': 'A', 'Â': 'A', 'Ã': 'A', 'Ä': 'A',
  'É': 'E', 'È': 'E', 'Ê': 'E', 'Ë': 'E',
  'Í': 'I', 'Ì': 'I', 'Î': 'I', 'Ï': 'I',
  'Ó': 'O', 'Ò': 'O', 'Ô': 'O', 'Õ': 'O', 'Ö': 'O',
  'Ú': 'U', 'Ù': 'U', 'Û': 'U', 'Ü': 'U',
  'Ç': 'C', 'Ñ': 'N',

};


// Passa a letra para maiúscula e sem acento
String normalizar_letra(String letra) {

  String maiuscula = letra.toUpperCase();

  return letras_sem_acento[maiuscula] ?? maiuscula;

}


// Lê as letras que o jogador já tentou
Set<String> ler_letras(Map<String, dynamic> dados) {

  Object? valor = dados['letras'];
  RegExp formato = RegExp(r'^[A-Z]$');

  if (valor is! List || valor.length > 26 || valor.any((letra) => letra is! String || !formato.hasMatch(letra))) {

    throw const ErroRegra(400, 'Letras inválidas.');

  }

  return {for (Object? letra in valor) letra as String};

}
