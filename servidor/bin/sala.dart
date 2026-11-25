import 'validacao.dart';


// Regras da sala
const int minimo_jogadores = 2;
const int maximo_jogadores = 6;
const int pontos_maximos_rodada = 40;
const int desconto_maximo_rodada = 10;

const Duration tempo_ausencia = Duration(seconds: 25);
const Duration tempo_remocao = Duration(minutes: 10);


// Etapas de uma rodada
enum Fase { espera, escrevendo, jogando, resultado }


// Jogador dentro de uma sala
class Jogador {

  final String id;
  final int numero;

  String nome;
  bool mostrar_nome;
  DateTime visto_em;
  int pontos = 0;
  bool jogou = false;

  bool participa = false;
  bool terminou = false;
  bool venceu = false;
  int pontos_rodada = 0;


  Jogador({

    required this.id,
    required this.numero,
    required this.nome,
    required this.mostrar_nome,
    required this.visto_em,

  });


  // Sem dar sinal há um tempo, o jogador conta como ausente
  bool esta_ausente(DateTime agora) => agora.difference(visto_em) > tempo_ausencia;


  // Limpa o que o jogador fez na rodada
  void limpar_rodada() {

    participa = false;
    terminou = false;
    venceu = false;
    pontos_rodada = 0;

  }

}


// Sala do desafio multiplayer
class Sala {

  final String codigo;
  final String id_partida;
  final bool publica;
  final DateTime criada_em;
  final List<Jogador> jogadores = [];
  final Map<String, Jogador> historico = {};

  Fase fase = Fase.espera;
  int rodada = 0;
  int rodadas_concluidas = 0;
  int rodadas_publicadas = 0;
  int numero_desafiante = 0;
  String palavra = '';
  String dica = '';

  int proximo_numero = 1;
  DateTime usada_em;


  Sala({

    required this.codigo,
    required this.id_partida,
    required this.publica,
    required this.criada_em,

  }) : usada_em = criada_em;


  // Acha o jogador pela identificação
  Jogador buscar_jogador(String id) {

    for (Jogador jogador in jogadores) {

      if (jogador.id == id) {

        return jogador;

      }

    }

    throw const ErroRegra(404, 'Você não está mais nesta sala.');

  }


  // Jogadores que ainda estão conectados
  List<Jogador> listar_presentes(DateTime agora) {

    return jogadores.where((jogador) => !jogador.esta_ausente(agora)).toList();

  }


  // Quem comanda a sala: o primeiro que está conectado
  Jogador escolher_anfitriao(DateTime agora) {

    List<Jogador> presentes = listar_presentes(agora);

    return presentes.isEmpty ? jogadores.first : presentes.first;

  }


  // Coloca o jogador na sala; quem volta recupera os pontos
  void entrar(String id, String nome, bool mostrar_nome, DateTime agora) {

    for (Jogador jogador in jogadores) {

      if (jogador.id == id) {

        jogador.nome = nome;
        jogador.mostrar_nome = mostrar_nome;
        jogador.visto_em = agora;

        return;

      }

    }

    if (jogadores.length >= maximo_jogadores) {

      throw const ErroRegra(409, 'Esta sala já tem $maximo_jogadores jogadores.');

    }

    Jogador? jogador_antigo = historico[id];

    if (jogador_antigo == null) {

      historico[id] = Jogador(

        id: id,
        numero: proximo_numero,
        nome: nome,
        mostrar_nome: mostrar_nome,
        visto_em: agora,

      );

      proximo_numero++;

    } else {

      jogador_antigo.limpar_rodada();
      jogador_antigo.nome = nome;
      jogador_antigo.mostrar_nome = mostrar_nome;
      jogador_antigo.visto_em = agora;

    }

    jogadores.add(historico[id]!);
    jogadores.sort((primeiro, segundo) => primeiro.numero.compareTo(segundo.numero));

  }


  // Tira o jogador da sala
  void sair(String id, DateTime agora) {

    jogadores.removeWhere((jogador) => jogador.id == id);

    atualizar(agora);

  }


  // Registra que o jogador ainda está na sala
  void marcar_presenca(String id, DateTime agora) {

    buscar_jogador(id).visto_em = agora;
    usada_em = agora;

    atualizar(agora);

  }


  // Tira quem sumiu e destrava a rodada quando preciso
  void atualizar(DateTime agora) {

    jogadores.removeWhere((jogador) => agora.difference(jogador.visto_em) > tempo_remocao);

    if (fase != Fase.espera && jogadores.length < minimo_jogadores) {

      voltar_para_espera();
      return;

    }

    if (fase == Fase.escrevendo) {

      trocar_desafiante_ausente(agora);

    }

    if (fase == Fase.jogando) {

      verificar_fim(agora);

    }

  }


  // Volta a sala para a espera
  void voltar_para_espera() {

    fase = Fase.espera;
    palavra = '';
    dica = '';

    limpar_rodada();

  }


  // Limpa a rodada de todos
  void limpar_rodada() {

    for (Jogador jogador in jogadores) {

      jogador.limpar_rodada();

    }

  }


  // Passa a vez se quem escreve perdeu a conexão
  void trocar_desafiante_ausente(DateTime agora) {

    List<Jogador> presentes = listar_presentes(agora);
    bool desafiante_presente = presentes.any((jogador) => jogador.numero == numero_desafiante);

    if (!desafiante_presente && presentes.isNotEmpty) {

      numero_desafiante = escolher_proximo(presentes);

    }

  }


