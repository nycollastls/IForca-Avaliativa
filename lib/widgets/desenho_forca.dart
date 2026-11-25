import 'dart:math';

import 'package:flutter/material.dart';

import 'estilo_caderno.dart';


// Desenho da forca, que cresce a cada erro
class DesenhoForca extends StatelessWidget {

  final int quantidade_erros;
  final int maximo_erros;


  const DesenhoForca({super.key, required this.quantidade_erros, required this.maximo_erros});


  // Anima o desenho quando entra um erro novo
  @override
  Widget build(BuildContext context) {

    bool sem_animacao = MediaQuery.disableAnimationsOf(context);
    EstiloCaderno estilo = EstiloCaderno.de(context);

    return Semantics(

      label: 'Desenho da forca com $quantidade_erros de $maximo_erros erros',

      child: TweenAnimationBuilder<double>(

        tween: Tween(begin: 0, end: quantidade_erros.toDouble()),
        duration: sem_animacao ? Duration.zero : const Duration(milliseconds: 350),
        curve: Curves.easeOut,

        builder: (context, progresso, _) => CustomPaint(

          size: const Size(220, 220),
          painter: PintorForca(progresso, estilo),

        ),

      ),

    );

  }

}


// Desenha a forca com CustomPaint
class PintorForca extends CustomPainter {

  final double progresso;
  final EstiloCaderno estilo;


  const PintorForca(this.progresso, this.estilo);


  static const List<List<Offset>> linhas_estrutura = [

    [Offset(20, 206), Offset(130, 206)],
    [Offset(50, 206), Offset(50, 16)],
    [Offset(46, 18), Offset(152, 18)],
    [Offset(50, 56), Offset(90, 18)],
    [Offset(150, 18), Offset(150, 44)],

  ];

  static const List<List<Offset>> linhas_corpo = [

    [Offset(150, 84), Offset(150, 138)],
    [Offset(150, 98), Offset(122, 122)],
    [Offset(150, 98), Offset(178, 122)],
    [Offset(150, 138), Offset(126, 178)],
    [Offset(150, 138), Offset(174, 178)],

  ];


  // Desenha a estrutura e o boneco
  @override
  void paint(Canvas canvas, Size size) {

    canvas.save();
    canvas.scale(size.width / 220, size.height / 220);

    desenhar_estrutura(canvas);
    desenhar_boneco(canvas);

    canvas.restore();

  }


  // Estrutura da forca, sempre visível
  void desenhar_estrutura(Canvas canvas) {

    Paint caneta_azul = criar_caneta(estilo.tinta, 5 + estilo.espessura_extra);

    for (List<Offset> linha in linhas_estrutura) {

      canvas.drawLine(linha.first, linha.last, caneta_azul);

    }

  }


  // Cabeça, corpo, braços e pernas, uma parte por erro
  void desenhar_boneco(Canvas canvas) {

    Paint caneta_vermelha = criar_caneta(estilo.vermelha, 4 + estilo.espessura_extra);
    double parte_cabeca = calcular_parte(0);

    if (parte_cabeca > 0) {

      Rect area_cabeca = Rect.fromCircle(center: const Offset(150, 64), radius: 20);

      canvas.drawArc(area_cabeca, -pi / 2, 2 * pi * parte_cabeca, false, caneta_vermelha);

    }

    for (int indice = 0; indice < linhas_corpo.length; indice++) {

      double parte = calcular_parte(indice + 1);
      Offset inicio = linhas_corpo[indice].first;
      Offset fim = linhas_corpo[indice].last;

      if (parte > 0) {

        canvas.drawLine(inicio, Offset.lerp(inicio, fim, parte)!, caneta_vermelha);

      }

    }

  }


  // Quanto de cada parte já deve aparecer
  double calcular_parte(int indice) {

    return (progresso - indice).clamp(0.0, 1.0);

  }


  // Caneta usada nos traços
  Paint criar_caneta(Color cor, double espessura) {

    return Paint()
      ..color = cor
      ..strokeWidth = espessura
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

  }


  // Redesenha quando muda o número de erros ou o estilo
  @override
  bool shouldRepaint(PintorForca oldDelegate) {

    return oldDelegate.progresso != progresso || oldDelegate.estilo != estilo;

  }

}
