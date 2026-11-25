import 'package:flutter/material.dart';

import '../modelos/linguagem.dart';
import 'tela_jogo.dart';


class TelaInicio extends StatelessWidget {

  const TelaInicio({super.key});


  void abrir_jogo(BuildContext context, Linguagem linguagem) {

    Navigator.of(context).push(

      MaterialPageRoute(

        builder: (context) => TelaJogo(linguagem: linguagem),

      ),

    );

  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: const Text('Forca'),

      ),

      body: Center(

        child: Column(

          mainAxisSize: MainAxisSize.min,

          children: [

            const Text('Escolha a linguagem', style: TextStyle(fontSize: 22)),

            const SizedBox(height: 24),

            for (Linguagem linguagem in Linguagem.values)

              Padding(

                padding: const EdgeInsets.symmetric(vertical: 8),

                child: SizedBox(

                  width: 200,

                  child: ElevatedButton(

                    onPressed: () => abrir_jogo(context, linguagem),

                    child: Text(linguagem.nome),

                  ),

                ),

              ),

          ],

        ),

      ),

    );

  }

}
