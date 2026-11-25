// Jogador como aparece no leaderboard
class JogadorLeaderboard {

  final String nome;
  final int pontos;
  final bool sou_eu;


  const JogadorLeaderboard({required this.nome, required this.pontos, required this.sou_eu});


  // Lê o jogador que veio do servidor
  factory JogadorLeaderboard.de_json(Map<String, dynamic> dados) {

    return JogadorLeaderboard(

      nome: dados['nome'] as String,
      pontos: dados['pontos'] as int,
      sou_eu: dados['sou_eu'] as bool,

    );

  }

}


// Partida pública do leaderboard com seus jogadores
class PartidaLeaderboard {

  final DateTime inicio;
  final int rodadas;
  final bool em_andamento;
  final List<JogadorLeaderboard> jogadores;


  const PartidaLeaderboard({

    required this.inicio,
    required this.rodadas,
    required this.em_andamento,
    required this.jogadores,

  });


  // Lê a partida que veio do servidor
  factory PartidaLeaderboard.de_json(Map<String, dynamic> dados) {

    return PartidaLeaderboard(

      inicio: DateTime.fromMillisecondsSinceEpoch(dados['inicio'] as int),
      rodadas: dados['rodadas'] as int,
      em_andamento: dados['em_andamento'] as bool,

      jogadores: [

        for (dynamic item in dados['jogadores'] as List<dynamic>)

          JogadorLeaderboard.de_json(item as Map<String, dynamic>),

      ],

    );

  }


  String get data_formatada {

    String dia = inicio.day.toString().padLeft(2, '0');
    String mes = inicio.month.toString().padLeft(2, '0');
    String hora = inicio.hour.toString().padLeft(2, '0');
    String minuto = inicio.minute.toString().padLeft(2, '0');

    return '$dia/$mes às $hora:$minuto';

  }


  String get titulo {

    int maior_pontuacao = jogadores.isEmpty ? 0 : jogadores.first.pontos;

    List<String> lideres = [

      for (JogadorLeaderboard jogador in jogadores)

        if (jogador.pontos == maior_pontuacao) jogador.nome,

    ];

    if (maior_pontuacao == 0 || lideres.length > 1) {

      return em_andamento ? 'Empate por enquanto' : 'Empate';

    }

    return em_andamento ? '${lideres.single} está na frente' : '${lideres.single} venceu';

  }

}
