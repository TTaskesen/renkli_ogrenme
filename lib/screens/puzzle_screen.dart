import 'dart:math';
import 'package:flutter/material.dart';
import '../data/colors_data.dart';
import '../services/app_state.dart';
import '../services/tts_service.dart';
import '../widgets/game_widgets.dart';

enum ShapeKind { circle, triangle, square, star, heart, diamond }

class _Piece {
  final ShapeKind shape;
  final Color color;
  bool placed = false;

  _Piece(this.shape, this.color);
}

class PuzzleScreen extends StatefulWidget {
  final AppState app;

  const PuzzleScreen({super.key, required this.app});

  @override
  State<PuzzleScreen> createState() => _PuzzleScreenState();
}

class _PuzzleScreenState extends State<PuzzleScreen> {
  final Random _random = Random();
  late List<_Piece> _pieces;
  late List<_Piece> _shuffled;
  int _score = 0;
  int? _hoveredSlot;
  int? _wrongSlot;

  static const _shapes = [
    ShapeKind.circle,
    ShapeKind.triangle,
    ShapeKind.square,
    ShapeKind.star,
    ShapeKind.heart,
    ShapeKind.diamond,
  ];

  @override
  void initState() {
    super.initState();
    _setup();
  }

  void _setup() {
    final baseColors = List.of(ColorData.colors)..shuffle(_random);
    final colors = baseColors.take(_shapes.length).toList();
    _pieces = List.generate(_shapes.length, (i) {
      final shape = _shapes[i];
      final colorsForShape = List.of(colors)..shuffle(_random);
      return _Piece(shape, colorsForShape[0].color);
    });
    _shuffled = List.of(_pieces)..shuffle(_random);
    _score = 0;
  }

  @override
  void dispose() {
    TtsService.stop();
    super.dispose();
  }

