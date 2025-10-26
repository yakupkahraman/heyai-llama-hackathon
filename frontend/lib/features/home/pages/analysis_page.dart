import 'package:flutter/material.dart';
import 'package:heylex/core/components/glass_effect_container.dart';
import 'package:heylex/core/theme/theme_constants.dart';
import 'package:heylex/features/home/components/analys_chart.dart';
import 'package:heylex/features/home/service/ai_analysis_service.dart';
import 'package:heylex/features/games/service/game_service.dart';
import 'package:heylex/features/auth/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class AnalysisPage extends StatefulWidget {
  const AnalysisPage({super.key});

  @override
  State<AnalysisPage> createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage> {
  final AiAnalysisService _analysisService = AiAnalysisService();
  final GameService _gameService = GameService();
  String? _analysis;
  bool _isLoading = true;
  String? _error;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _loadAnalysis();
  }

  Future<void> _loadAnalysis() async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      // İstatistikleri al
      final statistics = await _gameService.getUserStatistics();

      // Analizi al
      final analysis = await _analysisService.getAnalysis(
        ageGroup: userProvider.ageGroup ?? '',
        hardArea: userProvider.hardArea ?? '',
        readingGoal: userProvider.readingGoal ?? '',
        diagnosisTime: userProvider.diagnosisTime ?? '',
        motivatingGames: userProvider.motivatingGames ?? '',
        workingWithProfessional: userProvider.workingWithProfessional ?? '',
        userStatistics: statistics,
      );

      if (mounted) {
        setState(() {
          _analysis = analysis;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: const Text(
          'Analizlerim',
          style: TextStyle(color: ThemeConstants.creamColor),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              GlassEffectContainer(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _isLoading
                      ? Shimmer.fromColors(
                          baseColor: ThemeConstants.creamColor,
                          highlightColor: ThemeConstants.creamColor.withOpacity(
                            0.5,
                          ),
                          child: Text(
                            'LexAI özetinizi hazırlıyor...',
                            style: TextStyle(
                              fontFamily: "OpenDyslexic",
                              fontSize: 16,
                              color: ThemeConstants.creamColor,
                            ),
                          ),
                        )
                      : _error != null
                      ? Column(
                          children: [
                            Text(
                              'Analiz yüklenemedi',
                              style: TextStyle(
                                fontFamily: "OpenDyslexic",
                                fontSize: 16,
                                color: Colors.red,
                              ),
                            ),
                            SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _isLoading = true;
                                  _error = null;
                                });
                                _loadAnalysis();
                              },
                              child: Text('Tekrar Dene'),
                            ),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _analysis ?? '',
                              maxLines: _isExpanded ? null : 5,
                              overflow: _isExpanded
                                  ? TextOverflow.visible
                                  : TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: "OpenDyslexic",
                                fontSize: 16,
                                color: ThemeConstants.creamColor,
                              ),
                            ),
                            if ((_analysis?.length ?? 0) > 134)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _isExpanded = !_isExpanded;
                                    });
                                  },
                                  child: Text(
                                    _isExpanded
                                        ? 'Daha Az Göster'
                                        : 'Daha Fazla Göster',
                                    style: TextStyle(
                                      fontFamily: "OpenDyslexic",
                                      fontSize: 14,
                                      color: ThemeConstants.creamColor,
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                ),
              ),
              SizedBox(height: 16),

              //sound_hunter
              GlassEffectContainer(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Ses/Hece İşleme Becerisi",
                        style: TextStyle(
                          fontFamily: "OpenDyslexic",
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: ThemeConstants.creamColor,
                        ),
                      ),
                      SizedBox(height: 16),
                      AnalysChart(
                        gameId: 'sound_hunter',
                        chartColor: Colors.green,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),

              //true_or_false
              GlassEffectContainer(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Yazım ve Görsel Hafıza",
                        style: TextStyle(
                          fontFamily: "OpenDyslexic",
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: ThemeConstants.creamColor,
                        ),
                      ),
                      SizedBox(height: 16),
                      AnalysChart(
                        gameId: 'true_or_false',
                        chartColor: Colors.orange,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),

              //jumbled_words
              GlassEffectContainer(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Görsel Odak Gücü",
                        style: TextStyle(
                          fontFamily: "OpenDyslexic",
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: ThemeConstants.creamColor,
                        ),
                      ),
                      SizedBox(height: 16),
                      AnalysChart(
                        gameId: 'jumbled_words',
                        chartColor: Colors.pink,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),

              //sentence_detective
              GlassEffectContainer(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Okuma Akıcılığı",
                        style: TextStyle(
                          fontFamily: "OpenDyslexic",
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: ThemeConstants.creamColor,
                        ),
                      ),
                      SizedBox(height: 16),
                      AnalysChart(
                        gameId: 'sentence_detective',
                        chartColor: Colors.blue,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}
