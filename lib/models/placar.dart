import 'categoria.dart';
import 'nivel.dart';


class Placar {

  int pontos;
  int vitorias;
  int derrotas;
  int sequencia_atual;
  int melhor_sequencia;

  final List<List<int>> matriz_vitorias;


  Placar({

    this.pontos = 0,
    this.vitorias = 0,
    this.derrotas = 0,
    this.sequencia_atual = 0,
    this.melhor_sequencia = 0,
    List<List<int>>? matriz_vitorias,

  }) : matriz_vitorias = matriz_vitorias ?? criar_matriz_vazia();


  static List<List<int>> criar_matriz_vazia() {

    return [

      for (int linha = 0; linha < Categoria.values.length; linha++)

        List.filled(Nivel.values.length, 0),

    ];

  }


  factory Placar.de_json(Map<String, dynamic> dados) {

    List<List<int>> matriz_lida = criar_matriz_vazia();
    List<dynamic> linhas_salvas = dados['matriz_vitorias'] as List<dynamic>;

    for (int linha = 0; linha < matriz_lida.length; linha++) {

      for (int coluna = 0; coluna < matriz_lida[linha].length; coluna++) {

        matriz_lida[linha][coluna] = linhas_salvas[linha][coluna] as int;

      }

    }

    return Placar(

      pontos: dados['pontos'] as int,
      vitorias: dados['vitorias'] as int,
      derrotas: dados['derrotas'] as int,
      sequencia_atual: dados['sequencia_atual'] as int,
      melhor_sequencia: dados['melhor_sequencia'] as int,
      matriz_vitorias: matriz_lida,

    );

  }


  Map<String, dynamic> para_json() {

    return {

      'pontos': pontos,
      'vitorias': vitorias,
      'derrotas': derrotas,
      'sequencia_atual': sequencia_atual,
      'melhor_sequencia': melhor_sequencia,
      'matriz_vitorias': matriz_vitorias,

    };

  }

}
