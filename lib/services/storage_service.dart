import 'dart:convert';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:spacegom_companion/models/game_state.dart';

class StorageService {
  static const _key = 'game_state';

  Future<void> saveGameState(GameState state) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_key, jsonEncode(state.toJson()));
  }

  Future<GameState> loadGameState() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);

    if (raw == null) {
      return GameState.withDefaultCrew();
    }

    return GameState.fromJson(jsonDecode(raw));
  }

  Future<void> clearGameState() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_key);
  }

  Future<File> exportToFile(GameState state, String directoryPath) async {
    final now = DateTime.now();
    final timestamp = '${now.year}'
        '${now.month.toString().padLeft(2, '0')}'
        '${now.day.toString().padLeft(2, '0')}'
        '_'
        '${now.hour.toString().padLeft(2, '0')}'
        '${now.minute.toString().padLeft(2, '0')}';
    final fileName = 'spacegom_$timestamp.json';
    final file = File('$directoryPath/$fileName');

    final json = jsonEncode(state.toJson());
    await file.writeAsString(json);

    return file;
  }

  Future<GameState> importFromFile(String filePath) async {
    final file = File(filePath);
    final content = await file.readAsString();
    final json = jsonDecode(content) as Map<String, dynamic>;

    return GameState.fromJson(json);
  }
}
