import 'package:flutter/material.dart';

import 'screens/tela_inicio.dart';
import 'services/armazenamento_local.dart';
import 'services/dados_aplicativo.dart';
import 'widgets/tema_caderno.dart';


Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();

  DadosAplicativo dados = DadosAplicativo(ArmazenamentoLocal());

  await dados.carregar();

  runApp(Forca(dados: dados));

}


class Forca extends StatelessWidget {

  final DadosAplicativo dados;


  const Forca({super.key, required this.dados});


  @override
  Widget build(BuildContext context) {

    return MaterialApp(

      title: 'Forca da Programação',
      debugShowCheckedModeBanner: false,

      theme: criar_tema(),

      home: TelaInicio(dados: dados),

    );

  }

}
