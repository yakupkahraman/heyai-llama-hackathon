import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:heylex/features/auth/pages/questions_page.dart';
import 'package:heylex/features/auth/providers/user_answers_provider.dart';
import 'package:heylex/features/auth/providers/user_provider.dart';
import 'package:heylex/features/auth/service/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class QuestionsFlow extends StatefulWidget {
  const QuestionsFlow({super.key});

  @override
  State<QuestionsFlow> createState() => _QuestionsFlowState();
}

class _QuestionsFlowState extends State<QuestionsFlow> {
  int _currentQuestionIndex = 0;
  bool _isLoading = false;

  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'Hangi yaş grubundasınız?',
      'options': ['14-17', '18-24'],
      'key': 'age_group',
    },
    {
      'question': 'En çok zorlandığınız alan hangisidir?',
      'options': [
        'Harfleri ayırt etmek',
        'Heceleme ve yazım',
        'Okuma hızım düşük',
      ],
      'key': 'hard_area',
    },
    {
      'question': 'Okuma konusunda hangi hedef sana uyuyor?',
      'options': [
        'Daha hızlı okumak',
        'Daha rahat okumak',
        'Oyunlarla pratik yapmak',
        'Anlama becerisi geliştirmek',
      ],
      'key': 'reading_goal',
    },
    {
      'question': 'Disleksi tanınız ne zaman kondu?',
      'options': [
        'Yeni tanı aldım (son 1 yıl)',
        'Uzun süre (1-5 yıl)',
        'Çocuklukta tanı aldım ',
        'Hiç tanı almadım',
      ],
      'key': 'diagnosis_time',
    },
    {
      'question': 'Hangi tür oyunlar seni daha çok motive eder?',
      'options': [
        'Bulmaca ve eşleştirme',
        'Hikaye ve görev',
        'Süreli mini oyunlar',
        'Kelime bulma',
        'Yazım ve tamamlama görevi',
      ],
      'key': 'motivating_games',
    },
    {
      'question': 'En çok ilgin hangi alandadır?',
      'options': [
        'Spor',
        'Sanat',
        'Müzik',
        'Resim/Tasarım',
        'Teknoloji/Yazılım',
        'Doğa/Hayvanlar',
      ],
      'key': 'working_with_professional',
    },
    {
      'question': 'Şu anda bir uzman ile çalışıyor musun?',
      'options': [
        'Evet, bir uzmanla düzenli olarak çalışıyorum',
        'Hayır, bireysel olarak ilerliyorum',
      ],
      'key': 'working_with_professional',
    },
  ];

  void _handleAnswer(String answer) {
    final currentQuestion = _questions[_currentQuestionIndex];

    // Cevabı provider'a kaydet
    final provider = Provider.of<UserAnswersProvider>(context, listen: false);
    provider.updateAnswer(currentQuestion['key'], answer);

    if (_currentQuestionIndex < _questions.length - 1) {
      // Bir sonraki soruya geç
      setState(() {
        _currentQuestionIndex++;
      });
    } else {
      // Tüm sorular tamamlandı, kayıt işlemini yap
      _completeQuestionnaire();
    }
  }

  Future<void> _completeQuestionnaire() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final provider = Provider.of<UserAnswersProvider>(context, listen: false);

      final fullData = provider.getFullData();
      final email = provider.email;
      final password = provider.password;

      if (email == null || password == null) {
        _showError("Email veya şifre bulunamadı");
        return;
      }
      final authService = AuthService();
      final response = await authService.signUpWithEmailPassword(
        email,
        password,
      );

      if (response.user == null) {
        _showError("Kayıt başarısız oldu");
        return;
      }
      final profileData = {'id': response.user!.id, ...fullData};

      await Supabase.instance.client.from('profiles').insert(profileData);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_logged_in', true);
      await prefs.setBool('questions_completed', true);

      provider.clear();

      // ignore: use_build_context_synchronously
      final userProvider = context.read<UserProvider>();
      await userProvider.loadFromSupabase();

      if (mounted) {
        context.go('/');
      }
    } catch (e) {
      log('Hata: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showError("Kayıt sırasında hata: ${e.toString()}");
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = _questions[_currentQuestionIndex];
    final isLastQuestion = _currentQuestionIndex == _questions.length - 1;

    return QuestionsPage(
      question: currentQuestion['question'],
      options: List<String>.from(currentQuestion['options']),
      onOptionSelected: _handleAnswer,
      isLastQuestion: isLastQuestion,
      isLoading: _isLoading,
    );
  }
}
