import 'package:flutter/material.dart';
import 'package:heylex/features/games/pages/jumbled_words_game.dart';
import 'package:heylex/features/games/pages/sentence_detective_game.dart';
import 'package:heylex/features/games/pages/sound_hunter_game.dart';
import 'package:heylex/features/games/pages/true_or_false_game.dart';

class GamesFlow extends StatelessWidget {
  const GamesFlow({super.key, required this.gameId});
  final String gameId;

  @override
  Widget build(BuildContext context) {
    // gameId'ye göre ilgili oyun sayfasına yönlendir
    switch (gameId) {
      case 'sound_hunter':
        return const SoundHunterGame();
      case 'true_or_false':
        return const TrueOrFalseGame();
      case 'jumbled_words':
        return const JumbledWordsGame();
      case 'sentence_detective':
        return const SentenceDetectiveGame();
      default:
        return Scaffold(body: Center(child: Text('Oyun bulunamadı: $gameId')));
    }
  }
}
