import 'dart:math';
import 'package:flutter/material.dart';
import '../data/colors_data.dart';
import '../services/app_state.dart';
import '../services/tts_service.dart';
import '../widgets/game_widgets.dart';

class _Region {
  final String id;
  final List<Offset> points;
  Color? fill;

  _Region(this.id, this.points);
}

class _Picture {
  final String nameTr;
  final String nameEn;
  final String nameFr;
  final String nameKu;
  final List<_Region> regions;

  _Picture({
    required this.nameTr,
    required this.nameEn,
    required this.nameFr,
    required this.nameKu,
    required this.regions,
  });

  String nameForLanguageCode(String languageCode) {
    if (languageCode.startsWith('tr')) return nameTr;
    if (languageCode.startsWith('fr')) return nameFr;
    if (languageCode.startsWith('ku')) return nameKu;
    return nameEn;
  }
}

const double _vw = 200;
const int _coloringMaxScore = 180;

int coloringScoreFor(Duration elapsed) {
  return (_coloringMaxScore - elapsed.inSeconds)
      .clamp(0, _coloringMaxScore)
      .toInt();
}

class ColoringScreen extends StatefulWidget {
  final AppState app;

  const ColoringScreen({super.key, required this.app});

  @override
  State<ColoringScreen> createState() => _ColoringScreenState();
}

class _ColoringScreenState extends State<ColoringScreen> {
  late List<_Picture> _pictures;
  int _pictureIndex = 0;
  Color _selectedColor = const Color(0xFFE53935);
  int _coloredCount = 0;
  bool _doneShown = false;
  final Stopwatch _stopwatch = Stopwatch();

  @override
  void initState() {
    super.initState();
    _pictures = _buildPictures();
    _stopwatch.start();
  }

  List<_Picture> _buildPictures() {
    return [
      _Picture(
        nameTr: 'Ev',
        nameEn: 'House',
        nameFr: 'Maison',
        nameKu: 'Mal',
        regions: [
          _Region('wall', [p(50, 90), p(150, 90), p(150, 180), p(50, 180)]),
          _Region('roof', [p(40, 90), p(100, 35), p(160, 90)]),
          _Region('door', [p(85, 130), p(115, 130), p(115, 180), p(85, 180)]),
          _Region('win1', [p(60, 102), p(83, 102), p(83, 128), p(60, 128)]),
          _Region('win2', [p(117, 102), p(140, 102), p(140, 128), p(117, 128)]),
          _Region('chim', [p(132, 70), p(148, 70), p(148, 92), p(132, 92)]),
        ],
      ),
      _Picture(
        nameTr: 'Ağaç',
        nameEn: 'Tree',
        nameFr: 'Arbre',
        nameKu: 'Dar',
        regions: [
          _Region('foliage', _circle(100, 100, 55, 24)),
          _Region('trunk', [p(90, 135), p(110, 135), p(110, 180), p(90, 180)]),
          _Region('ground', [p(0, 185), p(200, 185), p(200, 200), p(0, 200)]),
          _Region('apple1', [p(72, 100), p(84, 100), p(84, 112), p(72, 112)]),
          _Region('apple2', [p(118, 88), p(130, 88), p(130, 100), p(118, 100)]),
        ],
      ),
      _Picture(
        nameTr: 'Balık',
        nameEn: 'Fish',
        nameFr: 'Poisson',
        nameKu: 'Masî',
        regions: [
          _Region('body', [
            p(45, 110),
            p(90, 85),
            p(150, 85),
            p(170, 110),
            p(150, 135),
            p(90, 135),
          ]),
          _Region('tail', [p(165, 90), p(195, 70), p(195, 150), p(165, 130)]),
          _Region('eye', [p(75, 100), p(92, 100), p(92, 115), p(75, 115)]),
          _Region('fin', [p(120, 100), p(140, 85), p(145, 110)]),
          _Region('bubble1', _circle(170, 45, 12, 16)),
          _Region('bubble2', _circle(190, 65, 8, 12)),
        ],
      ),
      _Picture(
        nameTr: 'Güneş',
        nameEn: 'Sun',
        nameFr: 'Soleil',
        nameKu: 'Roj',
        regions: [
          _Region('sky', [p(0, 0), p(200, 0), p(200, 200), p(0, 200)]),
          _Region('sun', _circle(100, 100, 55, 28)),
          _Region('cloud1', _ellipse(30, 40, 45, 20)),
          _Region('cloud2', _ellipse(140, 25, 50, 18)),
        ],
      ),
      _Picture(
        nameTr: 'Çiçek',
        nameEn: 'Flower',
        nameFr: 'Fleur',
        nameKu: 'Kulîlk',
        regions: [
          _Region('stem', [p(95, 120), p(105, 120), p(105, 185), p(95, 185)]),
          _Region('petal1', _circle(100, 55, 20, 20)),
          _Region('petal2', _circle(75, 75, 20, 20)),
          _Region('petal3', _circle(125, 75, 20, 20)),
          _Region('petal4', _circle(85, 100, 20, 20)),
          _Region('petal5', _circle(115, 100, 20, 20)),
          _Region('center', _circle(100, 80, 16, 16)),
          _Region('leaf', [p(103, 130), p(130, 112), p(140, 122), p(122, 145)]),
        ],
      ),
      _Picture(
        nameTr: 'Balon',
        nameEn: 'Balloon',
        nameFr: 'Ballon',
        nameKu: 'Balon',
        regions: [
          _Region('ball', _ellipse(100, 70, 65, 70)),
          _Region('string1', [p(95, 135), p(85, 185), p(92, 185), p(100, 138)]),
          _Region('string2', [
            p(105, 138),
            p(112, 185),
            p(119, 185),
            p(110, 136),
          ]),
        ],
      ),
    ];
  }

