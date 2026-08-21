import 'package:flutter/material.dart';
import '../data/colors_data.dart';
import '../models/color_model.dart';
import '../services/app_state.dart';
import '../services/tts_service.dart';
import '../widgets/game_widgets.dart';

class LearnScreen extends StatefulWidget {
  final AppState app;

  const LearnScreen({super.key, required this.app});

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  final PageController _controller = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _controller.dispose();
    TtsService.stop();
    super.dispose();
  }

  void _goTo(int index) {
    _controller.animateToPage(
      index,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = widget.app;
    return GameScaffold(
      app: app,
      title: app.t('learn'),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: ColorData.colors.length,
              onPageChanged: (i) => setState(() => _currentIndex = i),
              itemBuilder: (context, index) {
                final colorItem = ColorData.colors[index];
                return _LearnCard(
                  colorItem: colorItem,
                  app: app,
                  onTap: () => _speak(colorItem, app),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _ArrowButton(
                  icon: Icons.chevron_left,
                  enabled: _currentIndex > 0,
                  onTap: () => _goTo(_currentIndex - 1),
                ),
                _DotIndicator(
                  current: _currentIndex,
                  count: ColorData.colors.length,
                ),
                _ArrowButton(
                  icon: Icons.chevron_right,
                  enabled: _currentIndex < ColorData.colors.length - 1,
                  onTap: () => _goTo(_currentIndex + 1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _speak(ColorItem colorItem, AppState app) {
    final name = colorItem.nameForLanguageCode(app.langCode);
    TtsService.speak(name, app.langCode);
  }
}

class _LearnCard extends StatelessWidget {
  final ColorItem colorItem;
  final AppState app;
  final VoidCallback onTap;

  const _LearnCard({
    required this.colorItem,
    required this.app,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = colorItem.color.computeLuminance() < 0.5;
    final name = colorItem.nameForLanguageCode(app.langCode);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: colorItem.color,
                  borderRadius: BorderRadius.circular(32),
                  border: colorItem.id == 'white'
                      ? Border.all(color: Colors.black26, width: 2)
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: colorItem.color.withValues(alpha: 0.6),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      colorItem.icon,
                      size: 80,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF37474F),
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                icon: const Icon(
                  Icons.volume_up,
                  size: 36,
                  color: Color(0xFF26A69A),
                ),
                tooltip: app.t('tap_sound'),
                onPressed: onTap,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ArrowButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _ArrowButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: enabled ? const Color(0xFF26A69A) : Colors.white38,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: enabled ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, size: 36, color: Colors.white),
        ),
      ),
    );
  }
}

class _DotIndicator extends StatelessWidget {
  final int current;
  final int count;

  const _DotIndicator({required this.current, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(count, (i) {
        final active = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: active ? 24 : 10,
          height: 10,
          decoration: BoxDecoration(
            color: active ? const Color(0xFF26A69A) : Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
        );
      }),
    );
  }
}
