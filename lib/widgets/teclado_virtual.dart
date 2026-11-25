import 'package:flutter/material.dart';

import '../models/jogo_forca.dart';
import 'tema_caderno.dart';


const List<List<String>> linhas_teclado = [

  ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'],
  ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L'],
  ['Z', 'X', 'C', 'V', 'B', 'N', 'M'],

];


class TecladoVirtual extends StatelessWidget {

  final JogoForca jogo;
  final void Function(String letra) ao_escolher;


  const TecladoVirtual({super.key, required this.jogo, required this.ao_escolher});


  @override
  Widget build(BuildContext context) {

    return LayoutBuilder(

      builder: (context, limites) {

        double largura_tecla = (limites.maxWidth / linhas_teclado.first.length - 6).clamp(20.0, 48.0);

        return Column(

          children: [

            for (List<String> linha in linhas_teclado)

              Row(

                mainAxisAlignment: MainAxisAlignment.center,

                children: [

                  for (String letra in linha) construir_tecla(letra, largura_tecla),

                ],

              ),

          ],

        );

      },

    );

  }


  Widget construir_tecla(String letra, double largura) {

    bool acertou = jogo.letras_certas.contains(letra);
    bool errou = jogo.letras_erradas.contains(letra);
    bool usada = acertou || errou;

    Color cor_texto = cor_tinta;

    if (acertou) {

      cor_texto = cor_acerto;

    } else if (errou) {

      cor_texto = cor_caneta_vermelha;

    }

    return Padding(

      padding: const EdgeInsets.all(3),

      child: SizedBox(

        width: largura,
        height: 46,

        child: OutlinedButton(

          onPressed: usada ? null : () => ao_escolher(letra),

          style: OutlinedButton.styleFrom(

            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            backgroundColor: usada ? Colors.transparent : Colors.white,
            disabledForegroundColor: cor_texto,
            side: BorderSide(color: usada ? cor_texto : cor_tinta, width: 1.5),

          ),

          child: Text(

            letra,

            style: TextStyle(

              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: cor_texto,
              decoration: errou ? TextDecoration.lineThrough : null,
              decorationColor: cor_caneta_vermelha,
              decorationThickness: 2,

            ),

          ),

        ),

      ),

    );

  }

}
