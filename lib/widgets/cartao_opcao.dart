import 'package:flutter/material.dart';

import 'estilo_caderno.dart';


class Cartao extends StatelessWidget {

  final Widget conteudo;


  const Cartao({super.key, required this.conteudo});


  @override
  Widget build(BuildContext context) {

    return Padding(

      padding: const EdgeInsets.only(bottom: 10),

      child: Material(

        color: Colors.white,
        shape: RoundedRectangleBorder(side: BorderSide(color: EstiloCaderno.de(context).tinta)),
        child: conteudo,

      ),

    );

  }

}


class CartaoOpcao extends StatelessWidget {

  final String titulo;
  final String descricao;
  final bool valor;
  final void Function(bool valor) ao_mudar;


  const CartaoOpcao({

    super.key,
    required this.titulo,
    required this.descricao,
    required this.valor,
    required this.ao_mudar,

  });


  @override
  Widget build(BuildContext context) {

    return Cartao(

      conteudo: SwitchListTile(

        value: valor,
        onChanged: ao_mudar,
        title: Text(titulo),
        subtitle: Text(descricao),

      ),

    );

  }

}
