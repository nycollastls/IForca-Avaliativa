// Letras acentuadas e a versão sem acento de cada uma
const Map<String, String> letras_sem_acento = {

  'Á': 'A',
  'À': 'A',
  'Â': 'A',
  'Ã': 'A',
  'É': 'E',
  'Ê': 'E',
  'Í': 'I',
  'Ó': 'O',
  'Ô': 'O',
  'Õ': 'O',
  'Ú': 'U',
  'Ü': 'U',
  'Ç': 'C',

};


// Deixa o texto em maiúsculas, sem acentos e sem espaços repetidos
String normalizar_texto(String texto) {

  String texto_normalizado = texto.trim().toUpperCase();

  for (String letra in letras_sem_acento.keys) {

    texto_normalizado = texto_normalizado.replaceAll(letra, letras_sem_acento[letra]!);

  }

  return texto_normalizado.replaceAll(RegExp(r'\s+'), ' ');

}


// Diz se o caractere é uma letra de A a Z
bool eh_letra(String caractere) {

  return RegExp(r'^[A-Z]$').hasMatch(normalizar_texto(caractere));

}
