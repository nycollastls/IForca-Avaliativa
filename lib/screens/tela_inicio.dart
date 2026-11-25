import 'package:flutter/material.dart';

import '../models/categoria.dart';
import '../models/nivel.dart';
import '../models/palavra.dart';
import '../models/placar.dart';
import '../services/dados_aplicativo.dart';
import '../widgets/tema_caderno.dart';
import 'tela_cadastro.dart';
import 'tela_duelo.dart';
import 'tela_jogo.dart';
import 'tela_placar.dart';


class TelaInicio extends StatefulWidget {

  final DadosAplicativo dados;


  const TelaInicio({super.key, required this.dados});


  @override
  State<TelaInicio> createState() => _TelaInicioState();

}


class _TelaInicioState extends State<TelaInicio> {

  Nivel? nivel_escolhido;


  Future<void> abrir_tela(Widget tela) async {

    await Navigator.of(context).push(MaterialPageRoute<void>(builder: (context) => tela));

    if (mounted) {

      setState(() {});

    }

  }


  void abrir_jogo(Categoria categoria) {

    Nivel? nivel = nivel_escolhido;
    Palavra? palavra_sorteada = widget.dados.palavras.sortear(categoria, nivel);

    if (palavra_sorteada == null) {

      mostrar_aviso(context, 'Não há palavras de ${categoria.nome} nesse nível. Cadastre uma para jogar.');
      return;

    }

    abrir_tela(

      TelaJogo(

        titulo: 'Forca: ${categoria.nome}',
        palavra: palavra_sorteada,
        ao_terminar: widget.dados.placares.registrar_partida,
        sortear_proxima: (anterior) => widget.dados.palavras.sortear(categoria, nivel, anterior: anterior),

      ),

    );

  }


  @override
  Widget build(BuildContext context) {

    Placar placar = widget.dados.placares.placar;

    return PaginaCaderno(

      titulo: 'Forca da Programação',

      conteudo: [

        construir_resumo(placar),

        const Subtitulo('Nível'),

        construir_niveis(),

        const Subtitulo('Escolha a categoria'),

        for (Categoria categoria in Categoria.values) construir_categoria(categoria),

        const Subtitulo('Mais opções'),

        construir_opcoes(),

      ],

    );

  }


  Widget construir_resumo(Placar placar) {

    int sequencia = placar.sequencia_atual;
    String texto_sequencia = sequencia == 1 ? '1 acerto seguido' : '$sequencia acertos seguidos';

    return Text(

      'Você tem ${placar.pontos} pontos e $texto_sequencia.',
      style: const TextStyle(fontSize: 17),

    );

  }


  Widget construir_niveis() {

    return Wrap(

      spacing: 8,
      runSpacing: 8,

      children: [

        construir_filtro('Todos', null),

        for (Nivel nivel in Nivel.values) construir_filtro(nivel.nome, nivel),

      ],

    );

  }


  Widget construir_filtro(String rotulo, Nivel? nivel) {

    return ChoiceChip(

      label: Text(rotulo),
      selected: nivel_escolhido == nivel,
      selectedColor: cor_marca_texto,
      backgroundColor: Colors.white,

      onSelected: (_) {

        setState(() {

          nivel_escolhido = nivel;

        });

      },

    );

  }


  Widget construir_categoria(Categoria categoria) {

    int total_palavras = widget.dados.palavras.filtrar(categoria, nivel_escolhido).length;

    return Padding(

      padding: const EdgeInsets.only(bottom: 10),

      child: FilledButton(

        onPressed: () => abrir_jogo(categoria),
        style: FilledButton.styleFrom(minimumSize: const Size(48, 64)),

        child: Row(

          children: [

            Expanded(

              child: Text(categoria.nome, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),

            ),

            Text(total_palavras == 1 ? '1 palavra' : '$total_palavras palavras'),

          ],

        ),

      ),

    );

  }


  Widget construir_opcoes() {

    return Wrap(

      spacing: 10,
      runSpacing: 10,

      children: [

        OutlinedButton.icon(

          onPressed: () => abrir_tela(TelaDuelo(dados: widget.dados)),
          icon: const Icon(Icons.people_outline),
          label: const Text('Dois jogadores'),

        ),

        OutlinedButton.icon(

          onPressed: () => abrir_tela(TelaCadastro(palavras: widget.dados.palavras)),
          icon: const Icon(Icons.edit_outlined),
          label: const Text('Cadastrar palavras'),

        ),

        OutlinedButton.icon(

          onPressed: () => abrir_tela(TelaPlacar(placares: widget.dados.placares)),
          icon: const Icon(Icons.emoji_events_outlined),
          label: const Text('Ver placar'),

        ),

      ],

    );

  }

}
