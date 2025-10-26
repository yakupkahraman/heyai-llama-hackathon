import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:go_router/go_router.dart';
import 'package:heylex/core/components/glass_effect_container.dart';
import 'package:heylex/core/theme/theme_constants.dart';
import 'package:heylex/features/auth/components/auth_button.dart';
import 'package:heylex/features/games/service/game_service.dart';
import 'package:heylex/features/games/service/ai__game_service.dart';
import 'package:heylex/features/auth/providers/user_provider.dart';
import 'package:provider/provider.dart';

class SentenceDetectiveGame extends StatefulWidget {
  const SentenceDetectiveGame({super.key});

  @override
  State<SentenceDetectiveGame> createState() => _SentenceDetectiveGameState();
}

class _SentenceDetectiveGameState extends State<SentenceDetectiveGame> {
  int _currentStep = 0;
  int _totalSteps = 5;

  int _correctAnswers = 0;
  int _wrongAnswers = 0;

  List<SentenceDetectiveQuestion> _questions = [];
  bool _isLoading = true;

  List<String> correctOrder = [];
  List<String> sentences = [];

  bool _hasChecked = false;
  int? _selectedIndex;

  final player = AudioPlayer();
  final _gameService = GameService();
  final _aiGameService = AiGameService();

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  Future<void> _loadQuestions() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    try {
      final response = await _aiGameService.getSentenceDetectiveQuestions(
        ageGroup: userProvider.ageGroup ?? '',
        hardArea: userProvider.hardArea ?? '',
        readingGoal: userProvider.readingGoal ?? '',
        diagnosisTime: userProvider.diagnosisTime ?? '',
        motivatingGames: userProvider.motivatingGames ?? '',
        workingWithProfessional: userProvider.workingWithProfessional ?? '',
      );

      if (!mounted) return;

      setState(() {
        _questions = response.questions;
        _totalSteps = _questions.length;
        _isLoading = false;

        if (_questions.isNotEmpty) {
          _loadCurrentQuestion();
        }
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Sorular yüklenemedi: $e')));
    }
  }

  void _loadCurrentQuestion() {
    if (_questions.isEmpty || _currentStep >= _questions.length) return;

    setState(() {
      correctOrder = List.from(_questions[_currentStep].correctOrder);
      sentences = List.from(_questions[_currentStep].shuffledSentences);
    });
  }

  Future<void> goodAnswerPlaySound() async {
    await player.play(AssetSource('sounds/good_answer.wav'));
  }

  Future<void> badAnswerPlaySound() async {
    await player.play(AssetSource('sounds/bad_answer.wav'));
  }

  void _checkAnswers() {
    setState(() {
      _hasChecked = true;
    });

    // Kullanıcının oluşturduğu sıra doğru mu kontrol et
    bool isCorrect = true;
    for (int i = 0; i < sentences.length; i++) {
      if (sentences[i] != correctOrder[i]) {
        isCorrect = false;
        break;
      }
    }

    if (isCorrect) {
      _correctAnswers++;
      goodAnswerPlaySound();
    } else {
      _wrongAnswers++;
      badAnswerPlaySound();
    }
  }

  Color? _getBorderColor(int index) {
    if (!_hasChecked) return null;

    // Kontrol edildikten sonra, her cümlenin doğru pozisyonda olup olmadığını kontrol et
    bool isCorrectPosition = sentences[index] == correctOrder[index];
    return isCorrectPosition ? Colors.green : Colors.red;
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      setState(() {
        _currentStep++;
        _hasChecked = false;
        _selectedIndex = null;
        _loadCurrentQuestion();
      });
    } else {
      _showResultsDialog();
    }
  }

