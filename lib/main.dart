import 'package:flutter/material.dart';
import 'package:vertice/app/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Let Flutter activate accessibility when assistive technology requests it.
  // Browser tests enable it through Flutter's accessibility placeholder.
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vértice',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Vertice',
        // Define o fundo do Scaffold como preto puro
        scaffoldBackgroundColor: Colors.black,

        colorScheme: const ColorScheme.dark(
          // A cor principal (botões, destaques)
          primary: Colors.deepPurpleAccent,
          // Cor dos elementos sobre o roxo (ex: texto dentro do botão)
          onPrimary: Colors.white,
          // Fundo de Cards, Dialogs e Menus
          surface: Color(
            0xFF121212,
          ), // Um cinza quase preto para dar profundidade
          // Cor dos textos e ícones gerais
          onSurface: Colors.white,
        ),

        // Opcional: Garante que a AppBar também seja preta
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
      ),

      builder: (context, child) => Center(child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: child ?? const SizedBox.shrink(),
        )),
      home: const App(),
    );
  }
}

