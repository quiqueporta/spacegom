import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:spacegom_companion/models/game_state.dart';
import 'package:spacegom_companion/screens/home_screen.dart';
import 'package:spacegom_companion/services/storage_service.dart';
import 'package:spacegom_companion/theme/spacegom_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  final storageService = StorageService();
  final gameState = await storageService.loadGameState();

  runApp(SpacegomApp(initialState: gameState));
}

class SpacegomApp extends StatelessWidget {
  final GameState initialState;

  SpacegomApp({super.key, GameState? initialState})
      : initialState = initialState ?? GameState();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spacegom Companion',
      themeMode: ThemeMode.dark,
      darkTheme: SpacegomTheme.dark,
      home: HomeScreen(initialState: initialState),
    );
  }
}
