import 'package:flutter/material.dart';

import '../models/categoria.dart';
import '../models/nivel.dart';
import '../models/placar.dart';
import '../services/dados_aplicativo.dart';
import '../widgets/estilo_caderno.dart';
import '../widgets/tema_caderno.dart';


// Tela com as estatísticas do jogador
class TelaEstatisticas extends StatefulWidget {

  final DadosAplicativo dados;


  const TelaEstatisticas({super.key, required this.dados});


  @override
  State<TelaEstatisticas> createState() => _TelaEstatisticasState();

}


class _TelaEstatisticasState extends State<TelaEstatisticas> {

  // Pede confirmação e zera o placar
  Future<void> zerar_placar() async {

    bool confirmou = await confirmar_acao(

      context,
      'Zerar suas estatísticas?',
      'Os pontos, as vitórias e as sequências serão apagados.',
      'Zerar estatísticas',

    );

    if (!confirmou) {

      return;

    }

    try {

      await widget.dados.placares.zerar_placar();

    } on Object {

      if (mounted) {

        mostrar_aviso(context, 'Não foi possível salvar as estatísticas zeradas.');

      }

    }

    if (mounted) {

      setState(() {});

    }

  }


  // Monta a tela de estatísticas
  @override
  Widget build(BuildContext context) {

    Placar placar = widget.dados.placares.placar;

    return PaginaCaderno(

      titulo: 'Estatísticas',

      conteudo: [

        const Subtitulo('Seu placar'),

        construir_linha('Pontos', placar.pontos),
        construir_linha('Vitórias', placar.vitorias),
        construir_linha('Derrotas', placar.derrotas),
        construir_linha('Sequência atual de acertos', placar.sequencia_atual),
        construir_linha('Melhor sequência de acertos', placar.melhor_sequencia),

        const Subtitulo('Suas vitórias por categoria e nível'),

        construir_tabela(placar),

        const SizedBox(height: 28),

        Align(

          alignment: Alignment.centerLeft,

          child: OutlinedButton(

            onPressed: zerar_placar,
            child: const Text('Zerar estatísticas'),

          ),

        ),

      ],

    );

  }


  // Linha com um número do placar
  Widget construir_linha(String rotulo, int valor) {

    return Padding(

      padding: const EdgeInsets.symmetric(vertical: 6),

      child: Row(

        children: [

          Expanded(child: Text(rotulo, style: const TextStyle(fontSize: 17))),

          Text('$valor', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),

        ],

      ),

    );

  }


  // Tabela de vitórias por categoria e nível, lida da matriz
  Widget construir_tabela(Placar placar) {

    return Table(

      border: TableBorder.all(color: EstiloCaderno.de(context).tinta),

      children: [

        TableRow(

          decoration: BoxDecoration(color: EstiloCaderno.de(context).marca_texto),

          children: [

            construir_celula('Categoria'),

            for (Nivel nivel in Nivel.values) construir_celula(nivel.nome),

          ],

        ),

        for (Categoria categoria in Categoria.values)

          TableRow(

            decoration: const BoxDecoration(color: Colors.white),

            children: [

              construir_celula(categoria.nome),

              for (int vitorias in placar.matriz_vitorias[categoria.index]) construir_celula('$vitorias'),

            ],

          ),

      ],

    );

  }


  // Célula da tabela
  Widget construir_celula(String texto) {

    return Padding(

      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
      child: FittedBox(fit: BoxFit.scaleDown, child: Text(texto)),

    );

  }

}
