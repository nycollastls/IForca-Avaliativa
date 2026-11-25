import 'palavra.dart';


// Resultado de uma partida que acabou
class Resultado {

  final Palavra palavra;
  final bool venceu;
  final int pontos;


  const Resultado({

    required this.palavra,
    required this.venceu,
    required this.pontos,

  });

}
