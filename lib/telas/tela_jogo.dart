import 'dart:math';

import 'package:flutter/material.dart';

import '../modelos/jogo_forca.dart';
import '../modelos/linguagem.dart';
import '../servicos/carregador_palavras.dart';


class TelaJogo extends StatefulWidget {

  final Linguagem linguagem;


  const TelaJogo({super.key, required this.linguagem});


  @override
  State<TelaJogo> createState() => _TelaJogoState();

}


class _TelaJogoState extends State<TelaJogo> {

  List<String> palavras = [];
  JogoForca? jogo;

  final Random sorteador = Random();
  final List<String> alfabeto = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('');


  @override
  void initState() {

    super.initState();
    iniciar();

  }


  Future<void> iniciar() async {

    palavras = await carregar_palavras(widget.linguagem);
    novo_jogo();

  }


  void novo_jogo() {

    String palavra_sorteada = palavras[sorteador.nextInt(palavras.length)];

    setState(() {

      jogo = JogoForca(palavra: palavra_sorteada);

    });

  }


  void escolher_letra(String letra) {

    setState(() {

      jogo!.tentar_letra(letra);

    });

  }


  String mensagem_final(JogoForca jogo_atual) {

    if (jogo_atual.venceu) {

      return 'Você venceu!';

    }

    return 'Você perdeu! A palavra era ${jogo_atual.palavra_secreta}';

  }


  Widget construir_teclado(JogoForca jogo_atual) {

    return Wrap(

      alignment: WrapAlignment.center,

      spacing: 6,

      runSpacing: 6,

      children: [

        for (String letra in alfabeto)

          SizedBox(

            width: 44,

            height: 44,

            child: ElevatedButton(

              style: ElevatedButton.styleFrom(padding: EdgeInsets.zero),

              onPressed: jogo_atual.encerrado || jogo_atual.letra_ja_usada(letra) ? null : () => escolher_letra(letra),

              child: Text(letra),

            ),

          ),

      ],

    );

  }


  Widget construir_fim_de_jogo(JogoForca jogo_atual) {

    return Column(

      children: [

        Text(mensagem_final(jogo_atual), style: const TextStyle(fontSize: 20), textAlign: TextAlign.center),

        const SizedBox(height: 16),

        Row(

          mainAxisAlignment: MainAxisAlignment.center,

          children: [

            ElevatedButton(

              onPressed: novo_jogo,

              child: const Text('Jogar novamente'),

            ),

            const SizedBox(width: 12),

            OutlinedButton(

              onPressed: () => Navigator.of(context).pop(),

              child: const Text('Voltar'),

            ),

          ],

        ),

      ],

    );

  }


  @override
  Widget build(BuildContext context) {

    JogoForca? jogo_atual = jogo;

    if (jogo_atual == null) {

      return const Scaffold(

        body: Center(

          child: CircularProgressIndicator(),

        ),

      );

    }

    return Scaffold(

      appBar: AppBar(

        title: Text('Forca - ${widget.linguagem.nome}'),

      ),

      body: Padding(

        padding: const EdgeInsets.all(16),

        child: Column(

          children: [

            Text('Erros: ${jogo_atual.quantidade_erros} / ${jogo_atual.maximo_erros}', style: const TextStyle(fontSize: 18)),

            const SizedBox(height: 8),

            Text('Letras erradas: ${jogo_atual.letras_erradas.join(' ')}'),

            const Spacer(),

            Text(jogo_atual.palavra_exibida, style: const TextStyle(fontSize: 36, letterSpacing: 2)),

            const Spacer(),

            if (jogo_atual.encerrado) construir_fim_de_jogo(jogo_atual) else construir_teclado(jogo_atual),

            const SizedBox(height: 16),

          ],

        ),

      ),

    );

  }

}
