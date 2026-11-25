enum Linguagem {

  c('C', 'assets/palavras/c.json'),
  dart('Dart', 'assets/palavras/dart.json');


  final String nome;
  final String caminho_arquivo;


  const Linguagem(this.nome, this.caminho_arquivo);

}
