import 'dart:convert';
import 'dart:io';

import 'sala.dart';


const int maximo_partidas = 300;
const int tamanho_lista = 20;
const String nome_oculto = 'Anônimo';


class JogadorPartida {

  final String id;
  final String nome;
  final int pontos;

  bool mostrar_nome;


  JogadorPartida({

    required this.id,
    required this.nome,
    required this.pontos,
    required this.mostrar_nome,

  });


  factory JogadorPartida.de_json(Map<String, dynamic> dados) {

    return JogadorPartida(

      id: dados['id'] as String,
      nome: dados['nome'] as String,
      pontos: dados['pontos'] as int,
      mostrar_nome: dados['mostrar_nome'] as bool,

    );

  }


  Map<String, dynamic> para_json() {

    return {'id': id, 'nome': nome, 'pontos': pontos, 'mostrar_nome': mostrar_nome};

  }

}


class Partida {

  final String id;
  final int inicio;
  final int atualizada;
  final int rodadas;
  final List<JogadorPartida> jogadores;


  const Partida({

    required this.id,
    required this.inicio,
    required this.atualizada,
    required this.rodadas,
    required this.jogadores,

  });


  factory Partida.de_sala(Sala sala, DateTime agora) {

    List<JogadorPartida> jogadores = [

      for (Jogador jogador in sala.historico.values)

        if (jogador.jogou)

          JogadorPartida(

            id: jogador.id,
            nome: jogador.nome,
            pontos: jogador.pontos,
            mostrar_nome: jogador.mostrar_nome,

          ),

    ];

    jogadores.sort((primeiro, segundo) => segundo.pontos.compareTo(primeiro.pontos));

    return Partida(

      id: sala.id_partida,
      inicio: sala.criada_em.millisecondsSinceEpoch,
      atualizada: agora.millisecondsSinceEpoch,
      rodadas: sala.rodadas_concluidas,
      jogadores: jogadores,

    );

  }


  factory Partida.de_json(Map<String, dynamic> dados) {

    return Partida(

      id: dados['id'] as String,
      inicio: dados['inicio'] as int,
      atualizada: dados['atualizada'] as int,
      rodadas: dados['rodadas'] as int,

      jogadores: [

        for (dynamic item in dados['jogadores'] as List<dynamic>)

          JogadorPartida.de_json(item as Map<String, dynamic>),

      ],

    );

  }


  int get maior_pontuacao => jogadores.isEmpty ? 0 : jogadores.first.pontos;


  Map<String, dynamic> para_json() {

    return {

      'id': id,
      'inicio': inicio,
      'atualizada': atualizada,
      'rodadas': rodadas,
      'jogadores': [for (JogadorPartida jogador in jogadores) jogador.para_json()],

    };

  }


  Map<String, dynamic> montar_visao(String id_visitante, bool em_andamento) {

    return {

      'inicio': inicio,
      'rodadas': rodadas,
      'em_andamento': em_andamento,

      'jogadores': [

        for (JogadorPartida jogador in jogadores)

          {

            'nome': jogador.mostrar_nome ? jogador.nome : nome_oculto,
            'pontos': jogador.pontos,
            'sou_eu': jogador.id == id_visitante,

          },

      ],

    };

  }

}


class Leaderboard {

  final File? arquivo;
  final List<Partida> partidas = [];

  Future<void> fila_gravacao = Future.value();


  Leaderboard({this.arquivo});


  Future<void> carregar() async {

    File? arquivo_dados = arquivo;

    if (arquivo_dados == null || !await arquivo_dados.exists()) {

      return;

    }

    try {

      List<dynamic> itens = jsonDecode(await arquivo_dados.readAsString()) as List<dynamic>;

      for (dynamic item in itens) {

        partidas.add(Partida.de_json(item as Map<String, dynamic>));

      }

    } on Object {

      partidas.clear();

    }

  }


  void registrar(Sala sala, DateTime agora) {

    partidas.removeWhere((partida) => partida.id == sala.id_partida);
    partidas.add(Partida.de_sala(sala, agora));

    if (partidas.length > maximo_partidas) {

      partidas.removeAt(0);

    }

    gravar();

  }


  void mudar_nome(String id, bool mostrar) {

    for (Partida partida in partidas) {

      for (JogadorPartida jogador in partida.jogadores) {

        if (jogador.id == id) {

          jogador.mostrar_nome = mostrar;

        }

      }

    }

    gravar();

  }


  List<Map<String, dynamic>> listar(String id, bool por_pontos, Set<String> abertas) {

    List<Partida> ordenadas = [...partidas];

    ordenadas.sort((primeira, segunda) {

      int diferenca = por_pontos ? segunda.maior_pontuacao.compareTo(primeira.maior_pontuacao) : 0;

      return diferenca != 0 ? diferenca : segunda.atualizada.compareTo(primeira.atualizada);

    });

    return [

      for (Partida partida in ordenadas.take(tamanho_lista))

        partida.montar_visao(id, abertas.contains(partida.id)),

    ];

  }


  void gravar() {

    File? arquivo_dados = arquivo;

    if (arquivo_dados == null) {

      return;

    }

    String conteudo = jsonEncode([for (Partida partida in partidas) partida.para_json()]);

    fila_gravacao = fila_gravacao.then((_) async {

      try {

        await arquivo_dados.parent.create(recursive: true);
        await arquivo_dados.writeAsString(conteudo);

      } on FileSystemException catch (erro) {

        stderr.writeln('Falha ao gravar o leaderboard: ${erro.message}');

      }

    });

  }

}
