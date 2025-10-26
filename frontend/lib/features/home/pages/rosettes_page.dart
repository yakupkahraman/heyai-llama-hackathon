import 'package:flutter/material.dart';
import 'package:heylex/core/components/glass_effect_container.dart';
import 'package:heylex/core/theme/theme_constants.dart';

class Rosette {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  Rosette({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}

class RosettesPage extends StatefulWidget {
  const RosettesPage({super.key});

  @override
  State<RosettesPage> createState() => _RosettesPageState();
}

class _RosettesPageState extends State<RosettesPage> {
  int _currentRosetteIndex = 0;
  final PageController _pageController = PageController();

  final List<Rosette> _rosettes = [
    Rosette(
      icon: Icons.military_tech_rounded,
      title: 'Aktif Kullanıcı',
      description:
          'Bu rozeti çok uzun bir süre boyunca aktif kaldığınız için kazandınız.',
      color: ThemeConstants.orangeColor,
    ),
    Rosette(
      icon: Icons.workspace_premium_rounded,
      title: 'İlk Adım',
      description:
          'İlk oyununuzu tamamladığınız için bu rozeti kazandınız. Harika bir başlangıç!',
      color: Colors.blue,
    ),
    Rosette(
      icon: Icons.emoji_events_rounded,
      title: 'Şampiyon',
      description: 'Tüm oyunları %100 başarı ile tamamladınız. Muhteşemsiniz!',
      color: Colors.amber,
    ),
    Rosette(
      icon: Icons.favorite_rounded,
      title: 'Azimli',
      description:
          '30 gün üst üste çalışma yaptınız. Kararlılığınız örnek teşkil ediyor!',
      color: Colors.red,
    ),
    Rosette(
      icon: Icons.stars_rounded,
      title: 'Yıldız Öğrenci',
      description:
          'Tüm egzersizleri mükemmel puanla tamamladınız. Siz bir yıldızsınız!',
      color: Colors.purple,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        centerTitle: true,
        title: Text(
          'Rozetlerim',
          style: TextStyle(
            fontFamily: "OpenDyslexic",
            color: ThemeConstants.creamColor,
          ),
        ),
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GlassEffectContainer(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 8.0,
                    ),
                    child: Column(
                      children: [
                        Text(
                          "78",
                          style: TextStyle(
                            fontFamily: "OpenDyslexic",
                            fontSize: 24,
                            color: ThemeConstants.orangeColor,
                          ),
                        ),
                        Text(
                          "Day Streak",
                          style: TextStyle(
                            fontFamily: "OpenDyslexic",
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 16),
                GlassEffectContainer(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 8.0,
                    ),
                    child: Column(
                      children: [
                        Text(
                          "2",
                          style: TextStyle(
                            fontFamily: "OpenDyslexic",
                            fontSize: 24,
                            color: ThemeConstants.orangeColor,
                          ),
                        ),
                        Text(
                          "Badges",
                          style: TextStyle(
                            fontFamily: "OpenDyslexic",
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 100),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 64,
                  child: IconButton(
                    onPressed: _currentRosetteIndex > 0
                        ? () {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        : null,
                    icon: Icon(
                      Icons.chevron_left_rounded,
                      size: 64,
                      color: _currentRosetteIndex > 0
                          ? ThemeConstants.creamColor
                          : Colors.grey.shade700,
                    ),
                  ),
                ),
                SizedBox(
                  width: 200,
                  height: 200,
                  child: PageView.builder(
                    controller: _pageController,

                    itemCount: _rosettes.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentRosetteIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _rosettes[index].icon,
                            color: _rosettes[index].color,
                            size: 112,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _rosettes[index].title,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: "OpenDyslexic",
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: _rosettes[index].color,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                SizedBox(
                  width: 64,
                  child: IconButton(
                    onPressed: _currentRosetteIndex < _rosettes.length - 1
                        ? () {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        : null,
                    icon: Icon(
                      Icons.chevron_right_rounded,
                      size: 64,
                      color: _currentRosetteIndex < _rosettes.length - 1
                          ? ThemeConstants.creamColor
                          : Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Sayfa göstergesi
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _rosettes.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentRosetteIndex == index
                        ? ThemeConstants.orangeColor
                        : Colors.grey.shade700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                _rosettes[_currentRosetteIndex].description,
                textAlign: TextAlign.center,
                style: const TextStyle(fontFamily: "OpenDyslexic"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
