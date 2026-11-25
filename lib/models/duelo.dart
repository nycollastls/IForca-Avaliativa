class Duelo {

  final List<String> nomes;
  final List<int> pontos;

  int indice_desafiante;


  Duelo({

    required this.nomes,
    List<int>? pontos,
    this.indice_desafiante = 0,

  }) : pontos = pontos ?? [0, 0];


  int get indice_adivinhador => 1 - indice_desafiante;

  String get nome_desafiante => nomes[indice_desafiante];

  String get nome_adivinhador => nomes[indice_adivinhador];


  factory Duelo.de_json(Map<String, dynamic> dados) {

    List<String> nomes_lidos = List<String>.from(dados['nomes']);
    List<int> pontos_lidos = List<int>.from(dados['pontos']);
    int indice_lido = dados['indice_desafiante'] as int;

    if (nomes_lidos.length != 2 || pontos_lidos.length != 2 || indice_lido < 0 || indice_lido > 1) {

      throw const FormatException('Duelo salvo com dados inválidos');

    }

    return Duelo(

      nomes: nomes_lidos,
      pontos: pontos_lidos,
      indice_desafiante: indice_lido,

    );

  }


  Map<String, dynamic> para_json() {

    return {

      'nomes': nomes,
      'pontos': pontos,
      'indice_desafiante': indice_desafiante,

    };

  }

}
