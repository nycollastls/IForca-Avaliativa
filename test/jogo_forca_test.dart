import 'package:flutter_test/flutter_test.dart';

import 'package:forca/modelos/jogo_forca.dart';


void main() {

  test('esconde as letras ainda não descobertas', () {

    JogoForca jogo = JogoForca(palavra: 'mixin');

    jogo.tentar_letra('i');

    expect(jogo.palavra_exibida, '_ I _ I _');

  });


  test('vence ao descobrir todas as letras', () {

    JogoForca jogo = JogoForca(palavra: 'async');

    for (String letra in ['a', 's', 'y', 'n', 'c']) {

      jogo.tentar_letra(letra);

    }

    expect(jogo.venceu, isTrue);
    expect(jogo.encerrado, isTrue);

  });


  test('perde ao atingir o máximo de erros', () {

    JogoForca jogo = JogoForca(palavra: 'struct');

    for (String letra in ['a', 'b', 'd', 'e', 'f', 'g']) {

      jogo.tentar_letra(letra);

    }

    expect(jogo.perdeu, isTrue);
    expect(jogo.palavra_exibida, 'S T R U C T');

  });


  test('ignora letra repetida', () {

    JogoForca jogo = JogoForca(palavra: 'widget');

    jogo.tentar_letra('z');
    jogo.tentar_letra('z');

    expect(jogo.quantidade_erros, 1);

  });

}
