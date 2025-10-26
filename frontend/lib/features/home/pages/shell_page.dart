import 'package:flutter/material.dart';
import 'package:heylex/core/components/glass_effect_container.dart';
import 'package:heylex/features/home/components/navbar_item.dart';
import 'package:go_router/go_router.dart';
import 'package:heylex/features/home/pages/analysis_page.dart';
import 'package:heylex/features/home/pages/home_page.dart';
import 'package:heylex/features/home/pages/rosettes_page.dart';
import 'package:heylex/features/home/pages/profile_page.dart';

class ShellPage extends StatefulWidget {
  final Widget child;

  const ShellPage({super.key, required this.child});

  @override
  State<ShellPage> createState() => _ShellPageState();
}

class _ShellPageState extends State<ShellPage> {
  int _selectedIndex = 0;
  late PageController _pageController;

  // State korunması için sayfaları burada tanımla
  static const List<Widget> _pages = [
    HomePage(),
    AnalysisPage(),
    RosettesPage(),
    ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // URL'e göre index'i güncelle
    final location = GoRouterState.of(context).matchedLocation;
    int newIndex = 0;
    switch (location) {
      case '/':
        newIndex = 0;
        break;
      case '/analysis':
        newIndex = 1;
        break;
      case '/rosettes':
        newIndex = 2;
        break;
      case '/profile':
        newIndex = 3;
        break;
    }

    if (_selectedIndex != newIndex) {
      setState(() {
        _selectedIndex = newIndex;
      });

      // PageController'ı güncelle
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          newIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      body: Stack(
        children: [
          // PageView ile sayfaları yönet
          PageView(
            controller: _pageController,
            physics:
                const NeverScrollableScrollPhysics(), // Sadece programmatik geçiş
            children: _pages,
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 30, left: 36, right: 36),
        child: GlassEffectContainer(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(36),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: [
                  NavItem(
                    index: 0,
                    unSelectedIcon: Icons.home,
                    selectedIcon: Icons.home_filled,
                    isSelected: _selectedIndex == 0,
                    onTap: () => _onItemTapped(0, '/'),
                  ),
                  NavItem(
                    index: 1,
                    unSelectedIcon: Icons.analytics_outlined,
                    selectedIcon: Icons.analytics,
                    isSelected: _selectedIndex == 1,
                    onTap: () => _onItemTapped(1, '/analysis'),
                  ),
                  NavItem(
                    index: 2,
                    unSelectedIcon: Icons.military_tech_outlined,
                    selectedIcon: Icons.military_tech,
                    isSelected: _selectedIndex == 2,
                    onTap: () => _onItemTapped(2, '/rosettes'),
                  ),
                  NavItem(
                    index: 3,
                    unSelectedIcon: Icons.person_outline,
                    selectedIcon: Icons.person,
                    isSelected: _selectedIndex == 3,
                    onTap: () => _onItemTapped(3, '/profile'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onItemTapped(int index, String path) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    GoRouter.of(context).go(path);
  }
}
