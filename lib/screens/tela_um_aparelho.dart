import 'package:flutter/material.dart';

import '../models/categoria.dart';
import '../models/nivel.dart';
import '../models/palavra.dart';
import '../services/dados_aplicativo.dart';
import '../widgets/estilo_caderno.dart';
import '../widgets/tema_caderno.dart';
import 'tela_duelo.dart';
import 'tela_jogo.dart';


// Tela do modo um aparelho: jogo solo e dois jogadores
class TelaUmAparelho extends StatefulWidget {

  final DadosAplicativo dados;


  const TelaUmAparelho({super.key, required this.dados});


  @override
  State<TelaUmAparelho> createState() => _TelaUmAparelhoState();

}


class _TelaUmAparelhoState extends State<TelaUmAparelho> {

  Nivel? nivel_escolhido;


  // Abre outra tela por cima desta
  void abrir_tela(Widget tela) {

    Navigator.of(context).push(MaterialPageRoute<void>(builder: (context) => tela));

  }


  // Sorteia uma palavra da categoria e começa a partida
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


  // Monta a tela do modo um aparelho
  @override
  Widget build(BuildContext context) {

    return PaginaCaderno(

      titulo: 'Um aparelho',

      conteudo: [

        const Subtitulo('Jogar só: escolha o nível'),

        construir_niveis(),

        const Subtitulo('Escolha a categoria'),

        for (Categoria categoria in Categoria.values) construir_categoria(categoria),

        const Subtitulo('Jogar em dupla'),

        OutlinedButton.icon(

          onPressed: () => abrir_tela(TelaDuelo(dados: widget.dados)),
          icon: const Icon(Icons.people_outline),
          label: const Text('Dois jogadores'),

        ),

      ],

    );

  }


  // Botões de nível
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


  // Botão de um nível
  Widget construir_filtro(String rotulo, Nivel? nivel) {

    return ChoiceChip(

      label: Text(rotulo),
      selected: nivel_escolhido == nivel,
      selectedColor: EstiloCaderno.de(context).marca_texto,
      backgroundColor: Colors.white,

      onSelected: (_) {

        setState(() {

          nivel_escolhido = nivel;

        });

      },

    );

  }


  // Botão de uma categoria com o total de palavras
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

}
