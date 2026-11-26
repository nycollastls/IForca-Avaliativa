import 'package:flutter/material.dart';

import '../models/sala_desafio.dart';
import 'desenho_forca.dart';
import 'estilo_caderno.dart';


// Limite de erros da partida, igual ao do jogo
const int erros_permitidos = 6;


// Acompanhamento de quem está adivinhando, só para olhar
class PainelEspectador extends StatelessWidget {

  final JogadorSala jogador;


  const PainelEspectador({super.key, required this.jogador});


  // Situação do jogador nesta rodada
  String descrever() {

    if (jogador.terminou) {

      return jogador.venceu ? 'Acertou a palavra' : 'Não acertou';

    }

    return jogador.ausente ? 'Sem conexão' : 'Adivinhando agora';

  }


  // Monta o cartão; nada aqui responde a toque ou teclado
  @override
  Widget build(BuildContext context) {

    EstiloCaderno estilo = EstiloCaderno.de(context);
    ProgressoJogador? progresso = jogador.progresso;

    return ExcludeFocus(

      child: IgnorePointer(

        child: Container(

          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),

          decoration: BoxDecoration(

            color: Colors.white,
            border: Border.all(color: estilo.tinta, width: 1.5 + estilo.espessura_extra / 2),

          ),

          child: Column(

            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              Text(jogador.nome, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),

              Text(descrever(), style: TextStyle(color: jogador.terminou && !jogador.venceu ? estilo.vermelha : estilo.tinta)),

              const SizedBox(height: 8),

              if (progresso == null)

                const Text('O andamento deste jogador ainda não chegou.')

              else

                construir_andamento(progresso, estilo),

            ],

          ),

        ),

      ),

    );

  }


  // Forca pequena ao lado da palavra e das letras erradas
  Widget construir_andamento(ProgressoJogador progresso, EstiloCaderno estilo) {

    return Row(

      crossAxisAlignment: CrossAxisAlignment.start,

      children: [

        SizedBox(

          width: 110,
          height: 110,

          child: FittedBox(

            child: DesenhoForca(quantidade_erros: progresso.quantidade_erros, maximo_erros: erros_permitidos),

          ),

        ),

        const SizedBox(width: 12),

        Expanded(

          child: Column(

            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              construir_mascara(progresso.mascara, estilo),

              const SizedBox(height: 10),

              Text('Erros: ${progresso.quantidade_erros} de $erros_permitidos'),

              if (progresso.erradas.isNotEmpty)

                Text('Letras erradas: ${progresso.erradas.join(', ')}', style: TextStyle(color: estilo.vermelha)),

              if (progresso.dica_usada)

                Padding(

                  padding: const EdgeInsets.only(top: 4),

                  child: Container(

                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    color: estilo.marca_texto,
                    child: const Text('Usou a dica'),

                  ),

                ),

            ],

          ),

        ),

      ],

    );

  }


  // Palavra com traços no que o jogador ainda não descobriu
  Widget construir_mascara(List<String> mascara, EstiloCaderno estilo) {

    return Semantics(

      label: 'Palavra: ${mascara.map((letra) => letra == '_' ? 'oculta' : letra).join(', ')}',

      child: ExcludeSemantics(

        child: Wrap(

          spacing: 4,
          runSpacing: 6,

          children: [

            for (String letra in mascara)

              Container(

                width: letra == ' ' ? 8 : 20,
                height: 28,
                alignment: Alignment.center,

                decoration: BoxDecoration(

                  border: letra == ' ' ? null : Border(bottom: BorderSide(color: estilo.tinta, width: 2 + estilo.espessura_extra)),

                ),

                child: Text(

                  letra == '_' ? '' : letra,
                  style: const TextStyle(fontSize: 18, height: 1, fontWeight: FontWeight.w700),

                ),

              ),

          ],

        ),

      ),

    );

  }

}
