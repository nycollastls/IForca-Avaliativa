// Etapas de uma rodada do desafio multiplayer
enum FaseSala { espera, escrevendo, jogando, resultado }


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


  const JogadorSala({

    required this.numero,
    required this.nome,
    required this.pontos,
    required this.pontos_rodada,
    required this.ausente,
    required this.participa,
    required this.terminou,
    required this.venceu,

  });


  // Lê o jogador que veio do servidor
  factory JogadorSala.de_json(Map<String, dynamic> dados) {

    return JogadorSala(

      numero: dados['numero'] as int,
      nome: dados['nome'] as String,
      pontos: dados['pontos'] as int,
      pontos_rodada: dados['pontos_rodada'] as int,
      ausente: dados['ausente'] as bool,
      participa: dados['participa'] as bool,
      terminou: dados['terminou'] as bool,
      venceu: dados['venceu'] as bool,

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

  int get total_presentes => jogadores.where((jogador) => !jogador.ausente).length;


  String get nome_desafiante {

    for (JogadorSala jogador in jogadores) {

      if (jogador.numero == numero_desafiante) {

        return jogador.nome;

      }

    }

    return 'Quem saiu da sala';

  }

}
