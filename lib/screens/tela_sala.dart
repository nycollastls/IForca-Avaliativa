import 'dart:async';

import 'package:flutter/material.dart';

import '../models/categoria.dart';
import '../models/jogo_forca.dart';
import '../models/nivel.dart';
import '../models/palavra.dart';
import '../models/perfil.dart';
import '../models/resultado.dart';
import '../models/sala_desafio.dart';
import '../services/dados_aplicativo.dart';
import '../services/servico_online.dart';
import '../services/validador.dart';
import '../widgets/estilo_caderno.dart';
import '../widgets/lista_jogadores.dart';
import '../widgets/painel_espectador.dart';
import '../widgets/painel_jogo.dart';
import '../widgets/tema_caderno.dart';


// De quanto em quanto tempo a sala pergunta o estado ao servidor
const Duration intervalo_consulta = Duration(seconds: 2);


// Tela da sala multiplayer
class TelaSala extends StatefulWidget {

  final DadosAplicativo dados;
  final SalaDesafio sala_inicial;


  const TelaSala({super.key, required this.dados, required this.sala_inicial});


  @override
  State<TelaSala> createState() => _TelaSalaState();

}


class _TelaSalaState extends State<TelaSala> {

  final GlobalKey<FormState> chave_palavra = GlobalKey<FormState>();
  final TextEditingController controle_palavra = TextEditingController();
  final TextEditingController controle_dica = TextEditingController();

  late SalaDesafio sala = widget.sala_inicial;
  late final Timer relogio_consulta;

  Resultado? resultado_pendente;
  List<String> letras_tentadas = [];
  bool dica_usada = false;
  int rodada_do_resultado = 0;
  int rodada_do_painel = 0;
  int total_pedidos = 0;
  bool consultando = false;
  bool executando = false;
  bool sem_conexao = false;
  bool sala_perdida = false;


  Perfil get perfil => widget.dados.perfis.perfil;

  ServicoOnline get online => widget.dados.online;


  // Começa a consultar o servidor de tempos em tempos
  @override
  void initState() {

    super.initState();

    marcar_painel();
    relogio_consulta = Timer.periodic(intervalo_consulta, (_) => consultar());

  }


  // Para as consultas e avisa o servidor que saiu da sala
  @override
  void dispose() {

    relogio_consulta.cancel();
    controle_palavra.dispose();
    controle_dica.dispose();

    if (!sala_perdida) {

      online.sair_sala(perfil, sala.codigo).ignore();

    }

    super.dispose();

  }


  // Guarda a rodada em que este jogador começou a jogar
  void marcar_painel() {

    bool vai_jogar = sala.fase == FaseSala.jogando && sala.eu.participa && !sala.eu.terminou;

    if (vai_jogar && rodada_do_painel != sala.rodada) {

      rodada_do_painel = sala.rodada;
      letras_tentadas = [];
      dica_usada = false;

    }

  }


  // Atualiza a tela com o que veio do servidor
  void receber_sala(SalaDesafio sala_nova) {

    setState(() {

      sala = sala_nova;
      sem_conexao = false;

      marcar_painel();

    });

  }


  // Envia o resultado pendente ou só pergunta o estado da sala
  Future<SalaDesafio> pedir_estado() {

    Resultado? resultado = resultado_pendente;

    if (resultado == null) {

      return online.consultar_sala(perfil, sala.codigo);

    }

    return online.enviar_resultado(perfil, sala.codigo, rodada_do_resultado, resultado, letras: letras_tentadas, dica_usada: dica_usada);

  }


  // Consulta o servidor sem atrapalhar uma ação em andamento
  Future<void> consultar() async {

    if (consultando || executando || sala_perdida) {

      return;

    }

    consultando = true;
    total_pedidos++;

    int numero_pedido = total_pedidos;
    Resultado? resultado_enviado = resultado_pendente;

    try {

      SalaDesafio sala_nova = await pedir_estado();

      if (resultado_enviado != null && identical(resultado_enviado, resultado_pendente)) {

        resultado_pendente = null;

      }

      if (mounted && numero_pedido == total_pedidos) {

        receber_sala(sala_nova);

      }

    } on ErroServidor catch (erro) {

      tratar_erro_consulta(erro);

    } on Object {

      tratar_erro_consulta(const ErroServidor('Resposta inesperada.'));

    } finally {

      consultando = false;

    }

  }


  // Mostra o aviso de falta de conexão ou de sala encerrada
  void tratar_erro_consulta(ErroServidor erro) {

    if (!mounted) {

      return;

    }

    setState(() {

      sem_conexao = true;
      sala_perdida = erro.sala_perdida;

    });

  }


