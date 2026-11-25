import 'armazenamento.dart';
import 'repositorio_palavras.dart';
import 'repositorio_placar.dart';


class DadosAplicativo {

  final RepositorioPalavras palavras;
  final RepositorioPlacar placares;


  DadosAplicativo(Armazenamento armazenamento)
      : palavras = RepositorioPalavras(armazenamento),
        placares = RepositorioPlacar(armazenamento);


  Future<void> carregar() async {

    await palavras.carregar();
    await placares.carregar();

  }

}
