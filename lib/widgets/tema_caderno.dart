import 'package:flutter/material.dart';


const Color cor_papel = Color(0xFFF6F9FD);
const Color cor_linha = Color(0xFFDCE7F3);
const Color cor_tinta = Color(0xFF1B2F6B);
const Color cor_caneta_vermelha = Color(0xFFB71C3A);
const Color cor_marca_texto = Color(0xFFFFE15A);
const Color cor_acerto = Color(0xFF17633F);

const double tamanho_quadricula = 24;
const double largura_maxima = 560;


ThemeData criar_tema() {

  ColorScheme esquema_cores = ColorScheme.fromSeed(

    seedColor: cor_tinta,
    primary: cor_tinta,
    surface: cor_papel,
    onSurface: cor_tinta,
    error: cor_caneta_vermelha,

  );

  OutlinedBorder formato_botao = RoundedRectangleBorder(borderRadius: BorderRadius.circular(6));

  return ThemeData(

    colorScheme: esquema_cores,

    scaffoldBackgroundColor: cor_papel,

    appBarTheme: const AppBarTheme(

      backgroundColor: cor_papel,
      foregroundColor: cor_tinta,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(color: cor_tinta, fontSize: 20, fontWeight: FontWeight.w700),

    ),

    filledButtonTheme: FilledButtonThemeData(

      style: FilledButton.styleFrom(minimumSize: const Size(48, 48), shape: formato_botao),

    ),

    outlinedButtonTheme: OutlinedButtonThemeData(

      style: OutlinedButton.styleFrom(

        minimumSize: const Size(48, 48),
        shape: formato_botao,
        backgroundColor: Colors.white,
        side: const BorderSide(color: cor_tinta, width: 1.5),

      ),

    ),

    inputDecorationTheme: const InputDecorationTheme(

      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(),
      errorMaxLines: 2,

    ),

  );

}


class PaginaCaderno extends StatelessWidget {

  final String titulo;
  final List<Widget> conteudo;
  final List<Widget> acoes;


  const PaginaCaderno({

    super.key,
    required this.titulo,
    required this.conteudo,
    this.acoes = const [],

  });


  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(title: Text(titulo), actions: acoes),

      body: CustomPaint(

        painter: const PintorQuadriculado(),

        child: SizedBox.expand(

          child: SafeArea(

            child: SingleChildScrollView(

              padding: const EdgeInsets.all(20),

              child: Center(

                child: ConstrainedBox(

                  constraints: const BoxConstraints(maxWidth: largura_maxima),

                  child: Column(

                    crossAxisAlignment: CrossAxisAlignment.stretch,

                    children: conteudo,

                  ),

                ),

              ),

            ),

          ),

        ),

      ),

    );

  }

}


class Subtitulo extends StatelessWidget {

  final String texto;


  const Subtitulo(this.texto, {super.key});


  @override
  Widget build(BuildContext context) {

    return Padding(

      padding: const EdgeInsets.only(top: 24, bottom: 10),

      child: Text(texto, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),

    );

  }

}


class PintorQuadriculado extends CustomPainter {

  const PintorQuadriculado();


  @override
  void paint(Canvas canvas, Size size) {

    Paint pincel = Paint()
      ..color = cor_linha
      ..strokeWidth = 1;

    for (double x = 0; x < size.width; x += tamanho_quadricula) {

      canvas.drawLine(Offset(x, 0), Offset(x, size.height), pincel);

    }

    for (double y = 0; y < size.height; y += tamanho_quadricula) {

      canvas.drawLine(Offset(0, y), Offset(size.width, y), pincel);

    }

  }


  @override
  bool shouldRepaint(PintorQuadriculado oldDelegate) => false;

}


void mostrar_aviso(BuildContext context, String mensagem) {

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(mensagem)));

}


Future<bool> confirmar_acao(BuildContext context, String titulo, String mensagem, String rotulo_acao) async {

  bool? confirmou = await showDialog<bool>(

    context: context,

    builder: (contexto_dialogo) => AlertDialog(

      title: Text(titulo),
      content: Text(mensagem),

      actions: [

        TextButton(

          onPressed: () => Navigator.of(contexto_dialogo).pop(false),
          child: const Text('Cancelar'),

        ),

        FilledButton(

          onPressed: () => Navigator.of(contexto_dialogo).pop(true),
          child: Text(rotulo_acao),

        ),

      ],

    ),

  );

  return confirmou ?? false;

}