  @override
  void dispose() {
    _stopwatch.stop();
    TtsService.stop();
    super.dispose();
  }

  Offset p(double x, double y) => Offset(x / _vw, y / _vw);

  List<Offset> _circle(
    double cx,
    double cy,
    double rx,
    double ry, [
    int segments = 28,
  ]) {
    final pts = <Offset>[];
    for (var i = 0; i < segments; i++) {
      final a = i / segments * 2 * pi;
      pts.add(p(cx + rx * cos(a), cy + ry * sin(a)));
    }
    return pts;
  }

  List<Offset> _ellipse(double cx, double cy, double rx, double ry) =>
      _circle(cx, cy, rx, ry);

  int get _totalRegions => _pictures[_pictureIndex].regions.length;

  void _paint(Offset local) {
    final pic = _pictures[_pictureIndex];
    for (final r in pic.regions.reversed) {
      if (_pointInPolygon(local, r.points)) {
        setState(() {
          final wasColored = r.fill != null;
          r.fill = _selectedColor;
          if (!wasColored) _coloredCount++;
        });
        if (!_doneShown && _coloredCount == _totalRegions) {
          _doneShown = true;
          TtsService.speak(widget.app.t('great'), widget.app.langCode);
          _showDone();
        }
        return;
      }
    }
  }

  bool _pointInPolygon(Offset p, List<Offset> polygon) {
    var inside = false;
    for (var i = 0, j = polygon.length - 1; i < polygon.length; j = i++) {
      final a = polygon[i];
      final b = polygon[j];
      if ((a.dy > p.dy) != (b.dy > p.dy) &&
          p.dx < (b.dx - a.dx) * (p.dy - a.dy) / (b.dy - a.dy) + a.dx) {
        inside = !inside;
      }
    }
    return inside;
  }

