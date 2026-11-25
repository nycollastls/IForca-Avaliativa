import 'package:flutter/material.dart';

import 'telas/tela_inicio.dart';


void main() {

  runApp(const Forca());

}


class Forca extends StatelessWidget {

  const Forca({super.key});


  @override
  Widget build(BuildContext context) {

    return MaterialApp(

      title: 'Forca',

      theme: ThemeData(colorSchemeSeed: Colors.indigo),

      home: const TelaInicio(),

    );

  }

}
