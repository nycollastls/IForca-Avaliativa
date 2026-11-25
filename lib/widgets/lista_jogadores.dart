import 'package:flutter/material.dart';

import '../models/sala_desafio.dart';
import 'estilo_caderno.dart';


// Lista de jogadores da sala com os pontos
class ListaJogadores extends StatelessWidget {

  final SalaDesafio sala;


  const ListaJogadores({super.key, required this.sala});


  // Texto de situação de cada jogador
  String descrever(JogadorSala jogador) {

    if (jogador.ausente) {

      return 'Sem conexão';

    }

    if (sala.fase == FaseSala.espera) {

      return jogador.numero == sala.numero_anfitriao ? 'Começa o desafio' : 'Na sala';

    }

    if (jogador.numero == sala.numero_desafiante) {

      return sala.fase == FaseSala.escrevendo ? 'Escrevendo a palavra' : 'Escreveu a palavra';

    }

    if (jogador.terminou) {

      return descrever_fim(jogador);

    }

    if (jogador.participa) {

      return sala.fase == FaseSala.jogando ? 'Adivinhando' : 'Não terminou';

    }

    return 'Esperando';

  }


  // Como o jogador terminou a rodada
  String descrever_fim(JogadorSala jogador) {

    if (jogador.venceu) {

      return 'Acertou e ganhou ${jogador.pontos_rodada} pontos';

    }

    if (jogador.pontos_rodada < 0) {

      return 'Não acertou e a dica custou ${-jogador.pontos_rodada} pontos';

    }

    return 'Não acertou';

  }


  // Ordena os jogadores pelos pontos
  @override
  Widget build(BuildContext context) {

    List<JogadorSala> ordenados = [...sala.jogadores];

    ordenados.sort((primeiro, segundo) => segundo.pontos.compareTo(primeiro.pontos));

    return Column(

      children: [

        for (JogadorSala jogador in ordenados) construir_jogador(context, jogador),

      ],

    );

  }


  // Linha de um jogador
  Widget construir_jogador(BuildContext context, JogadorSala jogador) {

    bool sou_eu = jogador.numero == sala.meu_numero;

    return Container(

      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),

      decoration: BoxDecoration(

        color: sou_eu ? EstiloCaderno.de(context).marca_texto : Colors.white,
        border: Border(bottom: BorderSide(color: EstiloCaderno.de(context).tinta)),

      ),

      child: Row(

        children: [

          Expanded(

            child: Column(

              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                Text(

                  sou_eu ? '${jogador.nome} (você)' : jogador.nome,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),

                ),

                Text(descrever(jogador)),

              ],

            ),

          ),

          Text('${jogador.pontos}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),

        ],

      ),

    );

  }

}
