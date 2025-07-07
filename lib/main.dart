import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'providers/game_provider.dart';
import 'providers/language_provider.dart';
import 'screens/game_mode_screen.dart';
import 'screens/score_screen.dart';
import 'l10n/l10n.dart';
import 'l10n/app_localizations.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => GameProvider()..init()),
        ChangeNotifierProvider(create: (context) => LanguageProvider()),
      ],
      child: Consumer<LanguageProvider>(
        builder: (context, languageProvider, _) {
          return MaterialApp(
            title: 'Score Counter',
            locale: languageProvider.locale,
            theme: ThemeData(
              fontFamily: 'Quicksand',
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.blue[500]!,
                brightness: Brightness.light,
              ),
              useMaterial3: true,
              pageTransitionsTheme: const PageTransitionsTheme(
                builders: {
                  TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
                },
              ),
            ),
            darkTheme: ThemeData(
              fontFamily: 'Quicksand',
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.blue[500]!,
                brightness: Brightness.dark,
              ),
              useMaterial3: true,
            ),
            themeMode: ThemeMode.system, // Follow system theme
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: L10n.supportedLocales,
            home: const HomeRouter(),
          );
        },
      ),
    );
  }
}

// This StatefulWidget handles initial navigation only once
class HomeRouter extends StatefulWidget {
  const HomeRouter({super.key});

  @override
  State<HomeRouter> createState() => _HomeRouterState();
}

class _HomeRouterState extends State<HomeRouter> {
  bool _isInitialized = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Delay navigation until after the first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigateBasedOnGameState();
    });
  }

  Future<void> _navigateBasedOnGameState() async {
    if (_isInitialized) return;

    final gameProvider = Provider.of<GameProvider>(context, listen: false);

    // Add a small delay to ensure provider init() has completed
    await Future.delayed(const Duration(milliseconds: 100));

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _isInitialized = true;
    });

    // Check if there's a previous game and navigate accordingly
    if (gameProvider.currentGameMode != null &&
        gameProvider.players.isNotEmpty) {
      if (!mounted) return;

      // Use pushReplacement to avoid back navigation to this router
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => ScoreScreen(gameProvider: gameProvider),
        ),
      );
    } else {
      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const GameModeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : Container(), // This will be replaced by navigation
      ),
    );
  }
}
