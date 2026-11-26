# Forca da Programação

Trabalho prático do 2º bimestre de Linguagem de Programação I (LPI), IFPA Campus Tucuruí.
Professor: Prof. Me. Alex Santos de Oliveira. Tema 5.

## O que é

A Forca da Programação é um jogo da forca feito em Flutter para treinar o vocabulário de programação de um jeito divertido. Em vez de palavras aleatórias, as palavras são termos de C, de Dart e de lógica de programação, cada uma com uma dica para ajudar.

É possível jogar sozinho, em dupla passando o aparelho ou online com até 6 pessoas, cada uma no próprio aparelho. O jogo guarda as suas estatísticas, tem um leaderboard com as partidas públicas e opções de acessibilidade para quem precisa de mais contraste, letras maiores ou teclado em ordem alfabética.

## Jogar agora

https://iforca-avaliativa.onrender.com

## Funcionalidades

- Três categorias de palavras: C, Dart e Lógica, com 15 palavras cada, vindas do jogo.
- Três níveis de dificuldade: fácil (30 pontos), médio (40) e difícil (50). No modo solo dá para escolher um nível ou jogar com todos.
- Dica em cada palavra, que custa 10 pontos quando é usada.
- Cada partida permite até 6 erros, e a forca é desenhada aos poucos a cada letra errada.
- Pontuação: o nível dá os pontos base, cada erro desconta 3 e a vitória nunca vale menos que 5. A pontuação nunca fica negativa.
- Modo um aparelho, com duas opções:
  - jogar só, escolhendo categoria e nível, com sorteio sem repetir a palavra anterior;
  - dois jogadores no mesmo aparelho: um escreve a palavra e uma dica, o outro adivinha, e a cada rodada os dois trocam de papel. O placar do duelo fica salvo.
- Desafio multiplayer online: uma pessoa cria a sala e passa o código de 5 letras para os outros. Cabem de 2 a 6 pessoas. A cada rodada uma pessoa escreve a palavra e as outras tentam adivinhar cada uma no seu aparelho, e quem escreve muda a cada rodada. Quem cria a sala começa o desafio, e tanto ela quanto quem escreveu a palavra podem encerrar a rodada antes de todos terminarem.
- Leaderboard: ao criar a sala, dá para escolher mostrar a partida para todos. A lista tem as maiores pontuações e as partidas mais recentes. Quem quiser pode aparecer como Anônimo.
- Estatísticas: pontos, vitórias, derrotas, sequência atual e melhor sequência de acertos, além de uma tabela de vitórias por categoria e nível. Dá para zerar tudo.
- Cadastro de palavras: o jogador cria as próprias palavras com dica, categoria e nível, e pode excluir. O jogo confere se a palavra é válida, se já existe e se a dica não entrega a resposta.
- Aceita letras com acento (a letra A vale para Á, Ã e outras), e espaço e hífen já aparecem revelados.
- Dá para jogar pelo teclado da tela ou pelo teclado do computador.
- Acessibilidade: alto contraste, tamanho do texto (normal, grande e muito grande), espaçamento entre as letras, marcas de certo e errado no teclado sem depender da cor, teclado em ordem alfabética, redução de animações e descrições para leitores de tela.
- Funciona no navegador, no Windows e no Android. Os dados ficam salvos no próprio aparelho.

## Como rodar no computador

Precisa do Flutter instalado.

    flutter pub get
    flutter run -d edge

Para testar o desafio multiplayer no computador, rode o servidor em outro
terminal:

    dart servidor/bin/servidor.dart

Para rodar os testes:

    flutter test

## Pastas

- `lib/models`: classes do jogo, como Palavra, JogoForca e Placar
- `lib/screens`: telas do app
- `lib/services`: regras, validações, arquivos JSON e conexão com o servidor
- `lib/widgets`: partes reutilizadas das telas, como o desenho da forca e o
teclado
- `assets/palavras`: banco de palavras em JSON
- `servidor`: servidor do desafio multiplayer e do leaderboard
- `test`: testes automáticos

## Equipe

- Nycollas Teles
- Luiz Pinheiro
- Elias Bento 
- Jonathan Jaciel
