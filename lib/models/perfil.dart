import 'dart:math';

import 'tamanho_texto.dart';


// Dados do jogador neste aparelho: nome e preferências de acessibilidade
class Perfil {

  final String id;

  String nome;
  bool aparecer_leaderboard;

  TamanhoTexto tamanho_texto;
  bool alto_contraste;
  bool letras_espacadas;
  bool reduzir_animacoes;
  bool teclado_alfabetico;
  bool marcas_teclado;


  Perfil({

    required this.id,
    this.nome = '',
    this.aparecer_leaderboard = true,
    this.tamanho_texto = TamanhoTexto.normal,
    this.alto_contraste = false,
    this.letras_espacadas = false,
    this.reduzir_animacoes = false,
    this.teclado_alfabetico = false,
    this.marcas_teclado = false,

  });


  // Cria um perfil novo com uma identificação aleatória
  factory Perfil.novo() {

    Random sorteador = Random.secure();
    String id_novo = '';

    for (int indice = 0; indice < 32; indice++) {

      id_novo += sorteador.nextInt(16).toRadixString(16);

    }

    return Perfil(id: id_novo);

  }


  // Lê o perfil salvo; campos que faltam ficam com o valor padrão
  factory Perfil.de_json(Map<String, dynamic> dados) {

    String nome_tamanho = dados['tamanho_texto'] as String? ?? TamanhoTexto.normal.name;

    return Perfil(

      id: dados['id'] as String,
      nome: dados['nome'] as String,
      aparecer_leaderboard: dados['aparecer_leaderboard'] as bool? ?? true,
      tamanho_texto: TamanhoTexto.values.asNameMap()[nome_tamanho] ?? TamanhoTexto.normal,
      alto_contraste: dados['alto_contraste'] as bool? ?? false,
      letras_espacadas: dados['letras_espacadas'] as bool? ?? false,
      reduzir_animacoes: dados['reduzir_animacoes'] as bool? ?? false,
      teclado_alfabetico: dados['teclado_alfabetico'] as bool? ?? false,
      marcas_teclado: dados['marcas_teclado'] as bool? ?? false,

    );

  }


  // Transforma o perfil em mapa para salvar em JSON
  Map<String, dynamic> para_json() {

    return {

      'id': id,
      'nome': nome,
      'aparecer_leaderboard': aparecer_leaderboard,
      'tamanho_texto': tamanho_texto.name,
      'alto_contraste': alto_contraste,
      'letras_espacadas': letras_espacadas,
      'reduzir_animacoes': reduzir_animacoes,
      'teclado_alfabetico': teclado_alfabetico,
      'marcas_teclado': marcas_teclado,

    };

  }

}
