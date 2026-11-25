// Opções de tamanho do texto e o quanto cada uma aumenta
enum TamanhoTexto {

  normal('Normal', 1),
  grande('Grande', 1.2),
  muito_grande('Muito grande', 1.4);


  final String nome;
  final double fator;


  const TamanhoTexto(this.nome, this.fator);

}
