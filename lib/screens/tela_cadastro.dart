import 'package:flutter/material.dart';

import '../models/categoria.dart';
import '../models/nivel.dart';
import '../models/palavra.dart';
import '../services/repositorio_palavras.dart';
import '../services/validador.dart';
import '../widgets/tema_caderno.dart';


class TelaCadastro extends StatefulWidget {

  final RepositorioPalavras palavras;


  const TelaCadastro({super.key, required this.palavras});


  @override
  State<TelaCadastro> createState() => _TelaCadastroState();

}


class _TelaCadastroState extends State<TelaCadastro> {

  final GlobalKey<FormState> chave_formulario = GlobalKey<FormState>();
  final TextEditingController controle_texto = TextEditingController();
  final TextEditingController controle_dica = TextEditingController();

  Categoria categoria_escolhida = Categoria.c;
  Nivel nivel_escolhido = Nivel.facil;
  bool salvando = false;


  @override
  void dispose() {

    controle_texto.dispose();
    controle_dica.dispose();
    super.dispose();

  }


  Future<void> salvar_palavra() async {

    if (salvando || !chave_formulario.currentState!.validate()) {

      return;

    }

    Palavra palavra_nova = Palavra(

      texto: controle_texto.text.trim().replaceAll(RegExp(r'\s+'), ' '),
      dica: controle_dica.text.trim(),
      categoria: categoria_escolhida,
      nivel: nivel_escolhido,

    );

    setState(() {

      salvando = true;

    });

    String mensagem = 'Palavra salva.';

    try {

      await widget.palavras.adicionar(palavra_nova);

      chave_formulario.currentState?.reset();
      controle_texto.clear();
      controle_dica.clear();

    } on Object {

      mensagem = 'Não foi possível salvar a palavra. Tente de novo.';

    }

    if (!mounted) {

      return;

    }

    setState(() {

      salvando = false;

    });

    mostrar_aviso(context, mensagem);

  }


  Future<void> remover_palavra(Palavra palavra) async {

    bool confirmou = await confirmar_acao(

      context,
      'Excluir a palavra?',
      '"${palavra.texto}" sairá do jogo.',
      'Excluir palavra',

    );

    if (!confirmou) {

      return;

    }

    String mensagem = 'Palavra excluída.';

    try {

      await widget.palavras.remover(palavra);

    } on Object {

      mensagem = 'Não foi possível excluir a palavra. Tente de novo.';

    }

    if (!mounted) {

      return;

    }

    setState(() {});

    mostrar_aviso(context, mensagem);

  }


  @override
  Widget build(BuildContext context) {

    List<Palavra> cadastradas = widget.palavras.palavras_cadastradas;

    return PaginaCaderno(

      titulo: 'Cadastrar palavras',

      conteudo: [

        construir_formulario(),

        const Subtitulo('Palavras que você cadastrou'),

        if (cadastradas.isEmpty)

          const Text('Nenhuma ainda. Preencha os campos acima para criar a primeira.')

        else

          for (Palavra palavra in cadastradas) construir_item(palavra),

      ],

    );

  }


  Widget construir_formulario() {

    return Form(

      key: chave_formulario,

      child: Column(

        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          TextFormField(

            controller: controle_texto,
            maxLength: maximo_caracteres,
            decoration: const InputDecoration(labelText: 'Palavra'),
            validator: (valor) => validar_texto(valor) ?? validar_repeticao(valor!, widget.palavras.todas),

          ),

          const SizedBox(height: 8),

          TextFormField(

            controller: controle_dica,
            maxLength: maximo_dica,
            decoration: const InputDecoration(labelText: 'Dica'),
            validator: (valor) => validar_dica(valor, controle_texto.text),

          ),

          const Subtitulo('Categoria'),

          construir_categorias(),

          const Subtitulo('Nível'),

          construir_niveis(),

          const SizedBox(height: 20),

          FilledButton(

            onPressed: salvando ? null : salvar_palavra,
            child: const Text('Salvar palavra'),

          ),

        ],

      ),

    );

  }


  Widget construir_categorias() {

    return Wrap(

      spacing: 8,
      runSpacing: 8,

      children: [

        for (Categoria categoria in Categoria.values)

          ChoiceChip(

            label: Text(categoria.nome),
            selected: categoria_escolhida == categoria,
            selectedColor: cor_marca_texto,
            backgroundColor: Colors.white,

            onSelected: (_) {

              setState(() {

                categoria_escolhida = categoria;

              });

            },

          ),

      ],

    );

  }


  Widget construir_niveis() {

    return Wrap(

      spacing: 8,
      runSpacing: 8,

      children: [

        for (Nivel nivel in Nivel.values)

          ChoiceChip(

            label: Text(nivel.nome),
            selected: nivel_escolhido == nivel,
            selectedColor: cor_marca_texto,
            backgroundColor: Colors.white,

            onSelected: (_) {

              setState(() {

                nivel_escolhido = nivel;

              });

            },

          ),

      ],

    );

  }


  Widget construir_item(Palavra palavra) {

    return Padding(

      padding: const EdgeInsets.only(bottom: 8),

      child: Material(

        color: Colors.white,
        shape: const RoundedRectangleBorder(side: BorderSide(color: cor_tinta)),

        child: ListTile(

          title: Text(palavra.texto, style: const TextStyle(fontWeight: FontWeight.w700)),
          subtitle: Text('${palavra.categoria.nome}, ${palavra.nivel.nome.toLowerCase()}. ${palavra.dica}'),

          trailing: IconButton(

            onPressed: () => remover_palavra(palavra),
            tooltip: 'Excluir palavra',
            icon: const Icon(Icons.delete_outline, color: cor_caneta_vermelha),

          ),

        ),

      ),

    );

  }

}
