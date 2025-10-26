import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:heylex/core/theme/theme_constants.dart';
import 'package:heylex/features/auth/components/auth_button.dart';
import 'package:heylex/core/components/glass_effect_container.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:heylex/features/games/service/game_service.dart';
import 'package:heylex/features/games/service/ai__game_service.dart';
import 'package:heylex/features/auth/providers/user_provider.dart';
import 'package:provider/provider.dart';

class SoundHunterGame extends StatefulWidget {
  const SoundHunterGame({super.key});

  @override
  State<SoundHunterGame> createState() => _SoundHunterState();
}

class _SoundHunterState extends State<SoundHunterGame> {
  int _currentStep = 0;
  int _totalSteps = 5;

  int _correctAnswers = 0;
  int _wrongAnswers = 0;

  List<SoundHunterQuestion> _questions = [];
  bool _isLoading = true;

  List<int> _selectedIndices = [];
  bool _hasChecked = false;

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
      final response = await _aiGameService.getSoundHunterQuestions(
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

  String get question {
    if (_questions.isEmpty || _currentStep >= _questions.length) return '';
    final questionText = _questions[_currentStep].question;
    final match = RegExp(r"'(.+?)'").firstMatch(questionText);
    return match?.group(1) ?? '';
  }

  List<String> get options {
    if (_questions.isEmpty || _currentStep >= _questions.length) return [];
    return _questions[_currentStep].options;
  }

  List<int> get correctAnswers {
    if (_questions.isEmpty || _currentStep >= _questions.length) return [];
    return _questions[_currentStep].correctAnswers;
  }

  Future<void> goodAnswerPlaySound() async {
    await player.play(AssetSource('sounds/good_answer.wav'));
  }

  Future<void> badAnswerPlaySound() async {
    await player.play(AssetSource('sounds/bad_answer.wav'));
  }

  void _toggleSelection(int index) {
    if (_hasChecked) return; // Kontrol edildikten sonra seçim yapılamaz

    setState(() {
      if (_selectedIndices.contains(index)) {
        _selectedIndices.remove(index);
      } else {
        _selectedIndices.add(index);
      }
    });
  }

  void _checkAnswers() {
    if (_selectedIndices.isEmpty) return;

    setState(() {
      _hasChecked = true;
    });

    final selectedSet = Set<int>.from(_selectedIndices);
    final correctSet = Set<int>.from(correctAnswers);

    if (selectedSet.length == correctSet.length &&
        selectedSet.containsAll(correctSet) &&
        correctSet.containsAll(selectedSet)) {
      _correctAnswers++;
      goodAnswerPlaySound();
    } else {
      _wrongAnswers++;
      badAnswerPlaySound();
    }
  }

  bool _isAnswerCorrect(int index) {
    return correctAnswers.contains(index);
  }

  Color? _getBorderColor(int index) {
    final isSelected = _selectedIndices.contains(index);

    if (!isSelected) return null;

    if (!_hasChecked) {
      return ThemeConstants.creamColor;
    }

    // Kontrol edildikten sonra
    return _isAnswerCorrect(index) ? Colors.green : Colors.red;
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      setState(() {
        _currentStep++;
        _selectedIndices = [];
        _hasChecked = false;
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
                    gameId: 'sound_hunter',
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

  Widget _buildStepContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              SizedBox(
                height: 200,
                child: Image.asset(
                  'assets/images/sound_hunter_cat.png',
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: 16),

              Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 30, right: 30),
                    child: Container(
                      width: 100,
                      height: 60,
                      decoration: BoxDecoration(
                        color: ThemeConstants.creamColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          '$question',
                          style: TextStyle(
                            fontFamily: "OpenDyslexic",
                            fontSize: 24,
                            color: ThemeConstants.darkGreyColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),

                  //ses tuşu
                  Positioned(
                    right: 0,
                    top: 0,
                    child: IconButton(
                      onPressed: () {
                        FlutterTts flutterTts = FlutterTts();
                        flutterTts.speak(question);
                      },
                      style: IconButton.styleFrom(
                        backgroundColor: ThemeConstants.darkGreyColor,
                        shape: CircleBorder(),
                      ),
                      icon: Icon(
                        Icons.volume_up,
                        color: ThemeConstants.creamColor,
                        size: 32,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 2,
              ),
              itemCount: options.length,
              itemBuilder: (context, index) {
                final borderColor = _getBorderColor(index);

                return GestureDetector(
                  onTap: () => _toggleSelection(index),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32),
                      border: borderColor != null
                          ? Border.all(color: borderColor, width: 3)
                          : null,
                    ),
                    child: GlassEffectContainer(
                      child: Center(
                        child: Text(
                          options[index],
                          style: TextStyle(
                            fontFamily: "OpenDyslexic",
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
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
                          onPressed: !_hasChecked
                              ? (_selectedIndices.isNotEmpty
                                    ? _checkAnswers
                                    : null)
                              : _nextStep,
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
