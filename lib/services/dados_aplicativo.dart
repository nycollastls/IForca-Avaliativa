import 'armazenamento.dart';
import 'cliente_http.dart';
import 'repositorio_palavras.dart';
import 'repositorio_perfil.dart';
import 'repositorio_placar.dart';
import 'servico_online.dart';


// Junta tudo o que o app guarda e acessa
class DadosAplicativo {

  final RepositorioPalavras palavras;
  final RepositorioPlacar placares;
  final RepositorioPerfil perfis;
  final ServicoOnline online;


  DadosAplicativo(Armazenamento armazenamento, ClienteHttp cliente)
      : palavras = RepositorioPalavras(armazenamento),
        placares = RepositorioPlacar(armazenamento),
        perfis = RepositorioPerfil(armazenamento),
        online = ServicoOnline(cliente);


  // Carrega palavras, placar e perfil
  Future<void> carregar() async {

    await palavras.carregar();
    await placares.carregar();
    await perfis.carregar();

  }


  // Avisa o servidor se o nome deve aparecer no leaderboard
  Future<bool> mudar_nome_leaderboard() async {

    try {

      await online.mudar_nome(perfis.perfil);

      return true;

    } on ErroServidor {

      return false;

    }

  }

}
