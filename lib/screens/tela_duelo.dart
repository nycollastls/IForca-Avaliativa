import 'package:flutter/material.dart';

import '../models/categoria.dart';
import '../models/duelo.dart';
import '../models/nivel.dart';
import '../models/palavra.dart';
import '../services/dados_aplicativo.dart';
import '../services/validador.dart';
import '../widgets/tema_caderno.dart';
import 'tela_jogo.dart';


// Modo dois jogadores no mesmo aparelho
class TelaDuelo extends StatefulWidget {

  final DadosAplicativo dados;


  const TelaDuelo({super.key, required this.dados});


  @override
  State<TelaDuelo> createState() => _TelaDueloState();

}


class _TelaDueloState extends State<TelaDuelo> {

  final GlobalKey<FormState> chave_nomes = GlobalKey<FormState>();
  final GlobalKey<FormState> chave_palavra = GlobalKey<FormState>();

  final TextEditingController controle_primeiro = TextEditingController();
  final TextEditingController controle_segundo = TextEditingController();
  final TextEditingController controle_palavra = TextEditingController();
  final TextEditingController controle_dica = TextEditingController();

  bool palavra_visivel = false;


  @override
  void dispose() {

    controle_primeiro.dispose();
    controle_segundo.dispose();
    controle_palavra.dispose();
    controle_dica.dispose();
    super.dispose();

  }


  // Salva o duelo e avisa se não conseguir
  Future<void> salvar(Future<void> Function() acao) async {

    try {

      await acao();

    } on Object {

      if (mounted) {

        mostrar_aviso(context, 'Não foi possível salvar o duelo neste aparelho.');

      }

    }

    if (mounted) {

      setState(() {});

    }

  }


  // Confere os nomes e começa o duelo
  Future<void> iniciar_duelo() async {

    if (!chave_nomes.currentState!.validate()) {

      return;

    }

    await salvar(() => widget.dados.placares.iniciar_duelo(controle_primeiro.text, controle_segundo.text));

  }


  // Pede confirmação e encerra o duelo
  Future<void> encerrar_duelo() async {

    bool confirmou = await confirmar_acao(

      context,
      'Encerrar o duelo?',
      'A pontuação dos dois jogadores será apagada.',
      'Encerrar duelo',

    );

    if (confirmou) {

      await salvar(widget.dados.placares.encerrar_duelo);

    }

  }


  // Esconde a palavra secreta e passa o aparelho para quem vai adivinhar
  Future<void> iniciar_rodada(Duelo duelo) async {

    if (!chave_palavra.currentState!.validate()) {

      return;

    }

    Palavra palavra_secreta = Palavra(

      texto: controle_palavra.text.trim().replaceAll(RegExp(r'\s+'), ' '),
      dica: controle_dica.text.trim(),
      categoria: Categoria.logica,
      nivel: Nivel.medio,

    );

    bool confirmou = await confirmar_acao(

      context,
      'Passe o aparelho',
      'A palavra está escondida. Entregue o aparelho para ${duelo.nome_adivinhador}.',
      'Começar rodada',

    );

    if (!confirmou || !mounted) {

      return;

    }

    controle_palavra.clear();
    controle_dica.clear();
    palavra_visivel = false;

    await Navigator.of(context).push(

      MaterialPageRoute<void>(

        builder: (context) => TelaJogo(

          titulo: 'Vez de ${duelo.nome_adivinhador}',
          palavra: palavra_secreta,
          ao_terminar: widget.dados.placares.registrar_rodada,

        ),

      ),

    );

    if (mounted) {

      setState(() {});

    }

  }


  // Monta a tela do duelo
  @override
  Widget build(BuildContext context) {

    Duelo? duelo = widget.dados.placares.duelo;

    return PaginaCaderno(

      titulo: 'Dois jogadores',

      conteudo: duelo == null ? construir_inicio() : construir_rodada(duelo),

    );

  }


  // Formulário com o nome dos dois jogadores
  List<Widget> construir_inicio() {

    return [

      const Text('Um jogador escreve a palavra e o outro tenta adivinhar. A cada rodada, vocês trocam de papel.'),

      const SizedBox(height: 20),

      Form(

        key: chave_nomes,
        autovalidateMode: AutovalidateMode.onUserInteractionIfError,

        child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            TextFormField(

              controller: controle_primeiro,
              maxLength: maximo_nome,
              decoration: const InputDecoration(labelText: 'Primeiro jogador'),
              validator: validar_nome,

            ),

            const SizedBox(height: 8),

            TextFormField(

              controller: controle_segundo,
              maxLength: maximo_nome,
              decoration: const InputDecoration(labelText: 'Segundo jogador'),
              validator: (valor) => validar_nome(valor) ?? validar_nomes_diferentes(controle_primeiro.text, valor!),

            ),

            const SizedBox(height: 16),

            FilledButton(

              onPressed: iniciar_duelo,
              child: const Text('Começar duelo'),

            ),

          ],

        ),

      ),

    ];

  }


  // Placar do duelo e formulário da palavra secreta
  List<Widget> construir_rodada(Duelo duelo) {

    return [

      for (int indice = 0; indice < duelo.nomes.length; indice++)

        Padding(

          padding: const EdgeInsets.symmetric(vertical: 4),

          child: Row(

            children: [

              Expanded(child: Text(duelo.nomes[indice], style: const TextStyle(fontSize: 18))),

              Text('${duelo.pontos[indice]} pontos', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),

            ],

          ),

        ),

      Subtitulo('${duelo.nome_desafiante}, escreva a palavra para ${duelo.nome_adivinhador}'),

      Form(

        key: chave_palavra,
        autovalidateMode: AutovalidateMode.onUserInteractionIfError,

        child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            TextFormField(

              controller: controle_palavra,
              maxLength: maximo_caracteres,
              obscureText: !palavra_visivel,
              enableSuggestions: false,
              autocorrect: false,

              decoration: InputDecoration(

                labelText: 'Palavra secreta',

                suffixIcon: IconButton(

                  tooltip: palavra_visivel ? 'Esconder palavra' : 'Mostrar palavra',
                  icon: Icon(palavra_visivel ? Icons.visibility_off_outlined : Icons.visibility_outlined),

                  onPressed: () {

                    setState(() {

                      palavra_visivel = !palavra_visivel;

                    });

                  },

                ),

              ),

              validator: validar_texto,

            ),

            const SizedBox(height: 8),

            TextFormField(

              controller: controle_dica,
              maxLength: maximo_dica,
              decoration: const InputDecoration(labelText: 'Dica'),
              validator: (valor) => validar_dica(valor, controle_palavra.text),

            ),

            const SizedBox(height: 16),

            Wrap(

              spacing: 12,
              runSpacing: 12,

              children: [

                FilledButton(

                  onPressed: () => iniciar_rodada(duelo),
                  child: Text('Passar para ${duelo.nome_adivinhador}'),

                ),

                OutlinedButton(

                  onPressed: encerrar_duelo,
                  child: const Text('Encerrar duelo'),

                ),

              ],

            ),

          ],

        ),

      ),

    ];

  }

}
