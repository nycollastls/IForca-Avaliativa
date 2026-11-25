import 'package:flutter/material.dart';

import '../models/partida_leaderboard.dart';
import '../services/dados_aplicativo.dart';
import '../services/servico_online.dart';
import '../widgets/cartao_partida.dart';
import '../widgets/estilo_caderno.dart';
import '../widgets/tema_caderno.dart';


class TelaLeaderboard extends StatefulWidget {

  final DadosAplicativo dados;


  const TelaLeaderboard({super.key, required this.dados});


  @override
  State<TelaLeaderboard> createState() => _TelaLeaderboardState();

}


class _TelaLeaderboardState extends State<TelaLeaderboard> {

  List<PartidaLeaderboard> partidas = [];
  String? mensagem_erro;
  bool carregando = true;
  bool por_pontos = true;


  @override
  void initState() {

    super.initState();
    carregar();

  }


  Future<void> carregar() async {

    setState(() {

      carregando = true;
      mensagem_erro = null;

    });

    try {

      partidas = await widget.dados.online.listar_partidas(widget.dados.perfis.perfil, por_pontos);

    } on ErroServidor catch (erro) {

      mensagem_erro = erro.mensagem;

    } on Object {

      mensagem_erro = 'Não foi possível ler o leaderboard.';

    }

    if (mounted) {

      setState(() {

        carregando = false;

      });

    }

  }


  Future<void> mudar_ordem(bool ordem_por_pontos) async {

    por_pontos = ordem_por_pontos;

    await carregar();

  }


  @override
  Widget build(BuildContext context) {

    return PaginaCaderno(

      titulo: 'Leaderboard',

      acoes: [

        IconButton(

          onPressed: carregando ? null : carregar,
          tooltip: 'Atualizar',
          icon: const Icon(Icons.refresh),

        ),

        const SizedBox(width: 8),

      ],

      conteudo: construir_conteudo(),

    );

  }


  List<Widget> construir_conteudo() {

    if (carregando) {

      return const [AvisoConexao()];

    }

    String? erro = mensagem_erro;

    if (erro != null) {

      return [

        Text(erro),

        const SizedBox(height: 16),

        Align(

          alignment: Alignment.centerLeft,
          child: FilledButton(onPressed: carregar, child: const Text('Tentar de novo')),

        ),

      ];

    }

    return [

      const Text('Partidas do desafio multiplayer que foram abertas para todos.'),

      const SizedBox(height: 14),

      Wrap(

        spacing: 8,
        runSpacing: 8,

        children: [

          construir_ordem('Maiores pontuações', true),
          construir_ordem('Mais recentes', false),

        ],

      ),

      const SizedBox(height: 16),

      if (partidas.isEmpty)

        const Text('Nenhuma partida por aqui. Crie uma sala no desafio multiplayer e escolha mostrar no leaderboard geral.')

      else

        for (int indice = 0; indice < partidas.length; indice++)

          CartaoPartida(posicao: indice + 1, partida: partidas[indice]),

    ];

  }


  Widget construir_ordem(String rotulo, bool ordem_por_pontos) {

    return ChoiceChip(

      label: Text(rotulo),
      selected: por_pontos == ordem_por_pontos,
      selectedColor: EstiloCaderno.de(context).marca_texto,
      backgroundColor: Colors.white,
      onSelected: (_) => mudar_ordem(ordem_por_pontos),

    );

  }

}
