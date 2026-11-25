import 'package:flutter/material.dart';


class EstiloCaderno extends ThemeExtension<EstiloCaderno> {

  final Color papel;
  final Color linha;
  final Color tinta;
  final Color vermelha;
  final Color marca_texto;
  final Color acerto;
  final double espessura_extra;
  final bool teclado_alfabetico;
  final bool marcas_teclado;


  const EstiloCaderno({

    this.papel = const Color(0xFFF6F9FD),
    this.linha = const Color(0xFFDCE7F3),
    this.tinta = const Color(0xFF1B2F6B),
    this.vermelha = const Color(0xFFB71C3A),
    this.marca_texto = const Color(0xFFFFE15A),
    this.acerto = const Color(0xFF17633F),
    this.espessura_extra = 0,
    this.teclado_alfabetico = false,
    this.marcas_teclado = false,

  });


  const EstiloCaderno.alto_contraste({this.teclado_alfabetico = false, this.marcas_teclado = false})
      : papel = Colors.white,
        linha = Colors.white,
        tinta = Colors.black,
        vermelha = const Color(0xFF9C0000),
        marca_texto = const Color(0xFFFFE600),
        acerto = const Color(0xFF00401F),
        espessura_extra = 2;


  static EstiloCaderno de(BuildContext context) {

    return Theme.of(context).extension<EstiloCaderno>() ?? const EstiloCaderno();

  }


  @override
  EstiloCaderno copyWith() => this;


  @override
  EstiloCaderno lerp(EstiloCaderno? other, double t) => other ?? this;

}