  void _showResultsDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: ThemeConstants.darkGreyColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
          title: Text(
            'Oyun Bitti!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: "OpenDyslexic",
              color: ThemeConstants.creamColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 48),
                      SizedBox(height: 8),
                      Text(
                        '$_correctAnswers',
                        style: TextStyle(
                          fontFamily: "OpenDyslexic",
                          fontSize: 32,
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Doğru',
                        style: TextStyle(
                          fontFamily: "OpenDyslexic",
                          color: ThemeConstants.creamColor,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Icon(Icons.cancel, color: Colors.red, size: 48),
                      SizedBox(height: 8),
                      Text(
                        '$_wrongAnswers',
                        style: TextStyle(
                          fontFamily: "OpenDyslexic",
                          fontSize: 32,
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Yanlış',
                        style: TextStyle(
                          fontFamily: "OpenDyslexic",
                          color: ThemeConstants.creamColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: AuthButton(
                label: 'Tamam',
                onPressed: () async {
                  // Oyun sonucunu kaydet
                  await _gameService.saveGameResult(
                    gameId: 'sentence_detective',
                    correctCount: _correctAnswers,
                    wrongCount: _wrongAnswers,
                  );
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    context.go('/');
                  }
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _onSentenceTap(int index) {
    if (_hasChecked) return;

    setState(() {
      if (_selectedIndex == null) {
        // İlk cümle seçildi
        _selectedIndex = index;
      } else if (_selectedIndex == index) {
        // Aynı cümleye tekrar tıklandı, seçimi kaldır
        _selectedIndex = null;
      } else {
        // İki cümleyi yer değiştir
        final temp = sentences[_selectedIndex!];
        sentences[_selectedIndex!] = sentences[index];
        sentences[index] = temp;
        _selectedIndex = null;
      }
    });
  }

  Widget _buildStepContent() {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: ThemeConstants.creamColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'Cümleleri Doğru Sıraya Koy',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: "OpenDyslexic",
                    fontSize: 16,
                    color: ThemeConstants.darkGreyColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 40),
              ...List.generate(sentences.length, (index) {
                final borderColor = _getBorderColor(index);
                final isSelected = _selectedIndex == index;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: GestureDetector(
                    onTap: () => _onSentenceTap(index),
                    child: _buildSentenceContainer(
                      sentences[index],
                      borderColor,
                      isSelected,
                      index + 1,
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSentenceContainer(
    String sentence,
    Color? borderColor,
    bool isSelected,
    int number,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        border: isSelected
            ? Border.all(color: ThemeConstants.creamColor, width: 3)
            : (borderColor != null
                  ? Border.all(color: borderColor, width: 3)
                  : null),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(29),
        child: GlassEffectContainer(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: ThemeConstants.creamColor.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$number',
                      style: TextStyle(
                        fontFamily: "OpenDyslexic",
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: ThemeConstants.creamColor,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    sentence,
                    style: TextStyle(
                      fontFamily: "OpenDyslexic",
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ThemeConstants.darkGreyColor,
        leading: IconButton(
          onPressed: () => context.go('/'),
          icon: Icon(Icons.close, color: ThemeConstants.creamColor),
        ),
        title: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: _totalSteps > 0 ? _currentStep / _totalSteps : 0,
                backgroundColor: ThemeConstants.creamColor.withOpacity(0.3),
                valueColor: AlwaysStoppedAnimation<Color>(
                  ThemeConstants.creamColor,
                ),
                minHeight: 12,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: ThemeConstants.creamColor),
                  SizedBox(height: 16),
                  Text(
                    'Sorular hazırlanıyor...',
                    style: TextStyle(
                      fontFamily: "OpenDyslexic",
                      fontSize: 18,
                      color: ThemeConstants.creamColor,
                    ),
                  ),
                ],
              ),
            )
          : _questions.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: ThemeConstants.creamColor,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Sorular yüklenemedi',
                    style: TextStyle(
                      fontFamily: "OpenDyslexic",
                      fontSize: 18,
                      color: ThemeConstants.creamColor,
                    ),
                  ),
                  SizedBox(height: 16),
                  AuthButton(
                    label: 'Ana Sayfaya Dön',
                    onPressed: () => context.go('/'),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(child: _buildStepContent()),
                Padding(
                  padding: const EdgeInsets.all(50.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: AuthButton(
                          label: !_hasChecked
                              ? "Kontrol Et"
                              : (_currentStep == _totalSteps - 1
                                    ? "Bitir"
                                    : "Devam Et"),
                          onPressed: !_hasChecked ? _checkAnswers : _nextStep,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
