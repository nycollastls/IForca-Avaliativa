class JogoForca {

  final String palavra_secreta;
  final int maximo_erros;

  final Set<String> letras_certas = {};
  final Set<String> letras_erradas = {};


  JogoForca({required String palavra, this.maximo_erros = 6}) : palavra_secreta = palavra.toUpperCase();


  int get quantidade_erros => letras_erradas.length;

  bool get venceu => palavra_secreta.split('').every(letras_certas.contains);

  bool get perdeu => quantidade_erros >= maximo_erros;

  bool get encerrado => venceu || perdeu;


  String get palavra_exibida {

    List<String> letras_exibidas = palavra_secreta.split('').map((letra) {

      if (letras_certas.contains(letra) || perdeu) {

        return letra;

      }

      return '_';

    }).toList();

    return letras_exibidas.join(' ');

  }


  bool letra_ja_usada(String letra) {

    return letras_certas.contains(letra) || letras_erradas.contains(letra);

  }


  void tentar_letra(String letra) {

    String letra_normalizada = letra.toUpperCase();

    if (encerrado || letra_ja_usada(letra_normalizada)) {

      return;

    }

    if (palavra_secreta.contains(letra_normalizada)) {

      letras_certas.add(letra_normalizada);

    } else {

      letras_erradas.add(letra_normalizada);

    }

  }

}
