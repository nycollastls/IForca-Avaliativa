// Escolhe o cliente HTTP certo para cada plataforma
export 'cliente_http_nativo.dart' if (dart.library.js_interop) 'cliente_http_web.dart';
