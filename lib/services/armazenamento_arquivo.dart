import 'dart:io';

import 'armazenamento.dart';


// Salva os JSON em arquivos no Android e no Windows
class ArmazenamentoLocal implements Armazenamento {

  final Directory pasta;


  ArmazenamentoLocal({Directory? pasta}) : pasta = pasta ?? escolher_pasta();


  // Escolhe a pasta do app em cada sistema
  static Directory escolher_pasta() {

    if (Platform.isAndroid) {

      return Directory('${Directory.systemTemp.parent.path}/files/forca');

    }

    Map<String, String> ambiente = Platform.environment;
    String? pasta_usuario = Platform.isWindows ? ambiente['APPDATA'] : ambiente['HOME'];

    return Directory('${pasta_usuario ?? Directory.systemTemp.path}/forca_da_programacao');

  }


  // Caminho do arquivo dentro da pasta
  File abrir_arquivo(String nome_arquivo) {

    return File('${pasta.path}/$nome_arquivo');

  }


  // Lê o arquivo; se não existir, devolve vazio
  @override
  Future<String?> ler(String nome_arquivo) async {

    File arquivo = abrir_arquivo(nome_arquivo);

    try {

      return await arquivo.exists() ? await arquivo.readAsString() : null;

    } on FileSystemException {

      return null;

    }

  }


  // Cria a pasta, se precisar, e grava o arquivo
  @override
  Future<void> gravar(String nome_arquivo, String conteudo) async {

    File arquivo = abrir_arquivo(nome_arquivo);

    await pasta.create(recursive: true);
    await arquivo.writeAsString(conteudo, flush: true);

  }

}