  // Executa uma ação na sala e mostra o erro, se houver
  Future<bool> executar(Future<SalaDesafio> Function() pedido) async {

    if (executando) {

      return false;

    }

    total_pedidos++;

    setState(() {

      executando = true;

    });

    bool funcionou = false;

    try {

      SalaDesafio sala_nova = await pedido();

      funcionou = true;

      if (mounted) {

        receber_sala(sala_nova);

      }

    } on ErroServidor catch (erro) {

      if (mounted) {

        mostrar_aviso(context, erro.mensagem);

      }

    } on Object {

      if (mounted) {

        mostrar_aviso(context, 'O servidor não respondeu como esperado.');

      }

    }

    if (mounted) {

      setState(() {

        executando = false;

      });

    }

    return funcionou;

  }


  // Confere e envia a palavra secreta
  Future<void> enviar_palavra() async {

    if (!chave_palavra.currentState!.validate()) {

      return;

    }

    String palavra = controle_palavra.text.trim().replaceAll(RegExp(r'\s+'), ' ');
    String dica = controle_dica.text.trim();

    bool enviou = await executar(() => online.enviar_palavra(perfil, sala.codigo, palavra, dica));

    if (enviou && mounted) {

      controle_palavra.clear();
      controle_dica.clear();

    }

  }


  // Manda as letras ao servidor para quem está assistindo; se falhar, a próxima jogada manda de novo
  void enviar_progresso(JogoForca jogo) {

    letras_tentadas = jogo.letras_tentadas.toList()..sort();
    dica_usada = jogo.dica_usada;

    if (rodada_do_painel != sala.rodada) {

      return;

    }

    online.enviar_progresso(perfil, sala.codigo, sala.rodada, letras_tentadas, dica_usada).ignore();

  }


  // Guarda o resultado da partida para enviar ao servidor
  Future<void> terminar_partida(Resultado resultado) async {

    resultado_pendente = resultado;
    rodada_do_resultado = sala.rodada;

    await consultar();

  }


  // Confirma antes de sair da sala
  Future<void> confirmar_saida(bool ja_saiu, Object? _) async {

    if (ja_saiu) {

      return;

    }

    bool confirmou = await confirmar_acao(

      context,
      'Sair da sala?',
      'Enquanto houver alguém nela, você pode voltar com o código ${sala.codigo}.',
      'Sair da sala',

    );

    if (confirmou && mounted) {

      Navigator.of(context).pop();

    }

  }


  // Monta a tela da sala
  @override
  Widget build(BuildContext context) {

    return PopScope<Object?>(

      canPop: sala_perdida,
      onPopInvokedWithResult: confirmar_saida,

      child: PaginaCaderno(

        titulo: 'Sala ${sala.codigo}',

        conteudo: sala_perdida ? construir_sala_perdida() : construir_sala(),

      ),

    );

  }


  // Aviso de sala encerrada
  List<Widget> construir_sala_perdida() {

    return [

      const Text('Esta sala foi encerrada ou você ficou tempo demais sem conexão.'),

      const SizedBox(height: 16),

      FilledButton(

        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Voltar'),

      ),

    ];

  }


  // Conteúdo da sala: aviso de conexão, etapa atual e jogadores
  List<Widget> construir_sala() {

    return [

      if (sem_conexao)

        Container(

          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(10),
          color: EstiloCaderno.de(context).marca_texto,
          child: const Text('Sem conexão com o servidor. Tentando de novo.'),

        ),

      ...construir_fase(),

      const Subtitulo('Jogadores'),

      ListaJogadores(sala: sala),

    ];

  }


  // Escolhe o que mostrar em cada etapa da rodada
  List<Widget> construir_fase() {

    switch (sala.fase) {

      case FaseSala.espera:

        return construir_espera();

      case FaseSala.escrevendo:

        return construir_escrita();

      case FaseSala.jogando:

        return construir_partida();

      case FaseSala.resultado:

        return construir_resultado();

    }

  }


  // Sala esperando gente: código e botão de começar
  List<Widget> construir_espera() {

    bool pode_comecar = sala.total_presentes >= 2;

    return [

      if (sala.sou_espectador)

        const Padding(

          padding: EdgeInsets.only(bottom: 12),
          child: Text('Você entrou só para assistir.', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),

        ),

      const Text('Passe este código para quem vai jogar:'),

      const SizedBox(height: 8),

      FittedBox(

        fit: BoxFit.scaleDown,

        child: SelectableText(

          sala.codigo,
          style: const TextStyle(fontSize: 46, fontWeight: FontWeight.w800, letterSpacing: 6),

        ),

      ),

      const SizedBox(height: 16),

      Text(

        sala.publica ? 'Esta partida vai aparecer no leaderboard geral.' : 'Esta partida não aparece no leaderboard geral.',

      ),

      const SizedBox(height: 8),

      if (!pode_comecar)

        const Text('Falta pelo menos mais uma pessoa entrar.')

      else if (!sala.sou_anfitriao)

        const Text('Esperando quem criou a sala começar.'),

      if (sala.sou_anfitriao)

        Padding(

          padding: const EdgeInsets.only(top: 12),

          child: FilledButton(

            onPressed: pode_comecar && !executando ? () => executar(() => online.iniciar_sala(perfil, sala.codigo)) : null,
            child: const Text('Começar desafio'),

          ),

        ),

    ];

  }


