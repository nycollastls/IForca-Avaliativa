import '../models/palavra.dart';
import 'texto.dart';


// Limites usados nas validações
const int minimo_letras = 2;
const int maximo_caracteres = 18;
const int minimo_dica = 5;
const int maximo_dica = 100;
const int maximo_nome = 15;
const int tamanho_codigo = 5;


// Valida a palavra digitada
String? validar_texto(String? valor) {

  String texto = normalizar_texto(valor ?? '');
  int total_letras = texto.replaceAll(RegExp('[^A-Z]'), '').length;

  if (texto.isEmpty) {

    return 'Digite a palavra.';

  }

  if (!RegExp(r'^[A-Z][A-Z -]*$').hasMatch(texto)) {

    return 'Use só letras, espaço ou hífen, começando por letra.';

  }

  if (total_letras < minimo_letras) {

    return 'A palavra precisa de pelo menos $minimo_letras letras.';

  }

  if (texto.length > maximo_caracteres) {

    return 'Use no máximo $maximo_caracteres caracteres.';

  }

  return null;

}


// Valida a dica e não deixa ela entregar a palavra
String? validar_dica(String? valor, String palavra) {

  String dica = normalizar_texto(valor ?? '');
  String palavra_normalizada = normalizar_texto(palavra);

  if (dica.length < minimo_dica) {

    return 'Escreva uma dica com pelo menos $minimo_dica caracteres.';

  }

  if (dica.length > maximo_dica) {

    return 'Use no máximo $maximo_dica caracteres na dica.';

  }

  if (palavra_normalizada.length >= minimo_letras && dica.split(RegExp('[^A-Z]+')).contains(palavra_normalizada)) {

    return 'A dica não pode conter a própria palavra.';

  }

  return null;

}


// Não deixa cadastrar uma palavra que já existe
String? validar_repeticao(String texto, List<Palavra> palavras) {

  for (Palavra palavra in palavras) {

    if (normalizar_texto(palavra.texto) == normalizar_texto(texto)) {

      return 'Essa palavra já está cadastrada em ${palavra.categoria.nome}.';

    }

  }

  return null;

}


// Valida o nome do jogador
String? validar_nome(String? valor) {

  String nome = (valor ?? '').trim();

  if (nome.isEmpty) {

    return 'Digite o nome do jogador.';

  }

  if (nome.length > maximo_nome) {

    return 'Use no máximo $maximo_nome caracteres.';

  }

  return null;

}


// Valida o código da sala
String? validar_codigo(String? valor) {

  String codigo = (valor ?? '').trim().toUpperCase();

  if (!RegExp('^[A-Z]{$tamanho_codigo}\$').hasMatch(codigo)) {

    return 'O código tem $tamanho_codigo letras.';

  }

  return null;

}


// Não deixa os dois jogadores do duelo terem o mesmo nome
String? validar_nomes_diferentes(String primeiro_nome, String segundo_nome) {

  if (normalizar_texto(primeiro_nome) == normalizar_texto(segundo_nome)) {

    return 'Os jogadores precisam ter nomes diferentes.';

  }

  return null;

}
