import 'package:flutter/material.dart';

import '../models/perfil.dart';
import 'estilo_caderno.dart';


const double tamanho_quadricula = 24;
const double largura_maxima = 560;


EstiloCaderno criar_estilo(Perfil perfil) {

  if (perfil.alto_contraste) {

    return EstiloCaderno.alto_contraste(

      teclado_alfabetico: perfil.teclado_alfabetico,
      marcas_teclado: perfil.marcas_teclado,

    );

  }

  return EstiloCaderno(

    teclado_alfabetico: perfil.teclado_alfabetico,
    marcas_teclado: perfil.marcas_teclado,

  );

}


TextTheme criar_textos(bool letras_espacadas) {

  if (!letras_espacadas) {

    return const TextTheme();

  }

  const TextStyle espacado = TextStyle(letterSpacing: 1.4, wordSpacing: 3);

  return const TextTheme(

    headlineSmall: espacado,
    titleLarge: espacado,
    titleMedium: espacado,
    bodyLarge: espacado,
    bodyMedium: espacado,
    bodySmall: espacado,
    labelLarge: espacado,

  );

}


WidgetStateProperty<BorderSide?> criar_borda_foco(Color cor, BorderSide? borda_comum) {

  return WidgetStateProperty.resolveWith((estados) {

    if (estados.contains(WidgetState.focused)) {

      return BorderSide(color: cor, width: 4, strokeAlign: BorderSide.strokeAlignInside);

    }

    return borda_comum;

  });

}


ThemeData criar_tema(Perfil perfil) {

  EstiloCaderno estilo = criar_estilo(perfil);

  ColorScheme esquema_cores = ColorScheme.fromSeed(

    seedColor: estilo.tinta,
    primary: estilo.tinta,
    surface: estilo.papel,
    onSurface: estilo.tinta,
    onSurfaceVariant: estilo.tinta,
    outline: estilo.tinta,
    error: estilo.vermelha,

  );

  OutlinedBorder formato_botao = RoundedRectangleBorder(borderRadius: BorderRadius.circular(6));
  BorderSide borda_comum = BorderSide(color: estilo.tinta, width: 1.5 + estilo.espessura_extra / 2);

  return ThemeData(

    colorScheme: esquema_cores,
    extensions: [estilo],
    textTheme: criar_textos(perfil.letras_espacadas),

    scaffoldBackgroundColor: estilo.papel,

    appBarTheme: AppBarTheme(

      backgroundColor: estilo.tinta,
      foregroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),

    ),

    filledButtonTheme: FilledButtonThemeData(

      style: FilledButton.styleFrom(minimumSize: const Size(48, 48), shape: formato_botao).copyWith(

        side: criar_borda_foco(estilo.marca_texto, null),

      ),

    ),

    outlinedButtonTheme: OutlinedButtonThemeData(

      style: OutlinedButton.styleFrom(

        minimumSize: const Size(48, 48),
        shape: formato_botao,
        backgroundColor: Colors.white,

      ).copyWith(

        side: criar_borda_foco(estilo.tinta, borda_comum),

      ),

    ),

    chipTheme: ChipThemeData(

      labelStyle: TextStyle(color: estilo.tinta, fontWeight: FontWeight.w500),
      secondaryLabelStyle: TextStyle(color: estilo.tinta, fontWeight: FontWeight.w500),
      checkmarkColor: estilo.tinta,
      side: borda_comum,

    ),

    dialogTheme: DialogThemeData(

      backgroundColor: estilo.papel,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),

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

  final String? titulo;
  final Widget? cabecalho;
  final List<Widget> acoes;
  final List<Widget> conteudo;


  const PaginaCaderno({

    super.key,
    this.titulo,
    this.cabecalho,
    this.acoes = const [],
    required this.conteudo,

  });


  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(title: cabecalho ?? Text(titulo ?? ''), actions: acoes),

      body: CustomPaint(

        painter: PintorQuadriculado(EstiloCaderno.de(context).linha),

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

      child: Semantics(

        header: true,
        child: Text(texto, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),

      ),

    );

  }

}


class AvisoConexao extends StatelessWidget {

  const AvisoConexao({super.key});


  @override
  Widget build(BuildContext context) {

    return const Column(

      children: [

        SizedBox(height: 32),

        CircularProgressIndicator(),

        SizedBox(height: 20),

        Text('Conectando ao servidor. Na primeira vez, pode levar até um minuto.', textAlign: TextAlign.center),

      ],

    );

  }

}


class PintorQuadriculado extends CustomPainter {

  final Color cor_linha;


  const PintorQuadriculado(this.cor_linha);


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
  bool shouldRepaint(PintorQuadriculado oldDelegate) => oldDelegate.cor_linha != cor_linha;

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
