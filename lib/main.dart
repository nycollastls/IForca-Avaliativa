import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'models/perfil.dart';
import 'screens/tela_inicio.dart';
import 'services/armazenamento_local.dart';
import 'services/cliente_http_local.dart';
import 'services/dados_aplicativo.dart';
import 'widgets/tema_caderno.dart';


// Abre os dados salvos e inicia o app
Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {

    SemanticsBinding.instance.ensureSemantics();

  }

  DadosAplicativo dados = DadosAplicativo(ArmazenamentoLocal(), ClienteHttpLocal());

  await dados.carregar();

  runApp(Forca(dados: dados));

}


// Widget raiz: tema, idioma e tela inicial
class Forca extends StatelessWidget {

  final DadosAplicativo dados;


  const Forca({super.key, required this.dados});


  // Recria o app quando o perfil muda, para aplicar as preferências na hora
  @override
  Widget build(BuildContext context) {

    return ListenableBuilder(

      listenable: dados.perfis,

      builder: (context, _) => MaterialApp(

        title: 'Forca da Programação',
        debugShowCheckedModeBanner: false,

        locale: const Locale('pt', 'BR'),
        supportedLocales: const [Locale('pt', 'BR')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,

        theme: criar_tema(dados.perfis.perfil),
        themeAnimationDuration: Duration.zero,

        builder: (context, tela) => aplicar_acessibilidade(context, tela!),

        home: TelaInicio(dados: dados),

      ),

    );

  }


  // Aplica o tamanho do texto e a redução de animações escolhidos nas configurações
  Widget aplicar_acessibilidade(BuildContext context, Widget tela) {

    Perfil perfil = dados.perfis.perfil;
    MediaQueryData medidas = MediaQuery.of(context);
    double escala = medidas.textScaler.scale(1) * perfil.tamanho_texto.fator;

    return MediaQuery(

      data: medidas.copyWith(

        textScaler: TextScaler.linear(escala),
        disableAnimations: medidas.disableAnimations || perfil.reduzir_animacoes,

      ),

      child: tela,

    );

  }

}