  // Escolhe o próximo a escrever a palavra
  int escolher_proximo(List<Jogador> candidatos) {

    for (Jogador jogador in candidatos) {

      if (jogador.numero > numero_desafiante) {

        return jogador.numero;

      }

    }

    return candidatos.first.numero;

  }


  // Exige pelo menos dois jogadores conectados
  void exigir_jogadores(DateTime agora) {

    if (listar_presentes(agora).length < minimo_jogadores) {

      throw const ErroRegra(409, 'É preciso ter pelo menos $minimo_jogadores jogadores na sala.');

    }

  }


  // Começa o desafio
  void iniciar(String id, DateTime agora) {

    if (fase != Fase.espera) {

      return;

    }

    if (escolher_anfitriao(agora).id != id) {

      throw const ErroRegra(403, 'Só quem criou a sala pode começar.');

    }

    exigir_jogadores(agora);
    abrir_rodada(agora);

  }


  // Abre uma rodada nova
  void abrir_rodada(DateTime agora) {

    limpar_rodada();

    numero_desafiante = escolher_proximo(listar_presentes(agora));
    palavra = '';
    dica = '';
    rodada++;
    fase = Fase.escrevendo;

  }


  // Recebe a palavra secreta e começa a rodada
  void definir_palavra(String id, String palavra_nova, String dica_nova, DateTime agora) {

    bool sou_desafiante = buscar_jogador(id).numero == numero_desafiante;
    bool pedido_repetido = fase == Fase.jogando && palavra == palavra_nova && dica == dica_nova;

    if (sou_desafiante && pedido_repetido) {

      return;

    }

    if (fase != Fase.escrevendo || !sou_desafiante) {

      throw const ErroRegra(409, 'Agora não é a sua vez de escrever.');

    }

    exigir_jogadores(agora);

    palavra = palavra_nova;
    dica = dica_nova;
    fase = Fase.jogando;

    for (Jogador jogador in listar_presentes(agora)) {

      jogador.participa = jogador.numero != numero_desafiante;

    }

  }


  // Registra o resultado de quem adivinhou, com limite de pontos
  void registrar_resultado(String id, int rodada_jogada, bool venceu, int pontos, DateTime agora) {

    Jogador jogador = buscar_jogador(id);
    bool pode_registrar = fase == Fase.jogando && rodada == rodada_jogada;

    if (!pode_registrar || !jogador.participa || jogador.terminou) {

      return;

    }

    int maximo = venceu ? pontos_maximos_rodada : 0;
    int pontos_validos = pontos.clamp(-desconto_maximo_rodada, maximo);
    int pontos_anteriores = jogador.pontos;

    jogador.jogou = true;
    jogador.terminou = true;
    jogador.venceu = venceu;
    jogador.pontos = (pontos_anteriores + pontos_validos).clamp(0, 1 << 30);
    jogador.pontos_rodada = jogador.pontos - pontos_anteriores;

    verificar_fim(agora);

  }


  // Termina a rodada quando ninguém mais está jogando
  void verificar_fim(DateTime agora) {

    bool alguem_jogando = jogadores.any(

      (jogador) => jogador.participa && !jogador.terminou && !jogador.esta_ausente(agora),

    );

    if (!alguem_jogando) {

      concluir_rodada();

    }

  }


  // Fecha a rodada e conta para o leaderboard
  void concluir_rodada() {

    fase = Fase.resultado;

    bool alguem_terminou = jogadores.any((jogador) => jogador.terminou);

    if (!alguem_terminou) {

      return;

    }

    rodadas_concluidas++;

    for (Jogador jogador in jogadores) {

      if (jogador.numero == numero_desafiante) {

        jogador.jogou = true;

      }

    }

  }


  // Encerra a rodada antes de todos terminarem
  void encerrar_rodada(String id, int rodada_atual, DateTime agora) {

    Jogador jogador = buscar_jogador(id);

    if (fase != Fase.jogando || rodada != rodada_atual) {

      return;

    }

    if (jogador.numero != numero_desafiante && escolher_anfitriao(agora).id != id) {

      throw const ErroRegra(403, 'Só quem escreveu a palavra ou criou a sala pode encerrar.');

    }

    concluir_rodada();

  }


  // Passa para a próxima rodada
  void proxima_rodada(String id, int rodada_atual, DateTime agora) {

    buscar_jogador(id);

    if (fase != Fase.resultado || rodada != rodada_atual) {

      return;

    }

    exigir_jogadores(agora);
    abrir_rodada(agora);

  }


  // O que cada jogador pode ver da sala
  Map<String, dynamic> montar_visao(String id, DateTime agora) {

    Jogador eu = buscar_jogador(id);
    bool mostrar_palavra = fase == Fase.resultado || (fase == Fase.jogando && (eu.participa || eu.numero == numero_desafiante));

    return {

      'codigo': codigo,
      'publica': publica,
      'fase': fase.name,
      'rodada': rodada,
      'numero_desafiante': numero_desafiante,
      'meu_numero': eu.numero,
      'numero_anfitriao': escolher_anfitriao(agora).numero,
      'palavra': mostrar_palavra ? palavra : '',
      'dica': mostrar_palavra ? dica : '',

      'jogadores': [

        for (Jogador jogador in jogadores)

          {

            'numero': jogador.numero,
            'nome': jogador.nome,
            'pontos': jogador.pontos,
            'ausente': jogador.esta_ausente(agora),
            'participa': jogador.participa,
            'terminou': jogador.terminou,
            'venceu': jogador.venceu,
            'pontos_rodada': jogador.pontos_rodada,

          },

      ],

    };

  }

}
