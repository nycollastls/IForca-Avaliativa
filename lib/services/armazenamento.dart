abstract interface class Armazenamento {

  Future<String?> ler(String nome_arquivo);

  Future<void> gravar(String nome_arquivo, String conteudo);

}