  void _checkDone() {
    if (_pieces.every((p) => p.placed)) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) _showDone();
      });
    }
  }

  void _triggerWrong(int slotIndex) {
    if (_wrongSlot != null) return;
    setState(() => _wrongSlot = slotIndex);
    TtsService.speak(widget.app.t('wrong'), widget.app.langCode);
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _wrongSlot = null);
    });
  }

  void _showDone() {
    final app = widget.app;
    final stars = AppState.starsForScore(_score, _shapes.length * 10);
    final isRecord = app.recordScore(GameIds.puzzle, _score, stars);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          app.t('congrats'),
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.extension, size: 72, color: Color(0xFF8E24AA)),
            const SizedBox(height: 12),
            StarsRow(stars: stars),
            const SizedBox(height: 12),
            Text(
              '${app.t('score')}: $_score',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              '${app.t('best')}: ${app.bestScore(GameIds.puzzle)}',
              style: const TextStyle(fontSize: 16, color: Color(0xFF546E7A)),
            ),
            if (isRecord) ...[
              const SizedBox(height: 4),
              Text(
                app.t('new_record'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFF9A825),
                ),
              ),
            ],
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          RoundButton(
            label: app.t('restart'),
            icon: Icons.replay,
            color: const Color(0xFF8E24AA),
            onTap: () {
              Navigator.of(ctx).pop();
              if (mounted) setState(_setup);
            },
          ),
          const SizedBox(width: 12),
          RoundButton(
            label: app.t('menu'),
            icon: Icons.home,
            color: const Color(0xFF26A69A),
            onTap: () {
              Navigator.of(ctx).popUntil((route) => route.isFirst);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = widget.app;
    return GameScaffold(
      app: app,
      title: app.t('puzzle'),
      score: _score,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              app.t('puzzle_hint'),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF37474F),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: GridView.count(
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                children: List.generate(_pieces.length, (i) {
                  final piece = _pieces[i];
                  return DragTarget<_Piece>(
                    onWillAcceptWithDetails: (details) {
                      final ok = details.data.shape == piece.shape &&
                          details.data.color == piece.color;
                      _hoveredSlot = ok ? null : i;
                      return ok;
                    },
                    onLeave: (_) {
                      if (_hoveredSlot == i) _hoveredSlot = null;
                    },
                    onAcceptWithDetails: (details) {
                      final drag = details.data;
                      setState(() {
                        drag.placed = true;
                        piece.placed = true;
                        _score += 10;
                      });
                      TtsService.speak(app.t('great'), app.langCode);
                      _checkDone();
                    },
                    builder: (context, candidates, rejected) {
                      return _Slot(
                        piece: piece,
                        highlighted: candidates.isNotEmpty,
                        wrong: _wrongSlot == i,
                      );
                    },
                  );
                }),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              height: 96,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  const gap = 8.0;
                  final count = _shuffled.length;
                  final pieceSize = min(
                    56.0,
                    (constraints.maxWidth - gap * (count - 1)) / count,
                  );
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: _shuffled.map((piece) {
                      if (piece.placed) {
                        return SizedBox(width: pieceSize);
                      }
                      return Draggable<_Piece>(
                        data: piece,
                        feedback: _ShapeView(
                          shape: piece.shape,
                          color: piece.color,
                          size: pieceSize,
                          floating: true,
                        ),
                        childWhenDragging: _ShapeView(
                          shape: piece.shape,
                          color: piece.color,
                          size: pieceSize,
                          faded: true,
                        ),
                        child: _ShapeView(
                          shape: piece.shape,
                          color: piece.color,
                          size: pieceSize,
                        ),
                        onDragEnd: (details) {
                          if (!details.wasAccepted && _hoveredSlot != null) {
                            _triggerWrong(_hoveredSlot!);
                          }
                          _hoveredSlot = null;
                        },
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Slot extends StatelessWidget {
  final _Piece piece;
  final bool highlighted;
  final bool wrong;

  const _Slot({
    required this.piece,
    required this.highlighted,
    this.wrong = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: piece.placed
            ? const Color(0xFFEDE7F6)
            : wrong
                ? const Color(0xFFFFCDD2)
                : highlighted
                    ? const Color(0xFFFFF9C4)
                    : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: wrong ? const Color(0xFFC62828) : Colors.black26,
          width: wrong ? 3 : 2,
        ),
      ),
      child: Center(
        child: _ShapeView(
          shape: piece.shape,
          color: piece.placed ? piece.color : Colors.black12,
          size: 44,
        ),
      ),
    );
  }
}

class _ShapeView extends StatelessWidget {
  final ShapeKind shape;
  final Color color;
  final double size;
  final bool faded;
  final bool floating;

  const _ShapeView({
    required this.shape,
    required this.color,
    required this.size,
    this.faded = false,
    this.floating = false,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _ShapePainter(
        shape: shape,
        color: faded ? color.withValues(alpha: 0.3) : color,
      ),
    );
  }
}

class _ShapePainter extends CustomPainter {
  final ShapeKind shape;
  final Color color;

  _ShapePainter({required this.shape, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final w = size.width;
    final h = size.height;
    final c = Offset(w / 2, h / 2);

    switch (shape) {
      case ShapeKind.circle:
        canvas.drawCircle(c, w / 2, paint);
      case ShapeKind.triangle:
        final path = Path()
          ..moveTo(w / 2, h * 0.08)
          ..lineTo(w * 0.92, h * 0.9)
          ..lineTo(w * 0.08, h * 0.9)
          ..close();
        canvas.drawPath(path, paint);
      case ShapeKind.square:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: c, width: w * 0.88, height: h * 0.88),
            const Radius.circular(6),
          ),
          paint,
        );
      case ShapeKind.star:
        final path = _starPath(w, h);
        canvas.drawPath(path, paint);
      case ShapeKind.heart:
        final path = _heartPath(w, h);
        canvas.drawPath(path, paint);
      case ShapeKind.diamond:
        final path = Path()
          ..moveTo(w / 2, h * 0.08)
          ..lineTo(w * 0.92, h / 2)
          ..lineTo(w / 2, h * 0.92)
          ..lineTo(w * 0.08, h / 2)
          ..close();
        canvas.drawPath(path, paint);
    }
  }

  Path _starPath(double w, double h) {
    final path = Path();
    final cx = w / 2;
    final cy = h / 2;
    const spikes = 5;
    const outer = 0.46;
    const inner = 0.2;
    for (var i = 0; i < spikes * 2; i++) {
      final r = i.isEven ? w * outer : w * inner;
      final a = -pi / 2 + i * pi / spikes;
      final x = cx + r * cos(a);
      final y = cy + r * sin(a);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  Path _heartPath(double w, double h) {
    final path = Path();
    final s = w / 2;
    path.moveTo(s, h * 0.9);
    path.cubicTo(s * 0.2, h * 0.55, 0, h * 0.2, s * 0.35, h * 0.08);
    path.cubicTo(s * 0.5, h * 0.05, s * 0.65, h * 0.12, s, h * 0.35);
    path.cubicTo(s * 1.35, h * 0.12, s * 1.5, h * 0.05, s * 1.65, h * 0.08);
    path.cubicTo(w, h * 0.2, s * 1.8, h * 0.55, s, h * 0.9);
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant _ShapePainter oldDelegate) =>
      oldDelegate.shape != shape || oldDelegate.color != color;
}
