import 'package:flutter/material.dart';

import '../models/categoria.dart';
import '../models/nivel.dart';
import '../models/placar.dart';
import '../services/repositorio_placar.dart';
import '../widgets/tema_caderno.dart';


class TelaPlacar extends StatefulWidget {

  final RepositorioPlacar placares;


  const TelaPlacar({super.key, required this.placares});


  @override
  State<TelaPlacar> createState() => _TelaPlacarState();

}


class _TelaPlacarState extends State<TelaPlacar> {

  Future<void> zerar_placar() async {

    bool confirmou = await confirmar_acao(

      context,
      'Zerar o placar?',
      'Os pontos, as vitórias e as sequências serão apagados.',
      'Zerar placar',

    );

    if (!confirmou) {

      return;

    }

    try {

      await widget.placares.zerar_placar();

    } on Object {

      if (mounted) {

        mostrar_aviso(context, 'Não foi possível salvar o placar zerado.');

      }

    }

    if (mounted) {

      setState(() {});

    }

  }


  @override
  Widget build(BuildContext context) {

    Placar placar = widget.placares.placar;

    return PaginaCaderno(

      titulo: 'Placar',

      conteudo: [

        construir_linha('Pontos', placar.pontos),
        construir_linha('Vitórias', placar.vitorias),
        construir_linha('Derrotas', placar.derrotas),
        construir_linha('Sequência atual de acertos', placar.sequencia_atual),
        construir_linha('Melhor sequência de acertos', placar.melhor_sequencia),

        const Subtitulo('Vitórias por categoria e nível'),

        construir_tabela(placar),

        const SizedBox(height: 28),

        Align(

          alignment: Alignment.centerLeft,

          child: OutlinedButton(

            onPressed: zerar_placar,
            child: const Text('Zerar placar'),

          ),

        ),

      ],

    );

  }


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


  Widget construir_tabela(Placar placar) {

    return Table(

      border: TableBorder.all(color: cor_tinta),

      children: [

        TableRow(

          decoration: const BoxDecoration(color: cor_marca_texto),

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


  Widget construir_celula(String texto) {

    return Padding(

      padding: const EdgeInsets.all(10),
      child: Text(texto, textAlign: TextAlign.center),

    );

  }

}
