import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:forca/services/armazenamento_arquivo.dart';


void main() {

  test('grava e lê um arquivo JSON no disco', () async {

    Directory pasta_teste = await Directory.systemTemp.createTemp('forca_teste');

    addTearDown(() => pasta_teste.delete(recursive: true));

    ArmazenamentoLocal primeiro = ArmazenamentoLocal(pasta: Directory('${pasta_teste.path}/dados'));

    expect(await primeiro.ler('placar.json'), isNull);

    await primeiro.gravar('placar.json', '{"pontos": 30}');

    ArmazenamentoLocal segundo = ArmazenamentoLocal(pasta: Directory('${pasta_teste.path}/dados'));

    expect(await segundo.ler('placar.json'), '{"pontos": 30}');

  });

}
