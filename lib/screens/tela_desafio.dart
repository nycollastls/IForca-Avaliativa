import 'package:flutter/material.dart';

import '../models/sala_desafio.dart';
import '../services/dados_aplicativo.dart';
import '../services/servico_online.dart';
import '../services/validador.dart';
import '../widgets/cartao_opcao.dart';
import '../widgets/tema_caderno.dart';
import 'tela_sala.dart';


class TelaDesafio extends StatefulWidget {

  final DadosAplicativo dados;


  const TelaDesafio({super.key, required this.dados});


  @override
  State<TelaDesafio> createState() => _TelaDesafioState();

}


class _TelaDesafioState extends State<TelaDesafio> {

  final GlobalKey<FormState> chave_formulario = GlobalKey<FormState>();
  final TextEditingController controle_codigo = TextEditingController();

  bool conectando = false;
  bool partida_publica = false;


  @override
  void dispose() {

    controle_codigo.dispose();
    super.dispose();

  }


  Future<void> abrir_sala(Future<SalaDesafio> Function() pedido) async {

    setState(() {

      conectando = true;

    });

    try {

      SalaDesafio sala = await pedido();

      if (!mounted) {

        widget.dados.online.sair_sala(widget.dados.perfis.perfil, sala.codigo).ignore();
        return;

      }

      await Navigator.of(context).push(

        MaterialPageRoute<void>(builder: (context) => TelaSala(dados: widget.dados, sala_inicial: sala)),

      );

    } on ErroServidor catch (erro) {

      if (mounted) {

        mostrar_aviso(context, erro.mensagem);

      }

    } on Object {

      if (mounted) {

        mostrar_aviso(context, 'Não foi possível abrir a sala.');

      }

    }

    if (mounted) {

      setState(() {

        conectando = false;

      });

    }

  }


  void criar_sala() {

    abrir_sala(() => widget.dados.online.criar_sala(widget.dados.perfis.perfil, partida_publica));

  }


  void entrar_sala() {

    if (!chave_formulario.currentState!.validate()) {

      return;

    }

    String codigo = controle_codigo.text.trim().toUpperCase();

    abrir_sala(() => widget.dados.online.entrar_sala(widget.dados.perfis.perfil, codigo));

  }


  @override
  Widget build(BuildContext context) {

    return PaginaCaderno(

      titulo: 'Desafio multiplayer',

      conteudo: conectando ? const [AvisoConexao()] : construir_opcoes(),

    );

  }


  List<Widget> construir_opcoes() {

    return [

      const Text(

        'Uma pessoa escreve a palavra e as outras tentam adivinhar, cada uma no próprio aparelho. '
        'A cada rodada, troca quem escreve. Cabem até 6 pessoas na sala.',

      ),

      const Subtitulo('Começar uma sala nova'),

      CartaoOpcao(

        titulo: 'Mostrar no leaderboard geral',
        descricao: 'Todos poderão ver os nomes e os pontos desta partida.',
        valor: partida_publica,

        ao_mudar: (valor) {

          setState(() {

            partida_publica = valor;

          });

        },

      ),

      FilledButton(

        onPressed: criar_sala,
        child: const Text('Criar sala'),

      ),

      const Subtitulo('Entrar com o código de alguém'),

      Form(

        key: chave_formulario,
        autovalidateMode: AutovalidateMode.onUserInteractionIfError,

        child: Column(

          crossAxisAlignment: CrossAxisAlignment.stretch,

          children: [

            TextFormField(

              controller: controle_codigo,
              maxLength: tamanho_codigo,
              autocorrect: false,
              enableSuggestions: false,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(labelText: 'Código da sala'),
              validator: validar_codigo,
              onFieldSubmitted: (_) => entrar_sala(),

            ),

            const SizedBox(height: 8),

            OutlinedButton(

              onPressed: entrar_sala,
              child: const Text('Entrar na sala'),

            ),

          ],

        ),

      ),

    ];

  }

}
