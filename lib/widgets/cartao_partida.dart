import 'package:flutter/material.dart';

import '../models/partida_leaderboard.dart';
import 'estilo_caderno.dart';


// Cartão de uma partida no leaderboard
class CartaoPartida extends StatelessWidget {

  final int posicao;
  final PartidaLeaderboard partida;


  const CartaoPartida({super.key, required this.posicao, required this.partida});


  // Monta o cartão com o cabeçalho e os jogadores
  @override
  Widget build(BuildContext context) {

    EstiloCaderno estilo = EstiloCaderno.de(context);

    return Container(

      margin: const EdgeInsets.only(bottom: 14),

      decoration: BoxDecoration(

        color: Colors.white,
        border: Border.all(color: estilo.tinta, width: 1 + estilo.espessura_extra / 2),

      ),

      child: Column(

        crossAxisAlignment: CrossAxisAlignment.stretch,

        children: [

          construir_cabecalho(),

          for (JogadorLeaderboard jogador in partida.jogadores) construir_jogador(jogador, estilo),

        ],

      ),

    );

  }


  // Posição, quem venceu, rodadas e data
  Widget construir_cabecalho() {

    String rodadas = partida.rodadas == 1 ? '1 rodada' : '${partida.rodadas} rodadas';
    String situacao = partida.em_andamento ? 'em andamento' : 'encerrada';

    return Padding(

      padding: const EdgeInsets.all(14),

      child: Row(

        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          SizedBox(

            width: 52,
            child: Text('$posicaoº', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),

          ),

          Expanded(

            child: Column(

              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                Text(partida.titulo, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),

                const SizedBox(height: 2),

                Text('$rodadas, $situacao. Começou em ${partida.data_formatada}.'),

              ],

            ),

          ),

        ],

      ),

    );

  }


  // Linha de um jogador com os pontos
  Widget construir_jogador(JogadorLeaderboard jogador, EstiloCaderno estilo) {

    bool lidera = jogador.pontos == partida.jogadores.first.pontos;

    return Container(

      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),

      decoration: BoxDecoration(

        color: jogador.sou_eu ? estilo.marca_texto : null,
        border: Border(top: BorderSide(color: estilo.linha)),

      ),

      child: Row(

        children: [

          Expanded(

            child: Text(

              jogador.sou_eu ? '${jogador.nome} (você)' : jogador.nome,
              style: TextStyle(fontWeight: lidera ? FontWeight.w700 : FontWeight.w400),

            ),

          ),

          Text(

            jogador.pontos == 1 ? '1 ponto' : '${jogador.pontos} pontos',
            style: const TextStyle(fontWeight: FontWeight.w700),

          ),

        ],

      ),

    );

  }

}
