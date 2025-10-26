import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:heylex/core/components/glass_effect_container.dart';
import 'package:heylex/core/theme/theme_constants.dart';

class MyPlans extends StatelessWidget {
  const MyPlans({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Planım',
          style: TextStyle(fontFamily: "OpenDyslexic"),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: IconButton(
          icon: Icon(Icons.chevron_left, color: ThemeConstants.creamColor),
          onPressed: () {
            context.pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              GlassEffectContainer(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Premium Plan',
                        style: TextStyle(
                          fontFamily: "OpenDyslexic",
                          fontSize: 18,
                          color: ThemeConstants.orangeColor,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Mevcut planınız premium plandır. ',
                        style: TextStyle(
                          fontFamily: "OpenDyslexic",
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        '\n -Ai Analizleri ve Kişiselleştirilmiş Öneriler\n \n -Tüm Mini Oyunlara Erişim \n\n -Her Oyun için Ayda 100 Tur Hakkı ',
                        style: TextStyle(
                          fontFamily: "OpenDyslexic",
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.start,
                      ),
                      /*
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {},
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                            ThemeConstants.orangeColor,
                          ),
                        ),
                        child: Text(
                          "Üyelik Planları",
                          style: TextStyle(
                            fontFamily: "OpenDyslexic",
                            fontSize: 12,
                            color: ThemeConstants.creamColor,
                          ),
                        ),
                      ),*/
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              GlassEffectContainer(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Free Plan',
                        style: TextStyle(
                          fontFamily: "OpenDyslexic",
                          fontSize: 18,
                          color: ThemeConstants.orangeColor,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        ' -Mini Oyunlara Sınırlı Erişim \n\n -Her Oyun için Ayda 20 Tur Hakkı ',
                        style: TextStyle(
                          fontFamily: "OpenDyslexic",
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.start,
                      ),
                      /*
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {},
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                            ThemeConstants.orangeColor,
                          ),
                        ),
                        child: Text(
                          "Üyelik Planları",
                          style: TextStyle(
                            fontFamily: "OpenDyslexic",
                            fontSize: 12,
                            color: ThemeConstants.creamColor,
                          ),
                        ),
                      ),*/
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              GlassEffectContainer(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Pro Plan',
                        style: TextStyle(
                          fontFamily: "OpenDyslexic",
                          fontSize: 18,
                          color: ThemeConstants.orangeColor,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        '\n -Ai Analizleri ve Kişiselleştirilmiş Öneriler\n \n -Profesyonellerle Eşleşip Görüşme İmkanı \n\n -Kurumsal Arayüz: Ekip Yönetimi, Çoklu Kullanıcı ve Raporlama \n\n -Öncelikli Destek ve Erken Özellikler \n\n -Oyunlara Sınırsız Erişim',
                        style: TextStyle(
                          fontFamily: "OpenDyslexic",
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.start,
                      ),

                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: null,
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                            const Color.fromARGB(139, 255, 138, 66),
                          ),
                        ),
                        child: Text(
                          "Çok Yakında",
                          style: TextStyle(
                            fontFamily: "OpenDyslexic",
                            fontSize: 12,
                            color: ThemeConstants.creamColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
