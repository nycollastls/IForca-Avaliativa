import 'package:flutter/material.dart';

import '../models/jogo_forca.dart';
import 'tema_caderno.dart';


class PalavraOculta extends StatelessWidget {

  final JogoForca jogo;


  const PalavraOculta({super.key, required this.jogo});


  Color escolher_cor(String letra) {

    if (jogo.perdeu && !jogo.letra_revelada(letra)) {

      return cor_caneta_vermelha;

    }

    return jogo.venceu ? cor_acerto : cor_tinta;

  }


  @override
  Widget build(BuildContext context) {

    List<String> letras = jogo.letras_exibidas;

    return Semantics(

      label: 'Palavra: ${letras.map((letra) => letra == '_' ? 'oculta' : letra).join(', ')}',

      child: ExcludeSemantics(

        child: Wrap(

          alignment: WrapAlignment.center,
          spacing: 6,
          runSpacing: 10,

          children: [

            for (String letra in letras) construir_casa(letra),

          ],

        ),

      ),

    );

  }


  Widget construir_casa(String letra) {

    bool espaco = letra == ' ';

    return Container(

      width: espaco ? 14 : 30,
      height: 44,
      alignment: Alignment.center,

      decoration: BoxDecoration(

        border: espaco ? null : const Border(bottom: BorderSide(color: cor_tinta, width: 3)),

      ),

      child: Text(

        letra == '_' ? '' : letra,
        style: TextStyle(fontSize: 28, height: 1, fontWeight: FontWeight.w700, color: escolher_cor(letra)),

      ),

    );

  }

}
