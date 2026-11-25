import 'package:flutter/material.dart';

import '../services/dados_aplicativo.dart';
import '../widgets/dialogo_nome.dart';
import '../widgets/estilo_caderno.dart';
import '../widgets/tema_caderno.dart';
import 'tela_cadastro.dart';
import 'tela_configuracoes.dart';
import 'tela_desafio.dart';
import 'tela_estatisticas.dart';
import 'tela_leaderboard.dart';
import 'tela_um_aparelho.dart';


class TelaInicio extends StatelessWidget {

  final DadosAplicativo dados;


  const TelaInicio({super.key, required this.dados});


  void abrir_tela(BuildContext context, Widget tela) {

    Navigator.of(context).push(MaterialPageRoute<void>(builder: (context) => tela));

  }


  Future<void> abrir_desafio(BuildContext context) async {

    bool tem_nome = await garantir_nome(context, dados);

    if (tem_nome && context.mounted) {

      abrir_tela(context, TelaDesafio(dados: dados));

    }

  }


  @override
  Widget build(BuildContext context) {

    return PaginaCaderno(

      cabecalho: construir_usuario(),

      acoes: [

        IconButton(

          onPressed: () => abrir_tela(context, TelaConfiguracoes(dados: dados)),
          tooltip: 'Configurações',
          icon: const Icon(Icons.settings_outlined),

        ),

        const SizedBox(width: 8),

      ],

      conteudo: [

        construir_titulo(),

        const Subtitulo('Modos de jogo'),

        construir_modo(

          icone: Icons.smartphone,
          nome: 'Um aparelho',
          descricao: 'Jogue passando o aparelho para a outra pessoa.',
          ao_tocar: () => abrir_tela(context, TelaUmAparelho(dados: dados)),

        ),

        construir_modo(

          icone: Icons.devices,
          nome: 'Desafio multiplayer',
          descricao: 'Cada pessoa joga no próprio aparelho.',
          ao_tocar: () => abrir_desafio(context),

        ),

        construir_leaderboard(context),

        const SizedBox(height: 20),

        construir_opcoes(context),

      ],

    );

  }


  Widget construir_usuario() {

    return ListenableBuilder(

      listenable: dados.perfis,

      builder: (context, _) {

        String nome = dados.perfis.perfil.nome;

        return TextButton.icon(

          onPressed: () => pedir_nome(context, dados),
          style: TextButton.styleFrom(foregroundColor: Colors.white),
          icon: const Icon(Icons.account_circle_outlined, size: 26),

          label: Text(

            nome.isEmpty ? 'Escolher nome' : nome,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),

          ),

        );

      },

    );

  }


  Widget construir_titulo() {

    return Semantics(

      header: true,

      child: const Text(

        'Forca da Programação',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 30, height: 1.2, fontWeight: FontWeight.w800),

      ),

    );

  }


  Widget construir_modo({

    required IconData icone,
    required String nome,
    required String descricao,
    required VoidCallback ao_tocar,

  }) {

    return Padding(

      padding: const EdgeInsets.only(bottom: 10),

      child: FilledButton(

        onPressed: ao_tocar,

        style: FilledButton.styleFrom(

          minimumSize: const Size(48, 88),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),

        ),

        child: Row(

          children: [

            Icon(icone, size: 32),

            const SizedBox(width: 18),

            Expanded(

              child: Column(

                crossAxisAlignment: CrossAxisAlignment.start,

                children: [

                  Text(nome, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w700)),

                  const SizedBox(height: 2),

                  Text(descricao, style: const TextStyle(fontSize: 14)),

                ],

              ),

            ),

          ],

        ),

      ),

    );

  }


  Widget construir_leaderboard(BuildContext context) {

    return FilledButton.icon(

      onPressed: () => abrir_tela(context, TelaLeaderboard(dados: dados)),

      style: FilledButton.styleFrom(

        minimumSize: const Size(48, 60),
        backgroundColor: EstiloCaderno.de(context).marca_texto,
        foregroundColor: EstiloCaderno.de(context).tinta,

      ).copyWith(

        side: criar_borda_foco(EstiloCaderno.de(context).tinta, null),

      ),

      icon: const Icon(Icons.emoji_events_outlined, size: 26),
      label: const Text('Leaderboard', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),

    );

  }


  Widget construir_opcoes(BuildContext context) {

    return Wrap(

      alignment: WrapAlignment.center,
      spacing: 10,
      runSpacing: 10,

      children: [

        OutlinedButton.icon(

          onPressed: () => abrir_tela(context, TelaEstatisticas(dados: dados)),
          icon: const Icon(Icons.bar_chart),
          label: const Text('Estatísticas'),

        ),

        OutlinedButton.icon(

          onPressed: () => abrir_tela(context, TelaCadastro(palavras: dados.palavras)),
          icon: const Icon(Icons.edit_outlined),
          label: const Text('Cadastrar palavras'),

        ),

      ],

    );

  }

}
