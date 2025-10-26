import 'package:dio/dio.dart';

class AiAnalysisService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://172.30.48.80:8000',
      headers: {'Content-Type': 'application/json'},
    ),
  );

  Future<String> getAnalysis({
    required String ageGroup,
    required String hardArea,
    required String readingGoal,
    required String diagnosisTime,
    required String motivatingGames,
    required String workingWithProfessional,
    required Map<String, dynamic> userStatistics,
  }) async {
    try {
      final response = await _dio.post(
        '/api/analysis',
        data: {
          'user_info': {
            'age_group': ageGroup,
            'hard_area': hardArea,
            'reading_goal': readingGoal,
            'diagnosis_time': diagnosisTime,
            'motivating_games': motivatingGames,
            'working_with_professional': workingWithProfessional,
          },
          'user_statistics': userStatistics,
        },
      );

      return response.data['analysis'] as String;
    } catch (e) {
      throw Exception('Analiz alınırken hata oluştu: $e');
    }
  }
}