  void _showDone() {
    _stopwatch.stop();
    final elapsed = _stopwatch.elapsed;
    final score = coloringScoreFor(elapsed);
    final stars = AppState.starsForScore(score, _coloringMaxScore);
    final isRecord = widget.app.recordScore(GameIds.coloring, score, stars);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          widget.app.t('congrats'),
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.brush, size: 72, color: Color(0xFF1E88E5)),
            const SizedBox(height: 12),
            StarsRow(stars: stars),
            const SizedBox(height: 8),
            Text('${widget.app.t('score')}: $score'),
            Text('${widget.app.t('time')}: ${_formatDuration(elapsed)}'),
            Text(
              '${widget.app.t('best')}: ${widget.app.bestScore(GameIds.coloring)}',
            ),
            if (isRecord) Text(widget.app.t('new_record')),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          RoundButton(
            label: widget.app.t('choose_another_game'),
            icon: Icons.apps,
            color: const Color(0xFF5C6BC0),
            onTap: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
          ),
          RoundButton(
            label: widget.app.t('next'),
            icon: Icons.arrow_forward,
            color: const Color(0xFF26A69A),
            onTap: () {
              Navigator.of(ctx).pop();
              if (mounted) {
                setState(() {
                  _changePicture(1);
                });
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = widget.app;
    final pic = _pictures[_pictureIndex];
    final name = pic.nameForLanguageCode(app.langCode);

    return GameScaffold(
      app: app,
      title: '${app.t('coloring')} - $name',
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final size = constraints.biggest.shortestSide;
                  return Center(
                    child: GestureDetector(
                      onTapDown: (d) => _paint(d.localPosition / size),
                      child: Container(
                        width: size,
                        height: size,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.black12, width: 2),
                        ),
                        child: CustomPaint(
                          key: const ValueKey('coloring_canvas'),
                          painter: _PicturePainter(pic.regions),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          _Palette(
            selected: _selectedColor,
            onSelect: (c) => setState(() => _selectedColor = c),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 12, top: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _PictureSwitcher(
                  icon: Icons.chevron_left,
                  onTap: () => setState(() => _changePicture(-1)),
                ),
                const SizedBox(width: 16),
                Text(
                  app.t('paint'),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF37474F),
                  ),
                ),
                const SizedBox(width: 16),
                _PictureSwitcher(
                  icon: Icons.chevron_right,
                  onTap: () => setState(() => _changePicture(1)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _changePicture(int direction) {
    for (final region in _pictures[_pictureIndex].regions) {
      region.fill = null;
    }
    _pictureIndex =
        (_pictureIndex + direction + _pictures.length) % _pictures.length;
    for (final region in _pictures[_pictureIndex].regions) {
      region.fill = null;
    }
    _coloredCount = 0;
    _doneShown = false;
    _stopwatch
      ..reset()
      ..start();
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

class _PicturePainter extends CustomPainter {
  final List<_Region> regions;

  _PicturePainter(this.regions);

  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = Colors.black38;

    for (final r in regions) {
      final path = Path()
        ..addPolygon(scaleNormalizedPoints(r.points, size), true);
      if (r.fill != null) {
        fillPaint.color = r.fill!;
        canvas.drawPath(path, fillPaint);
      }
      canvas.drawPath(path, borderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _PicturePainter oldDelegate) => true;
}

List<Offset> scaleNormalizedPoints(List<Offset> points, Size size) {
  return points
      .map((point) => Offset(point.dx * size.width, point.dy * size.height))
      .toList();
}

class _Palette extends StatelessWidget {
  final Color selected;
  final ValueChanged<Color> onSelect;

  const _Palette({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(8),
        itemCount: ColorData.colors.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final c = ColorData.colors[i];
          final isSelected = c.color.toARGB32() == selected.toARGB32();
          return GestureDetector(
            onTap: () => onSelect(c.color),
            child: Container(
              width: 44,
              decoration: BoxDecoration(
                color: c.color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? const Color(0xFF37474F) : Colors.black12,
                  width: isSelected ? 4 : 1,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PictureSwitcher extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _PictureSwitcher({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF00897B),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, color: Colors.white, size: 26),
        ),
      ),
    );
  }
}
