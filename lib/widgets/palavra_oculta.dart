import 'package:flutter/material.dart';

import '../models/jogo_forca.dart';
import 'estilo_caderno.dart';


class PalavraOculta extends StatelessWidget {

  final JogoForca jogo;


  const PalavraOculta({super.key, required this.jogo});


  Color escolher_cor(String letra, EstiloCaderno estilo) {

    if (jogo.perdeu && !jogo.letra_revelada(letra)) {

      return estilo.vermelha;

    }

    return jogo.venceu ? estilo.acerto : estilo.tinta;

  }


  @override
  Widget build(BuildContext context) {

    EstiloCaderno estilo = EstiloCaderno.de(context);
    double escala = MediaQuery.textScalerOf(context).scale(1);
    List<String> letras = jogo.letras_exibidas;

    return Semantics(

      liveRegion: true,
      label: 'Palavra: ${letras.map((letra) => letra == '_' ? 'oculta' : letra).join(', ')}',

      child: ExcludeSemantics(

        child: Wrap(

          alignment: WrapAlignment.center,
          spacing: 6,
          runSpacing: 10,

          children: [

            for (String letra in letras) construir_casa(letra, escala, estilo),

          ],

        ),

      ),

    );

  }


  Widget construir_casa(String letra, double escala, EstiloCaderno estilo) {

    bool espaco = letra == ' ';

    return Container(

      width: (espaco ? 14 : 30) * escala,
      height: 44 * escala,
      alignment: Alignment.center,

      decoration: BoxDecoration(

        border: espaco ? null : Border(bottom: BorderSide(color: estilo.tinta, width: 3 + estilo.espessura_extra)),

      ),

      child: Text(

        letra == '_' ? '' : letra,

        style: TextStyle(

          fontSize: 28,
          height: 1,
          letterSpacing: 0,
          fontWeight: FontWeight.w700,
          color: escolher_cor(letra, estilo),

        ),

      ),

    );

  }

}
