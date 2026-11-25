import 'package:flutter/material.dart';

import '../models/jogo_forca.dart';
import 'estilo_caderno.dart';


const List<List<String>> linhas_teclado = [

  ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'],
  ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L'],
  ['Z', 'X', 'C', 'V', 'B', 'N', 'M'],

];

const List<List<String>> linhas_alfabeticas = [

  ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J'],
  ['K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S'],
  ['T', 'U', 'V', 'W', 'X', 'Y', 'Z'],

];


class TecladoVirtual extends StatelessWidget {

  final JogoForca jogo;
  final void Function(String letra) ao_escolher;


  const TecladoVirtual({super.key, required this.jogo, required this.ao_escolher});


  @override
  Widget build(BuildContext context) {

    EstiloCaderno estilo = EstiloCaderno.de(context);
    List<List<String>> linhas = estilo.teclado_alfabetico ? linhas_alfabeticas : linhas_teclado;
    double altura_tecla = MediaQuery.textScalerOf(context).scale(46);

    return LayoutBuilder(

      builder: (context, limites) {

        double largura_tecla = (limites.maxWidth / linhas.first.length - 6).clamp(20.0, 48.0);

        return Column(

          children: [

            for (List<String> linha in linhas)

              Row(

                mainAxisAlignment: MainAxisAlignment.center,

                children: [

                  for (String letra in linha) construir_tecla(letra, Size(largura_tecla, altura_tecla), estilo),

                ],

              ),

          ],

        );

      },

    );

  }


  Widget construir_tecla(String letra, Size tamanho, EstiloCaderno estilo) {

    bool acertou = jogo.letras_certas.contains(letra);
    bool errou = jogo.letras_erradas.contains(letra);
    bool usada = acertou || errou;

    Color cor_texto = estilo.tinta;
    String rotulo = letra;

    if (acertou) {

      cor_texto = estilo.acerto;
      rotulo = '$letra, certa';

    } else if (errou) {

      cor_texto = estilo.vermelha;
      rotulo = '$letra, errada';

    }

    return Padding(

      padding: const EdgeInsets.all(3),

      child: SizedBox(

        width: tamanho.width,
        height: tamanho.height,

        child: OutlinedButton(

          onPressed: usada ? null : () => ao_escolher(letra),

          style: OutlinedButton.styleFrom(

            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            backgroundColor: usada ? Colors.transparent : Colors.white,
            disabledForegroundColor: cor_texto,
            side: BorderSide(color: cor_texto, width: 1.5 + estilo.espessura_extra / 2),

          ),

          child: FittedBox(

            fit: BoxFit.scaleDown,

            child: Column(

              mainAxisSize: MainAxisSize.min,

              children: [

                Text(

                  letra,
                  semanticsLabel: rotulo,

                  style: TextStyle(

                    fontSize: 17,
                    height: 1.1,
                    letterSpacing: 0,
                    fontWeight: FontWeight.w700,
                    color: cor_texto,
                    decoration: errou ? TextDecoration.lineThrough : null,
                    decorationColor: estilo.vermelha,
                    decorationThickness: 2,

                  ),

                ),

                if (usada && estilo.marcas_teclado)

                  Icon(acertou ? Icons.check : Icons.close, size: 15, color: cor_texto),

              ],

            ),

          ),

        ),

      ),

    );

  }

}