  // Quem escreve digita a palavra; os outros esperam
  List<Widget> construir_escrita() {

    if (!sala.sou_desafiante) {

      return [

        Text('Rodada ${sala.rodada}. ${sala.nome_desafiante} está escrevendo a palavra.', style: const TextStyle(fontSize: 18)),

      ];

    }

    return [

      Text('Rodada ${sala.rodada}. Sua vez de escrever a palavra.', style: const TextStyle(fontSize: 18)),

      const SizedBox(height: 16),

      Form(

        key: chave_palavra,
        autovalidateMode: AutovalidateMode.onUserInteractionIfError,

        child: Column(

          crossAxisAlignment: CrossAxisAlignment.stretch,

          children: [

            TextFormField(

              controller: controle_palavra,
              maxLength: maximo_caracteres,
              autocorrect: false,
              enableSuggestions: false,
              decoration: const InputDecoration(labelText: 'Palavra secreta'),
              validator: validar_texto,

            ),

            const SizedBox(height: 8),

            TextFormField(

              controller: controle_dica,
              maxLength: maximo_dica,
              decoration: const InputDecoration(labelText: 'Dica'),
              validator: (valor) => validar_dica(valor, controle_palavra.text),

            ),

            const SizedBox(height: 8),

            FilledButton(

              onPressed: executando ? null : enviar_palavra,
              child: const Text('Enviar palavra'),

            ),

          ],

        ),

      ),

    ];

  }


  // Painel do jogo para quem adivinha, ou o acompanhamento para quem olha
  List<Widget> construir_partida() {

    if (rodada_do_painel == sala.rodada) {

      return [

        PainelJogo(

          key: ValueKey(sala.rodada),

          palavra: Palavra(

            texto: sala.palavra,
            dica: sala.dica,
            categoria: Categoria.logica,
            nivel: Nivel.medio,

          ),

          ao_terminar: terminar_partida,
          ao_jogar: enviar_progresso,

        ),

        if (sala.eu.terminou || resultado_pendente != null)

          const Padding(

            padding: EdgeInsets.only(top: 12),
            child: Text('Esperando os outros terminarem.', textAlign: TextAlign.center),

          ),

        if (sala.eu.terminou) ...construir_acompanhamento(),

      ];

    }

    if (sala.sou_desafiante) {

      return [

        Text('Estão tentando adivinhar "${sala.palavra}".', style: const TextStyle(fontSize: 18)),

        const SizedBox(height: 12),

        OutlinedButton(

          onPressed: executando ? null : () => executar(() => online.encerrar_rodada(perfil, sala.codigo, sala.rodada)),
          child: const Text('Encerrar rodada'),

        ),

        const SizedBox(height: 8),

        ...construir_acompanhamento(),

      ];

    }

    return [

      Text(descrever_espera(), style: const TextStyle(fontSize: 18)),

      const SizedBox(height: 8),

      ...construir_acompanhamento(),

    ];

  }


  // Frase para quem não está adivinhando nesta rodada
  String descrever_espera() {

    if (sala.sou_espectador) {

      return 'Rodada ${sala.rodada}. Você está assistindo.';

    }

    return sala.eu.terminou ? 'Esperando os outros terminarem.' : 'Esta rodada já começou. Você joga na próxima.';

  }


  // Cartões de quem está adivinhando, só para acompanhar
  List<Widget> construir_acompanhamento() {

    List<JogadorSala> jogando = sala.adivinhando;

    if (jogando.isEmpty) {

      return [];

    }

    return [

      const Subtitulo('Acompanhe quem está adivinhando'),

      for (JogadorSala jogador in jogando) PainelEspectador(key: ValueKey(jogador.numero), jogador: jogador),

    ];

  }


  // Diz se este jogador acertou ou não
  Widget construir_meu_resultado() {

    EstiloCaderno estilo = EstiloCaderno.de(context);

    return Padding(

      padding: const EdgeInsets.only(bottom: 8),

      child: Semantics(

        liveRegion: true,

        child: Text(

          sala.eu.venceu ? 'Você acertou!' : 'Você não acertou.',

          style: TextStyle(

            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: sala.eu.venceu ? estilo.acerto : estilo.vermelha,

          ),

        ),

      ),

    );

  }


  // Fim da rodada: a palavra e o botão da próxima
  List<Widget> construir_resultado() {

    return [

      if (sala.eu.terminou) construir_meu_resultado(),

      Text('A palavra era ${sala.palavra.toUpperCase()}.', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),

      const SizedBox(height: 16),

      if (sala.sou_espectador)

        const Text('Esperando um jogador passar para a próxima rodada.')

      else

        FilledButton(

        onPressed: executando ? null : () => executar(() => online.proxima_rodada(perfil, sala.codigo, sala.rodada)),
        child: const Text('Próxima rodada'),

      ),

    ];

  }

}
