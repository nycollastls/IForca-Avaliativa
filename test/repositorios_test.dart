import 'package:flutter_test/flutter_test.dart';

import 'package:forca/models/categoria.dart';
import 'package:forca/models/nivel.dart';
import 'package:forca/models/palavra.dart';
import 'package:forca/models/resultado.dart';
import 'package:forca/models/tamanho_texto.dart';
import 'package:forca/services/dados_aplicativo.dart';
import 'package:forca/services/repositorio_palavras.dart';
import 'package:forca/services/repositorio_perfil.dart';
import 'package:forca/services/repositorio_placar.dart';
import 'package:forca/services/texto.dart';
import 'package:forca/services/validador.dart';

import 'armazenamento_memoria.dart';
import 'cliente_teste.dart';


const Palavra palavra_teste = Palavra(

  texto: 'herança',
  dica: 'Relação entre classe mãe e filha',
  categoria: Categoria.dart,
  nivel: Nivel.dificil,

);


Future<DadosAplicativo> abrir_dados(ArmazenamentoMemoria armazenamento) async {

  DadosAplicativo dados = DadosAplicativo(armazenamento, ClienteTeste());

  await dados.carregar();

  return dados;

}


void main() {

  TestWidgetsFlutterBinding.ensureInitialized();


  test('cada categoria tem 5 palavras por nível', () async {

    DadosAplicativo dados = await abrir_dados(ArmazenamentoMemoria());

    for (Categoria categoria in Categoria.values) {

      for (Nivel nivel in Nivel.values) {

        expect(dados.palavras.filtrar(categoria, nivel).length, 5);

      }

    }

  });


  test('palavras iniciais são válidas e não se repetem', () async {

    DadosAplicativo dados = await abrir_dados(ArmazenamentoMemoria());
    Set<String> textos = {};

    for (Palavra palavra in dados.palavras.todas) {

      expect(validar_texto(palavra.texto), isNull, reason: palavra.texto);
      expect(validar_dica(palavra.dica, palavra.texto), isNull, reason: palavra.texto);
      expect(textos.add(normalizar_texto(palavra.texto)), isTrue, reason: palavra.texto);

    }

  });


  test('palavra cadastrada continua salva ao reabrir', () async {

    ArmazenamentoMemoria armazenamento = ArmazenamentoMemoria();
    DadosAplicativo dados = await abrir_dados(armazenamento);

    await dados.palavras.adicionar(palavra_teste);

    DadosAplicativo dados_reabertos = await abrir_dados(armazenamento);
    Palavra palavra_salva = dados_reabertos.palavras.palavras_cadastradas.single;

    expect(palavra_salva.texto, 'herança');

    await dados_reabertos.palavras.remover(palavra_salva);

    DadosAplicativo dados_finais = await abrir_dados(armazenamento);

    expect(dados_finais.palavras.palavras_cadastradas, isEmpty);

  });


  test('placar e duelo continuam salvos ao reabrir', () async {

    ArmazenamentoMemoria armazenamento = ArmazenamentoMemoria();
    DadosAplicativo dados = await abrir_dados(armazenamento);
    Resultado vitoria = const Resultado(palavra: palavra_teste, venceu: true, pontos: 50);

    await dados.placares.registrar_partida(vitoria);
    await dados.placares.iniciar_duelo('Ana', 'Beto');
    await dados.placares.registrar_rodada(vitoria);

    DadosAplicativo dados_reabertos = await abrir_dados(armazenamento);

    expect(dados_reabertos.placares.placar.pontos, 50);
    expect(dados_reabertos.placares.placar.sequencia_atual, 1);
    expect(dados_reabertos.placares.placar.matriz_vitorias[Categoria.dart.index][Nivel.dificil.index], 1);
    expect(dados_reabertos.placares.duelo!.pontos, [0, 50]);
    expect(dados_reabertos.placares.duelo!.nome_desafiante, 'Beto');

    await dados_reabertos.placares.encerrar_duelo();

    DadosAplicativo dados_finais = await abrir_dados(armazenamento);

    expect(dados_finais.placares.duelo, isNull);

  });


  test('perfil continua salvo ao reabrir e mantém a identificação', () async {

    ArmazenamentoMemoria armazenamento = ArmazenamentoMemoria();
    DadosAplicativo dados = await abrir_dados(armazenamento);

    await dados.perfis.mudar_nome('  Ana   Maria ');
    await dados.perfis.alterar((perfil) {

      perfil.reduzir_animacoes = true;
      perfil.alto_contraste = true;
      perfil.tamanho_texto = TamanhoTexto.grande;

    });

    DadosAplicativo dados_reabertos = await abrir_dados(armazenamento);

    expect(dados_reabertos.perfis.perfil.nome, 'Ana Maria');
    expect(dados_reabertos.perfis.perfil.reduzir_animacoes, isTrue);
    expect(dados_reabertos.perfis.perfil.alto_contraste, isTrue);
    expect(dados_reabertos.perfis.perfil.tamanho_texto, TamanhoTexto.grande);
    expect(dados_reabertos.perfis.perfil.id, dados.perfis.perfil.id);
    expect(dados.perfis.perfil.id, matches(RegExp(r'^[0-9a-f]{32}$')));

  });


  test('perfil salvo por versão anterior continua valendo', () async {

    ArmazenamentoMemoria armazenamento = ArmazenamentoMemoria();

    armazenamento.arquivos[RepositorioPerfil.nome_arquivo] = '{"id": "abc", "nome": "Ana"}';

    DadosAplicativo dados = await abrir_dados(armazenamento);

    expect(dados.perfis.perfil.nome, 'Ana');
    expect(dados.perfis.perfil.tamanho_texto, TamanhoTexto.normal);

  });


  test('arquivos corrompidos não impedem o app de abrir', () async {

    ArmazenamentoMemoria armazenamento = ArmazenamentoMemoria();

    armazenamento.arquivos[RepositorioPalavras.nome_arquivo] = '[{"texto": 1}]';
    armazenamento.arquivos[RepositorioPlacar.arquivo_placar] = '{quebrado';
    armazenamento.arquivos[RepositorioPlacar.arquivo_duelo] = '{"nomes": ["Ana"]}';

    DadosAplicativo dados = await abrir_dados(armazenamento);

    expect(dados.palavras.palavras_cadastradas, isEmpty);
    expect(dados.placares.placar.pontos, 0);
    expect(dados.placares.duelo, isNull);

  });


  test('sorteio não repete a palavra anterior', () async {

    DadosAplicativo dados = await abrir_dados(ArmazenamentoMemoria());
    Palavra? anterior;

    for (int rodada = 0; rodada < 50; rodada++) {

      Palavra? sorteada = dados.palavras.sortear(Categoria.c, Nivel.facil, anterior: anterior);

      expect(sorteada, isNotNull);
      expect(sorteada, isNot(anterior));

      anterior = sorteada;

    }

  });

}
