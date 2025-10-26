import 'package:supabase_flutter/supabase_flutter.dart';

class GameService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> saveGameResult({
    required String gameId,
    required int correctCount,
    required int wrongCount,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    await _supabase.from('game_results').insert({
      'user_id': userId,
      'game_id': gameId,
      'correct_count': correctCount,
      'wrong_count': wrongCount,
      'played_at': DateTime.now().toIso8601String(),
    });
  }

  /// Son 7 günün oyun verilerini getirir
  Future<Map<String, double>> getWeeklyGameData(String gameId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return {};

    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 6));

    final response = await _supabase
        .from('game_results')
        .select('played_at, correct_count, wrong_count')
        .eq('user_id', userId)
        .eq('game_id', gameId)
        .gte('played_at', sevenDaysAgo.toIso8601String())
        .order('played_at', ascending: true);

    // Günlük verileri topla
    Map<String, double> dailyData = {};

    for (var result in response) {
      final playedAt = DateTime.parse(result['played_at']);
      final dateKey =
          '${playedAt.year}-${playedAt.month.toString().padLeft(2, '0')}-${playedAt.day.toString().padLeft(2, '0')}';

      final correct = (result['correct_count'] as num).toDouble();
      final wrong = (result['wrong_count'] as num).toDouble();
      final total = correct + wrong;

      // Başarı oranını hesapla (0-10 arası)
      final successRate = total > 0 ? (correct / total) * 10 : 0.0;

      // Aynı gün birden fazla oyun varsa ortalamasını al
      if (dailyData.containsKey(dateKey)) {
        dailyData[dateKey] = (dailyData[dateKey]! + successRate) / 2;
      } else {
        dailyData[dateKey] = successRate;
      }
    }

    return dailyData;
  }

  /// Belirli bir oyun için toplam oynama sayısını döndürür
  Future<int> getGamePlayCount(String gameId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return 0;

    final response = await _supabase
        .from('game_results')
        .select('id')
        .eq('user_id', userId)
        .eq('game_id', gameId);

    return response.length;
  }

  /// Kullanıcının genel istatistiklerini hesaplar
  Future<Map<String, dynamic>> getUserStatistics() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return {};

    // Tüm oyun sonuçlarını çek
    final allResults = await _supabase
        .from('game_results')
        .select('game_id, correct_count, wrong_count')
        .eq('user_id', userId);

    if (allResults.isEmpty) {
      return {
        'total_games_played': 0,
        'phonological_success_rate': 0.0,
        'spelling_success_rate': 0.0,
        'word_list_success_rate': 0.0,
        'paragraph_success_rate': 0.0,
      };
    }

    // Toplam oyun sayısı
    int totalGamesPlayed = allResults.length;

    // Oyun bazlı başarı oranları
    Map<String, List<double>> gameSuccessRates = {
      'sound_hunter': [],
      'true_or_false': [],
      'jumbled_words': [],
      'sentence_detective': [],
    };

    for (var result in allResults) {
      final gameId = result['game_id'] as String;
      final correct = (result['correct_count'] as num).toDouble();
      final wrong = (result['wrong_count'] as num).toDouble();
      final total = correct + wrong;

      if (total > 0 && gameSuccessRates.containsKey(gameId)) {
        gameSuccessRates[gameId]!.add((correct / total) * 100);
      }
    }

    // Ortalama başarı oranlarını hesapla
    double phonologicalRate = gameSuccessRates['sound_hunter']!.isEmpty
        ? 0.0
        : gameSuccessRates['sound_hunter']!.reduce((a, b) => a + b) /
              gameSuccessRates['sound_hunter']!.length;

    double spellingRate = gameSuccessRates['true_or_false']!.isEmpty
        ? 0.0
        : gameSuccessRates['true_or_false']!.reduce((a, b) => a + b) /
              gameSuccessRates['true_or_false']!.length;

    double wordListRate = gameSuccessRates['jumbled_words']!.isEmpty
        ? 0.0
        : gameSuccessRates['jumbled_words']!.reduce((a, b) => a + b) /
              gameSuccessRates['jumbled_words']!.length;

    double paragraphRate = gameSuccessRates['sentence_detective']!.isEmpty
        ? 0.0
        : gameSuccessRates['sentence_detective']!.reduce((a, b) => a + b) /
              gameSuccessRates['sentence_detective']!.length;

    return {
      'total_games_played': totalGamesPlayed.toString(),
      'phonological_success_rate': phonologicalRate.toString(),
      'spelling_success_rate': spellingRate.toString(),
      'word_list_success_rate': wordListRate.toString(),
      'paragraph_success_rate': paragraphRate.toString(),
    };
  }
}
