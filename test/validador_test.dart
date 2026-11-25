import 'package:flutter_test/flutter_test.dart';

import 'package:forca/models/categoria.dart';
import 'package:forca/models/nivel.dart';
import 'package:forca/models/palavra.dart';
import 'package:forca/services/validador.dart';


void main() {

  test('aceita palavras com acento, espaço e hífen', () {

    for (String texto in ['laço', 'if else', 'palavra-chave', '  função  ']) {

      expect(validar_texto(texto), isNull, reason: texto);

    }

  });


  test('recusa palavras inválidas', () {

    for (String? texto in [null, '', '   ', 'a', 'a-', 'C99', 'soma()', '-laço', 'a' * 19]) {

      expect(validar_texto(texto), isNotNull, reason: '$texto');

    }

  });


  test('recusa dica curta ou que contém a palavra', () {

    expect(validar_dica('abc', 'laço'), isNotNull);
    expect(validar_dica('Um LACO que repete', 'laço'), isNotNull);
    expect(validar_dica('Repete instruções', 'laço'), isNull);

  });


  test('recusa palavra repetida sem diferenciar acentos', () {

    List<Palavra> palavras = [

      const Palavra(texto: 'laço', dica: 'Repete instruções', categoria: Categoria.logica, nivel: Nivel.facil),

    ];

    expect(validar_repeticao('LACO', palavras), isNotNull);
    expect(validar_repeticao('vetor', palavras), isNull);

  });


  test('valida nomes do duelo', () {

    expect(validar_nome('  '), isNotNull);
    expect(validar_nome('a' * 16), isNotNull);
    expect(validar_nome('Ana'), isNull);
    expect(validar_nomes_diferentes('Ana', ' ana '), isNotNull);

  });

}
