import 'package:dio/dio.dart';

class AiGameService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://172.30.48.80:8000',
      headers: {'Content-Type': 'application/json'},
    ),
  );

  Future<SoundHunterResponse> getSoundHunterQuestions({
    required String ageGroup,
    required String hardArea,
    required String readingGoal,
    required String diagnosisTime,
    required String motivatingGames,
    required String workingWithProfessional,
  }) async {
    try {
      final response = await _dio.post(
        '/api/phonological-game',
        data: {
          'user_info': {
            'age_group': ageGroup,
            'hard_area': hardArea,
            'reading_goal': readingGoal,
            'diagnosis_time': diagnosisTime,
            'motivating_games': motivatingGames,
            'working_with_professional': workingWithProfessional,
          },
        },
      );

      return SoundHunterResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Sorular alınırken hata oluştu: $e');
    }
  }

  Future<TrueOrFalseResponse> getTrueOrFalseQuestions({
    required String ageGroup,
    required String hardArea,
    required String readingGoal,
    required String diagnosisTime,
    required String motivatingGames,
    required String workingWithProfessional,
  }) async {
    try {
      final response = await _dio.post(
        '/api/spelling-game',
        data: {
          'user_info': {
            'age_group': ageGroup,
            'hard_area': hardArea,
            'reading_goal': readingGoal,
            'diagnosis_time': diagnosisTime,
            'motivating_games': motivatingGames,
            'working_with_professional': workingWithProfessional,
          },
        },
      );

      return TrueOrFalseResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Sorular alınırken hata oluştu: $e');
    }
  }

  Future<JumbledWordsResponse> getJumbledWordsQuestions({
    required String ageGroup,
    required String hardArea,
    required String readingGoal,
    required String diagnosisTime,
    required String motivatingGames,
    required String workingWithProfessional,
  }) async {
    try {
      final response = await _dio.post(
        '/api/word-list',
        data: {
          'user_info': {
            'age_group': ageGroup,
            'hard_area': hardArea,
            'reading_goal': readingGoal,
            'diagnosis_time': diagnosisTime,
            'motivating_games': motivatingGames,
            'working_with_professional': workingWithProfessional,
          },
        },
      );

      return JumbledWordsResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Sorular alınırken hata oluştu: $e');
    }
  }

  Future<SentenceDetectiveResponse> getSentenceDetectiveQuestions({
    required String ageGroup,
    required String hardArea,
    required String readingGoal,
    required String diagnosisTime,
    required String motivatingGames,
    required String workingWithProfessional,
  }) async {
    try {
      final response = await _dio.post(
        '/api/paragraph',
        data: {
          'user_info': {
            'age_group': ageGroup,
            'hard_area': hardArea,
            'reading_goal': readingGoal,
            'diagnosis_time': diagnosisTime,
            'motivating_games': motivatingGames,
            'working_with_professional': workingWithProfessional,
          },
        },
      );

      return SentenceDetectiveResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Sorular alınırken hata oluştu: $e');
    }
  }
}

class SoundHunterResponse {
  final List<SoundHunterQuestion> questions;

  SoundHunterResponse({required this.questions});

  factory SoundHunterResponse.fromJson(Map<String, dynamic> json) {
    return SoundHunterResponse(
      questions: (json['questions'] as List)
          .map((q) => SoundHunterQuestion.fromJson(q))
          .toList(),
    );
  }
}

class SoundHunterQuestion {
  final String question;
  final List<String> options;
  final List<int> correctAnswers;

  SoundHunterQuestion({
    required this.question,
    required this.options,
    required this.correctAnswers,
  });

  factory SoundHunterQuestion.fromJson(Map<String, dynamic> json) {
    return SoundHunterQuestion(
      question: json['question'] as String,
      options: (json['options'] as List).map((o) => o as String).toList(),
      correctAnswers: (json['correct_answers'] as List)
          .map((a) => a as int)
          .toList(),
    );
  }
}

class TrueOrFalseResponse {
  final List<TrueOrFalseQuestion> questions;

  TrueOrFalseResponse({required this.questions});

  factory TrueOrFalseResponse.fromJson(Map<String, dynamic> json) {
    return TrueOrFalseResponse(
      questions: (json['questions'] as List)
          .map((q) => TrueOrFalseQuestion.fromJson(q))
          .toList(),
    );
  }
}

class TrueOrFalseQuestion {
  final List<String> words;
  final int wrongIndex;

  TrueOrFalseQuestion({required this.words, required this.wrongIndex});

  factory TrueOrFalseQuestion.fromJson(Map<String, dynamic> json) {
    return TrueOrFalseQuestion(
      words: (json['words'] as List).map((w) => w as String).toList(),
      wrongIndex: json['wrong_index'] as int,
    );
  }
}

class JumbledWordsResponse {
  final List<JumbledWordsQuestion> questions;

  JumbledWordsResponse({required this.questions});

  factory JumbledWordsResponse.fromJson(Map<String, dynamic> json) {
    final words = (json['words'] as List).map((w) => w as String).toList();

    return JumbledWordsResponse(
      questions: words.map((word) => JumbledWordsQuestion(word: word)).toList(),
    );
  }
}

class JumbledWordsQuestion {
  final String correctWord;
  final List<String> shuffledLetters;

  JumbledWordsQuestion({required String word})
    : correctWord = word,
      shuffledLetters = _shuffleLetters(word);

  static List<String> _shuffleLetters(String word) {
    final letters = word.split('');
    letters.shuffle();
    return letters;
  }
}

class SentenceDetectiveResponse {
  final List<SentenceDetectiveQuestion> questions;

  SentenceDetectiveResponse({required this.questions});

  factory SentenceDetectiveResponse.fromJson(Map<String, dynamic> json) {
    // API'den paragraphs array'i geliyor
    final paragraphs = (json['paragraphs'] as List)
        .map((p) => p as String)
        .toList();

    return SentenceDetectiveResponse(
      questions: paragraphs
          .map((paragraph) => SentenceDetectiveQuestion(paragraph: paragraph))
          .toList(),
    );
  }
}

class SentenceDetectiveQuestion {
  final List<String> correctOrder;
  final List<String> shuffledSentences;

  SentenceDetectiveQuestion({required String paragraph})
    : correctOrder = _parseSentences(paragraph),
      shuffledSentences = _shuffleSentences(_parseSentences(paragraph));

  static List<String> _parseSentences(String paragraph) {
    return paragraph
        .split('.')
        .where((s) => s.trim().isNotEmpty)
        .map((s) => '${s.trim()}.')
        .toList();
  }

  static List<String> _shuffleSentences(List<String> sentences) {
    final shuffled = List<String>.from(sentences);
    shuffled.shuffle();
    return shuffled;
  }
}
