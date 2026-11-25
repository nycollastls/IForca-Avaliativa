import 'package:forca/services/armazenamento.dart';


class ArmazenamentoMemoria implements Armazenamento {

  final Map<String, String> arquivos = {};


  @override
  Future<String?> ler(String nome_arquivo) async {

    return arquivos[nome_arquivo];

  }


  @override
  Future<void> gravar(String nome_arquivo, String conteudo) async {

    arquivos[nome_arquivo] = conteudo;

  }

}
