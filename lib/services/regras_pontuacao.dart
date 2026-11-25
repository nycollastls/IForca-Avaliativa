import '../models/jogo_forca.dart';
import '../models/placar.dart';
import '../models/resultado.dart';


const int custo_dica = 10;
const int desconto_por_erro = 3;
const int pontos_minimos = 5;


int calcular_pontos_vitoria(JogoForca jogo) {

  int pontos = jogo.palavra.nivel.pontos_base - jogo.quantidade_erros * desconto_por_erro;

  if (jogo.dica_usada) {

    pontos -= custo_dica;

  }

  return pontos < pontos_minimos ? pontos_minimos : pontos;

}


Resultado gerar_resultado(JogoForca jogo) {

  int pontos = 0;

  if (jogo.venceu) {

    pontos = calcular_pontos_vitoria(jogo);

  } else if (jogo.dica_usada) {

    pontos = -custo_dica;

  }

  return Resultado(palavra: jogo.palavra, venceu: jogo.venceu, pontos: pontos);

}


int somar_pontos(int pontos_atuais, int pontos_ganhos) {

  int total = pontos_atuais + pontos_ganhos;

  return total < 0 ? 0 : total;

}


void aplicar_resultado(Placar placar, Resultado resultado) {

  placar.pontos = somar_pontos(placar.pontos, resultado.pontos);

  if (!resultado.venceu) {

    placar.derrotas++;
    placar.sequencia_atual = 0;

    return;

  }

  int linha = resultado.palavra.categoria.index;
  int coluna = resultado.palavra.nivel.index;

  placar.vitorias++;
  placar.sequencia_atual++;
  placar.matriz_vitorias[linha][coluna]++;

  if (placar.sequencia_atual > placar.melhor_sequencia) {

    placar.melhor_sequencia = placar.sequencia_atual;

  }

}
