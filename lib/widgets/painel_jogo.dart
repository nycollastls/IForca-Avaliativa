import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/jogo_forca.dart';
import '../models/palavra.dart';
import '../models/resultado.dart';
import '../services/regras_pontuacao.dart';
import '../services/texto.dart';
import 'desenho_forca.dart';
import 'estilo_caderno.dart';
import 'palavra_oculta.dart';
import 'teclado_virtual.dart';
import 'tema_caderno.dart';


class PainelJogo extends StatefulWidget {

  final Palavra palavra;
  final Future<void> Function(Resultado resultado) ao_terminar;
  final Palavra? Function(Palavra anterior)? sortear_proxima;
  final VoidCallback? ao_voltar;


  const PainelJogo({

    super.key,
    required this.palavra,
    required this.ao_terminar,
    this.sortear_proxima,
    this.ao_voltar,

  });


  @override
  State<PainelJogo> createState() => _PainelJogoState();

}


class _PainelJogoState extends State<PainelJogo> {

  late JogoForca jogo = JogoForca(palavra: widget.palavra);

  final FocusNode foco_teclado = FocusNode();

  Resultado? resultado;


  @override
  void dispose() {

    foco_teclado.dispose();
    super.dispose();

  }


  void novo_jogo() {

    Palavra? proxima_palavra = widget.sortear_proxima?.call(jogo.palavra);

    if (proxima_palavra == null) {

      mostrar_aviso(context, 'Não há outra palavra disponível.');
      return;

    }

    setState(() {

      jogo = JogoForca(palavra: proxima_palavra);
      resultado = null;

    });

    foco_teclado.requestFocus();

  }


  void escolher_letra(String letra) {

    if (resultado != null) {

      return;

    }

    setState(() {

      jogo.tentar_letra(letra);

    });

    foco_teclado.requestFocus();

    if (jogo.encerrado) {

      terminar_partida();

    }

  }


  Future<void> terminar_partida() async {

    Resultado resultado_final = gerar_resultado(jogo);

    setState(() {

      resultado = resultado_final;

    });

    try {

      await widget.ao_terminar(resultado_final);

    } on Object {

      if (mounted) {

        mostrar_aviso(context, 'Não foi possível salvar o resultado desta partida.');

      }

    }

  }


  void pedir_dica() {

    setState(jogo.usar_dica);

    foco_teclado.requestFocus();

  }


  KeyEventResult tratar_tecla(FocusNode foco, KeyEvent evento) {

    String? caractere = evento.character;

    if (evento is! KeyDownEvent || caractere == null || !eh_letra(caractere)) {

      return KeyEventResult.ignored;

    }

    escolher_letra(normalizar_texto(caractere));

    return KeyEventResult.handled;

  }


  @override
  Widget build(BuildContext context) {

    Resultado? resultado_final = resultado;

    return Focus(

      focusNode: foco_teclado,
      autofocus: true,
      onKeyEvent: tratar_tecla,

      child: Column(

        crossAxisAlignment: CrossAxisAlignment.stretch,

        children: [

          construir_situacao(),

          const SizedBox(height: 8),

          Center(

            child: DesenhoForca(quantidade_erros: jogo.quantidade_erros, maximo_erros: jogo.maximo_erros),

          ),

          const SizedBox(height: 16),

          PalavraOculta(jogo: jogo),

          const SizedBox(height: 20),

          construir_dica(),

          const SizedBox(height: 16),

          if (resultado_final == null)

            TecladoVirtual(jogo: jogo, ao_escolher: escolher_letra)

          else

            construir_fim_de_jogo(resultado_final),

        ],

      ),

    );

  }


  Widget construir_situacao() {

    return Wrap(

      alignment: WrapAlignment.spaceBetween,
      spacing: 16,
      runSpacing: 4,

      children: [

        Text('Nível ${jogo.palavra.nivel.nome.toLowerCase()}'),

        Semantics(

          liveRegion: true,
          child: Text('Erros: ${jogo.quantidade_erros} de ${jogo.maximo_erros}'),

        ),

        Text('Vale ${calcular_pontos_vitoria(jogo)} pontos', style: const TextStyle(fontWeight: FontWeight.w700)),

      ],

    );

  }


  Widget construir_dica() {

    if (jogo.dica_usada) {

      return Center(

        child: Container(

          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          color: EstiloCaderno.de(context).marca_texto,

          child: Text(jogo.palavra.dica, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),

        ),

      );

    }

    if (jogo.encerrado) {

      return const SizedBox.shrink();

    }

    return Center(

      child: OutlinedButton.icon(

        onPressed: pedir_dica,
        icon: const Icon(Icons.lightbulb_outline),
        label: const Text('Ver dica (custa $custo_dica pontos)'),

      ),

    );

  }


  String montar_mensagem(Resultado resultado_final) {

    if (resultado_final.venceu) {

      return 'Você acertou e ganhou ${resultado_final.pontos} pontos.';

    }

    String mensagem = 'Fim das tentativas. A palavra era ${jogo.palavra_secreta}.';

    if (resultado_final.pontos < 0) {

      return '$mensagem A dica custou ${-resultado_final.pontos} pontos.';

    }

    return mensagem;

  }


  Widget construir_fim_de_jogo(Resultado resultado_final) {

    return Column(

      children: [

        Text(

          montar_mensagem(resultado_final),
          textAlign: TextAlign.center,

          style: TextStyle(

            fontSize: 19,
            fontWeight: FontWeight.w700,
            color: resultado_final.venceu ? EstiloCaderno.de(context).acerto : EstiloCaderno.de(context).vermelha,

          ),

        ),

        const SizedBox(height: 16),

        Wrap(

          alignment: WrapAlignment.center,
          spacing: 12,
          runSpacing: 12,

          children: [

            if (widget.sortear_proxima != null)

              FilledButton(

                onPressed: novo_jogo,
                child: const Text('Próxima palavra'),

              ),

            if (widget.ao_voltar != null)

              OutlinedButton(

                onPressed: widget.ao_voltar,
                child: const Text('Voltar'),

              ),

          ],

        ),

      ],

    );

  }

}
