import 'package:flutter/material.dart';

import '../services/dados_aplicativo.dart';
import '../services/validador.dart';
import 'tema_caderno.dart';


Future<bool> garantir_nome(BuildContext context, DadosAplicativo dados) async {

  if (dados.perfis.tem_nome) {

    return true;

  }

  return pedir_nome(context, dados);

}


Future<bool> pedir_nome(BuildContext context, DadosAplicativo dados) async {

  String? nome = await showDialog<String>(

    context: context,
    builder: (context) => DialogoNome(nome_atual: dados.perfis.perfil.nome),

  );

  if (nome == null) {

    return false;

  }

  try {

    await dados.perfis.mudar_nome(nome);

  } on Object {

    if (context.mounted) {

      mostrar_aviso(context, 'Não foi possível salvar o nome neste aparelho.');

    }

  }

  return true;

}


class DialogoNome extends StatefulWidget {

  final String nome_atual;


  const DialogoNome({super.key, required this.nome_atual});


  @override
  State<DialogoNome> createState() => _DialogoNomeState();

}


class _DialogoNomeState extends State<DialogoNome> {

  final GlobalKey<FormState> chave_formulario = GlobalKey<FormState>();

  late final TextEditingController controle_nome = TextEditingController(text: widget.nome_atual);


  @override
  void dispose() {

    controle_nome.dispose();
    super.dispose();

  }


  void salvar() {

    if (chave_formulario.currentState!.validate()) {

      Navigator.of(context).pop(controle_nome.text);

    }

  }


  @override
  Widget build(BuildContext context) {

    return AlertDialog(

      scrollable: true,
      title: const Text('Seu nome no jogo'),

      content: Form(

        key: chave_formulario,
        autovalidateMode: AutovalidateMode.onUserInteractionIfError,

        child: Column(

          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            const Text('Outras pessoas veem esse nome no desafio e no leaderboard.'),

            const SizedBox(height: 16),

            TextFormField(

              controller: controle_nome,
              autofocus: true,
              maxLength: maximo_nome,
              decoration: const InputDecoration(labelText: 'Nome'),
              validator: validar_nome,
              onFieldSubmitted: (_) => salvar(),

            ),

          ],

        ),

      ),

      actions: [

        TextButton(

          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),

        ),

        FilledButton(

          onPressed: salvar,
          child: const Text('Salvar nome'),

        ),

      ],

    );

  }

}
