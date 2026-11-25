import 'categoria.dart';
import 'nivel.dart';


class Palavra {

  final String texto;
  final String dica;
  final Categoria categoria;
  final Nivel nivel;


  const Palavra({

    required this.texto,
    required this.dica,
    required this.categoria,
    required this.nivel,

  });


  factory Palavra.de_json(Map<String, dynamic> dados) {

    return Palavra(

      texto: dados['texto'] as String,
      dica: dados['dica'] as String,
      categoria: Categoria.values.byName(dados['categoria'] as String),
      nivel: Nivel.values.byName(dados['nivel'] as String),

    );

  }


  Map<String, dynamic> para_json() {

    return {

      'texto': texto,
      'dica': dica,
      'categoria': categoria.name,
      'nivel': nivel.name,

    };

  }

}
