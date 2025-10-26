import 'package:flutter/material.dart';
import 'package:heylex/core/components/glass_effect_container.dart';
import 'package:heylex/core/theme/theme_constants.dart';
import 'package:heylex/features/auth/service/auth_service.dart';
import 'package:heylex/features/home/components/game_info_container.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _userName = '';

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    try {
      final name = await AuthService().getCurrentUserName();

      setState(() {
        _userName = name ?? 'Kullanıcı';
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _userName = 'Kullanıcı';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "HeyLex",
          style: TextStyle(
            fontFamily: "OpenDyslexic",
            color: ThemeConstants.creamColor,
          ),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GlassEffectContainer(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "SELAM ${_userName.toUpperCase()},",
                          style: TextStyle(
                            fontFamily: "OpenDyslexic",
                            color: ThemeConstants.creamColor,
                          ),
                        ),
                        TextSpan(
                          text:
                              " cevapların doğrultusunda öncelik sıralamasına göre senin için hazırladığımız eğitimler aşağıdadır.",
                          style: TextStyle(
                            fontFamily: "OpenDyslexic",
                            fontSize: 13,
                            color: ThemeConstants.creamColor.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 8),
            GameInfoContainer(
              title: "Ses Avcısı",
              gameId: "sound_hunter",
              typeIcon: Icons.hearing,
              typeContent: 'Fonolojik Disleksi',
            ),
            GameInfoContainer(
              title: "Doğru mu Yanlış mı?",
              gameId: "true_or_false",
              typeIcon: Icons.search,
              typeContent: 'Yüzey Disleksi',
            ),
            GameInfoContainer(
              title: "Karışık Kelimeler",
              gameId: "jumbled_words",
              typeIcon: Icons.visibility,
              typeContent: 'Görsel / Dikkatsel Disleksi',
            ),
            GameInfoContainer(
              title: "Cümle Detektifi",
              gameId: "sentence_detective",
              typeIcon: Icons.autorenew,
              typeContent: 'Akıcılık Disleksisi',
            ),
            SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
