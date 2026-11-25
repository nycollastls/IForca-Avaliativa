// Níveis de dificuldade e quantos pontos cada um vale
enum Nivel {

  facil('Fácil', 30),
  medio('Médio', 40),
  dificil('Difícil', 50);


  final String nome;
  final int pontos_base;


  const Nivel(this.nome, this.pontos_base);

}
