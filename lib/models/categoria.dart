// Categorias de palavras e o arquivo JSON de cada uma
enum Categoria {

  c('C', 'assets/palavras/c.json'),
  dart('Dart', 'assets/palavras/dart.json'),
  logica('Lógica', 'assets/palavras/logica.json');


  final String nome;
  final String caminho_arquivo;


  const Categoria(this.nome, this.caminho_arquivo);

}
