import 'package:flutter_test/flutter_test.dart';

import 'package:forca/models/categoria.dart';
import 'package:forca/models/jogo_forca.dart';
import 'package:forca/models/nivel.dart';
import 'package:forca/models/palavra.dart';
import 'package:forca/models/placar.dart';
import 'package:forca/models/resultado.dart';
import 'package:forca/services/regras_pontuacao.dart';


JogoForca criar_jogo(String texto, {Nivel nivel = Nivel.facil}) {

  return JogoForca(

    palavra: Palavra(texto: texto, dica: 'Dica de teste', categoria: Categoria.dart, nivel: nivel),

  );

}


void tentar_todas(JogoForca jogo, String letras) {

  for (String letra in letras.split('')) {

    jogo.tentar_letra(letra);

  }

}


void main() {

  test('esconde as letras ainda não descobertas', () {

    JogoForca jogo = criar_jogo('mixin');

    jogo.tentar_letra('i');

    expect(jogo.palavra_exibida, '_ I _ I _');

  });


  test('vence ao descobrir todas as letras', () {

    JogoForca jogo = criar_jogo('async');

    tentar_todas(jogo, 'async');

    expect(jogo.venceu, isTrue);
    expect(jogo.encerrado, isTrue);

  });


  test('perde ao atingir o máximo de erros', () {

    JogoForca jogo = criar_jogo('struct');

    tentar_todas(jogo, 'abdefg');

    expect(jogo.perdeu, isTrue);
    expect(jogo.palavra_exibida, 'S T R U C T');

  });


  test('ignora letra repetida', () {

    JogoForca jogo = criar_jogo('widget');

    tentar_todas(jogo, 'zz');

    expect(jogo.quantidade_erros, 1);

  });


  test('guarda acertos e erros no conjunto de letras tentadas', () {

    JogoForca jogo = criar_jogo('widget');

    tentar_todas(jogo, 'wz');

    expect(jogo.letras_tentadas, {'W', 'Z'});

  });


  test('ignora caracteres que não são letras', () {

    JogoForca jogo = criar_jogo('widget');

    tentar_todas(jogo, '1-_ ');

    expect(jogo.letras_tentadas, isEmpty);

  });


  test('letra sem acento revela letra acentuada', () {

    JogoForca jogo = criar_jogo('função');

    tentar_todas(jogo, 'funcao');

    expect(jogo.venceu, isTrue);
    expect(jogo.palavra_exibida, 'F U N Ç Ã O');

  });


  test('espaço e hífen não precisam ser adivinhados', () {

    JogoForca jogo = criar_jogo('if else-if');

    tentar_todas(jogo, 'ifels');

    expect(jogo.venceu, isTrue);

  });


  test('não aceita letras depois do fim', () {

    JogoForca jogo = criar_jogo('struct');

    tentar_todas(jogo, 'abdefgh');

    expect(jogo.quantidade_erros, 6);

  });


  test('erros e dica diminuem os pontos da vitória', () {

    JogoForca jogo = criar_jogo('async', nivel: Nivel.medio);

    jogo.usar_dica();
    tentar_todas(jogo, 'zxasync');

    expect(gerar_resultado(jogo).pontos, 24);

  });


  test('vitória nunca vale menos que o mínimo', () {

    JogoForca jogo = criar_jogo('async');

    jogo.usar_dica();
    tentar_todas(jogo, 'zxwvtasync');

    expect(gerar_resultado(jogo).pontos, pontos_minimos);

  });


  test('derrota com dica desconta pontos sem ficar negativo', () {

    JogoForca jogo = criar_jogo('struct');
    Placar placar = Placar(pontos: 4, sequencia_atual: 3);

    jogo.usar_dica();
    tentar_todas(jogo, 'abdefg');

    Resultado resultado = gerar_resultado(jogo);

    aplicar_resultado(placar, resultado);

    expect(resultado.pontos, -custo_dica);
    expect(placar.pontos, 0);
    expect(placar.derrotas, 1);
    expect(placar.sequencia_atual, 0);

  });


  test('vitória atualiza sequência e matriz de vitórias', () {

    JogoForca jogo = criar_jogo('async', nivel: Nivel.dificil);
    Placar placar = Placar();

    tentar_todas(jogo, 'async');
    aplicar_resultado(placar, gerar_resultado(jogo));

    expect(placar.pontos, 50);
    expect(placar.sequencia_atual, 1);
    expect(placar.melhor_sequencia, 1);
    expect(placar.matriz_vitorias[Categoria.dart.index][Nivel.dificil.index], 1);

  });

}
