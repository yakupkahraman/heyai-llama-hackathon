import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:heylex/core/components/glass_effect_circle_container.dart';
import 'package:heylex/core/components/glass_effect_container.dart';
import 'package:heylex/core/theme/theme_constants.dart';
import 'package:heylex/features/games/service/game_service.dart';

class GameInfoContainer extends StatefulWidget {
  const GameInfoContainer({
    super.key,
    required this.title,
    required this.gameId,
    required this.typeIcon,
    required this.typeContent,
  });

  final String title;
  final String gameId;
  final IconData typeIcon;
  final String typeContent;

  @override
  State<GameInfoContainer> createState() => _GameInfoContainerState();
}

class _GameInfoContainerState extends State<GameInfoContainer> {
  final GameService _gameService = GameService();
  int _playCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPlayCount();
  }

  Future<void> _loadPlayCount() async {
    try {
      final count = await _gameService.getGamePlayCount(widget.gameId);
      if (mounted) {
        setState(() {
          _playCount = count;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Stack(
        children: [
          Container(
            width: 350,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(32)),
            clipBehavior: Clip.hardEdge,
            child: Image.asset(
              'assets/images/${widget.gameId}.png',
              fit: BoxFit.fill,
            ),
          ),
          SizedBox(height: 8),
          Positioned(
            right: 6,
            top: 12,
            child: GlassEffectCircleContainer(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(
                      widget.typeContent,
                      style: TextStyle(
                        fontFamily: "OpenDyslexic",
                        color: ThemeConstants.creamColor,
                      ),
                    ),
                    content: Text(
                      'Bu oyun, belirtilen alanda egzersiz ve pratik yaparak düzenli pratik yapıldığında gelişmenizi sağlar.',
                      style: TextStyle(
                        fontFamily: "OpenDyslexic",
                        color: ThemeConstants.creamColor,
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          'Kapat',
                          style: TextStyle(
                            fontFamily: "OpenDyslexic",
                            color: ThemeConstants.creamColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 8.0,
                ),
                child: Icon(widget.typeIcon, color: Colors.white, size: 28),
              ),
            ),
          ),
          Positioned(
            right: 6,
            bottom: 12,
            child: InkWell(
              onTap: () {
                context.go('/games/${widget.gameId}');
              },
              child: GlassEffectCircleContainer(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4.0,
                    vertical: 4.0,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.green,
                        size: 46,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          //ilerleme çubuğu
          Positioned(
            left: 6,
            bottom: 12,
            child: GlassEffectContainer(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 8.0,
                ),
                child: _isLoading
                    ? SizedBox(
                        width: 100,
                        height: 20,
                        child: Center(
                          child: SizedBox(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: ThemeConstants.creamColor,
                            ),
                          ),
                        ),
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 100,
                            child: LinearProgressIndicator(
                              value: _playCount / 100,
                              backgroundColor: ThemeConstants.creamColor
                                  .withOpacity(0.3),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _playCount >= 100
                                    ? Colors.green
                                    : ThemeConstants.creamColor,
                              ),
                            ),
                          ),
                          SizedBox(width: 4),
                          Text(
                            '$_playCount/100',
                            style: TextStyle(
                              fontFamily: "OpenDyslexic",
                              fontSize: 12,
                              color: ThemeConstants.creamColor,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
