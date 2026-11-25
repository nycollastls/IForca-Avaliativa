import 'package:flutter/material.dart';

import '../models/perfil.dart';
import '../models/tamanho_texto.dart';
import '../services/dados_aplicativo.dart';
import '../widgets/cartao_opcao.dart';
import '../widgets/dialogo_nome.dart';
import '../widgets/estilo_caderno.dart';
import '../widgets/tema_caderno.dart';


class TelaConfiguracoes extends StatelessWidget {

  final DadosAplicativo dados;


  const TelaConfiguracoes({super.key, required this.dados});


  Future<void> alterar(BuildContext context, void Function(Perfil perfil) mudanca) async {

    try {

      await dados.perfis.alterar(mudanca);

    } on Object {

      if (context.mounted) {

        mostrar_aviso(context, 'Não foi possível salvar neste aparelho.');

      }

    }

  }


  Future<void> mudar_leaderboard(BuildContext context, bool aparecer) async {

    await alterar(context, (perfil) => perfil.aparecer_leaderboard = aparecer);

    bool mudou = await dados.mudar_nome_leaderboard();

    if (!mudou && context.mounted) {

      mostrar_aviso(context, 'Sem conexão com o servidor. A mudança vale só para as próximas partidas.');

    }

  }


  @override
  Widget build(BuildContext context) {

    return ListenableBuilder(

      listenable: dados.perfis,

      builder: (context, _) => PaginaCaderno(

        titulo: 'Configurações',

        conteudo: [

          const Subtitulo('Jogador'),

          construir_nome(context),

          CartaoOpcao(

            titulo: 'Mostrar meu nome no leaderboard',
            descricao: 'Desligado, você aparece como Anônimo nas partidas do leaderboard geral.',
            valor: dados.perfis.perfil.aparecer_leaderboard,
            ao_mudar: (valor) => mudar_leaderboard(context, valor),

          ),

          const Subtitulo('Acessibilidade'),

          construir_tamanho(context),

          ...construir_acessibilidade(context),

        ],

      ),

    );

  }


  List<Widget> construir_acessibilidade(BuildContext context) {

    Perfil perfil = dados.perfis.perfil;

    return [

      CartaoOpcao(

        titulo: 'Alto contraste',
        descricao: 'Usa preto no branco, traços mais grossos e fundo sem quadriculado.',
        valor: perfil.alto_contraste,
        ao_mudar: (valor) => alterar(context, (perfil) => perfil.alto_contraste = valor),

      ),

      CartaoOpcao(

        titulo: 'Espaçar letras',
        descricao: 'Afasta letras e palavras para facilitar a leitura.',
        valor: perfil.letras_espacadas,
        ao_mudar: (valor) => alterar(context, (perfil) => perfil.letras_espacadas = valor),

      ),

      CartaoOpcao(

        titulo: 'Marcas no teclado',
        descricao: 'Mostra um sinal de certo ou errado nas letras usadas, sem depender da cor.',
        valor: perfil.marcas_teclado,
        ao_mudar: (valor) => alterar(context, (perfil) => perfil.marcas_teclado = valor),

      ),

      CartaoOpcao(

        titulo: 'Teclado em ordem alfabética',
        descricao: 'Organiza as letras de A a Z.',
        valor: perfil.teclado_alfabetico,
        ao_mudar: (valor) => alterar(context, (perfil) => perfil.teclado_alfabetico = valor),

      ),

      CartaoOpcao(

        titulo: 'Reduzir animações',
        descricao: 'O desenho da forca aparece sem efeito.',
        valor: perfil.reduzir_animacoes,
        ao_mudar: (valor) => alterar(context, (perfil) => perfil.reduzir_animacoes = valor),

      ),

    ];

  }


  Widget construir_nome(BuildContext context) {

    String nome = dados.perfis.perfil.nome;

    return Cartao(

      conteudo: ListTile(

        title: const Text('Nome do jogador'),
        subtitle: Text(nome.isEmpty ? 'Nenhum nome escolhido' : nome),

        trailing: OutlinedButton(

          onPressed: () => pedir_nome(context, dados),
          child: const Text('Mudar'),

        ),

      ),

    );

  }


  Widget construir_tamanho(BuildContext context) {

    return Cartao(

      conteudo: Padding(

        padding: const EdgeInsets.all(16),

        child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            const Text('Tamanho do texto', style: TextStyle(fontSize: 16)),

            const SizedBox(height: 10),

            Wrap(

              spacing: 8,
              runSpacing: 8,

              children: [

                for (TamanhoTexto tamanho in TamanhoTexto.values)

                  ChoiceChip(

                    label: Text(tamanho.nome),
                    selected: dados.perfis.perfil.tamanho_texto == tamanho,
                    selectedColor: EstiloCaderno.de(context).marca_texto,
                    backgroundColor: Colors.white,
                    onSelected: (_) => alterar(context, (perfil) => perfil.tamanho_texto = tamanho),

                  ),

              ],

            ),

          ],

        ),

      ),

    );

  }

}
