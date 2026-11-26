// Etapas de uma rodada do desafio multiplayer
enum FaseSala { espera, escrevendo, jogando, resultado }


// Andamento de quem está adivinhando, para quem está assistindo
class ProgressoJogador {

  final List<String> mascara;
  final List<String> erradas;
  final bool dica_usada;


  const ProgressoJogador({required this.mascara, required this.erradas, required this.dica_usada});


  // Lê o andamento que veio do servidor
  factory ProgressoJogador.de_json(Map<String, dynamic> dados) {

    return ProgressoJogador(

      mascara: [for (dynamic letra in dados['mascara'] as List<dynamic>) letra as String],
      erradas: [for (dynamic letra in dados['erradas'] as List<dynamic>) letra as String],
      dica_usada: dados['dica_usada'] as bool,

    );

  }


  int get quantidade_erros => erradas.length;

}


// Jogador da sala do jeito que o servidor manda
class JogadorSala {

  final int numero;
  final String nome;
  final int pontos;
  final int pontos_rodada;
  final bool ausente;
  final bool participa;
  final bool terminou;
  final bool venceu;
  final bool espectador;
  final ProgressoJogador? progresso;


  const JogadorSala({

    required this.numero,
    required this.nome,
    required this.pontos,
    required this.pontos_rodada,
    required this.ausente,
    required this.participa,
    required this.terminou,
    required this.venceu,
    this.espectador = false,
    this.progresso,

  });


  // Lê o jogador que veio do servidor
  factory JogadorSala.de_json(Map<String, dynamic> dados) {

    Object? progresso = dados['progresso'];

    return JogadorSala(

      numero: dados['numero'] as int,
      nome: dados['nome'] as String,
      pontos: dados['pontos'] as int,
      pontos_rodada: dados['pontos_rodada'] as int,
      ausente: dados['ausente'] as bool,
      participa: dados['participa'] as bool,
      terminou: dados['terminou'] as bool,
      venceu: dados['venceu'] as bool,
      espectador: dados['espectador'] == true,
      progresso: progresso is Map<String, dynamic> ? ProgressoJogador.de_json(progresso) : null,

    );

  }

}


// Situação da sala multiplayer vista por este jogador
class SalaDesafio {

  final String codigo;
  final bool publica;
  final FaseSala fase;
  final int rodada;
  final int numero_desafiante;
  final int meu_numero;
  final int numero_anfitriao;
  final String palavra;
  final String dica;
  final List<JogadorSala> jogadores;


  const SalaDesafio({

    required this.codigo,
    required this.publica,
    required this.fase,
    required this.rodada,
    required this.numero_desafiante,
    required this.meu_numero,
    required this.numero_anfitriao,
    required this.palavra,
    required this.dica,
    required this.jogadores,

  });


  // Lê a sala que veio do servidor
  factory SalaDesafio.de_json(Map<String, dynamic> dados) {

    List<dynamic> lista_jogadores = dados['jogadores'] as List<dynamic>;

    return SalaDesafio(

      codigo: dados['codigo'] as String,
      publica: dados['publica'] as bool,
      fase: FaseSala.values.byName(dados['fase'] as String),
      rodada: dados['rodada'] as int,
      numero_desafiante: dados['numero_desafiante'] as int,
      meu_numero: dados['meu_numero'] as int,
      numero_anfitriao: dados['numero_anfitriao'] as int,
      palavra: dados['palavra'] as String,
      dica: dados['dica'] as String,

      jogadores: [

        for (dynamic item in lista_jogadores)

          JogadorSala.de_json(item as Map<String, dynamic>),

      ],

    );

  }


  bool get sou_desafiante => meu_numero == numero_desafiante;

  bool get sou_anfitriao => meu_numero == numero_anfitriao;

  JogadorSala get eu => jogadores.firstWhere((jogador) => jogador.numero == meu_numero);

  bool get sou_espectador => eu.espectador;

  int get total_presentes => jogadores.where((jogador) => !jogador.ausente && !jogador.espectador).length;

  List<JogadorSala> get adivinhando => jogadores.where((jogador) => jogador.participa && jogador.numero != meu_numero).toList();


  String get nome_desafiante {

    for (JogadorSala jogador in jogadores) {

      if (jogador.numero == numero_desafiante) {

        return jogador.nome;

      }

    }

    return 'Quem saiu da sala';

  }

}
