import 'package:flutter/material.dart';

import '../models/palavra.dart';
import '../models/resultado.dart';
import '../widgets/painel_jogo.dart';
import '../widgets/tema_caderno.dart';


// Tela de uma partida, usada no jogo solo e no duelo
class TelaJogo extends StatelessWidget {

  final String titulo;
  final Palavra palavra;
  final Future<void> Function(Resultado resultado) ao_terminar;
  final Palavra? Function(Palavra anterior)? sortear_proxima;


  const TelaJogo({

    super.key,
    required this.titulo,
    required this.palavra,
    required this.ao_terminar,
    this.sortear_proxima,

  });


  // Monta a tela com o painel do jogo
  @override
  Widget build(BuildContext context) {

    return PaginaCaderno(

      titulo: titulo,

      conteudo: [

        PainelJogo(

          palavra: palavra,
          ao_terminar: ao_terminar,
          sortear_proxima: sortear_proxima,
          ao_voltar: () => Navigator.of(context).pop(),

        ),

      ],

    );

  }

}
