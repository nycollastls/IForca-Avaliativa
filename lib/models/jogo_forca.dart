import '../services/texto.dart';
import 'palavra.dart';


// Estado de uma partida: palavra, letras tentadas, erros e dica
class JogoForca {

  final Palavra palavra;
  final String palavra_secreta;
  final int maximo_erros;

  final Set<String> letras_certas = {};
  final Set<String> letras_erradas = {};

  bool dica_usada = false;


  JogoForca({required this.palavra, this.maximo_erros = 6}) : palavra_secreta = palavra.texto.trim().toUpperCase();


  Set<String> get letras_tentadas => letras_certas.union(letras_erradas);

  int get quantidade_erros => letras_erradas.length;

  bool get venceu => palavra_secreta.split('').every(letra_revelada);

  bool get perdeu => quantidade_erros >= maximo_erros;

  bool get encerrado => venceu || perdeu;

  String get palavra_exibida => letras_exibidas.join(' ');


  List<String> get letras_exibidas {

    List<String> letras = [];

    for (String letra in palavra_secreta.split('')) {

      letras.add(letra_revelada(letra) || perdeu ? letra : '_');

    }

    return letras;

  }


  // Diz se a letra já aparece na palavra; espaço e hífen já começam revelados
  bool letra_revelada(String letra) {

    return !eh_letra(letra) || letras_certas.contains(normalizar_texto(letra));

  }


  // Diz se a letra já foi tentada, com ou sem acento
  bool letra_ja_usada(String letra) {

    return letras_tentadas.contains(normalizar_texto(letra));

  }


  // Regra principal do jogo: guarda a letra como acerto ou como erro
  void tentar_letra(String letra) {

    String letra_normalizada = normalizar_texto(letra);

    if (encerrado || !eh_letra(letra) || letra_ja_usada(letra)) {

      return;

    }

    if (normalizar_texto(palavra_secreta).contains(letra_normalizada)) {

      letras_certas.add(letra_normalizada);

    } else {

      letras_erradas.add(letra_normalizada);

    }

  }


  // Marca que a dica foi usada, o que desconta pontos no final
  void usar_dica() {

    if (!encerrado) {

      dica_usada = true;

    }

  }

}
