import 'dart:async';
import 'dart:io';

import 'aplicacao.dart';
import 'leaderboard.dart';


// Liga o servidor na porta do Render e carrega o leaderboard
Future<void> main() async {

  Map<String, String> ambiente = Platform.environment;
  int porta = int.tryParse(ambiente['PORT'] ?? '') ?? 8124;
  String pasta_dados = ambiente['PASTA_DADOS'] ?? '${Directory.systemTemp.path}/forca_servidor';

  Leaderboard leaderboard = Leaderboard(arquivo: File('$pasta_dados/partidas.json'));

  await leaderboard.carregar();

  Aplicacao aplicacao = Aplicacao(leaderboard: leaderboard);
  HttpServer servidor = await HttpServer.bind(InternetAddress.anyIPv4, porta);

  stdout.writeln('Servidor da forca na porta $porta');

  await for (HttpRequest requisicao in servidor) {

    unawaited(aplicacao.atender(requisicao));

  }

}
