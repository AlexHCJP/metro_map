import 'package:flutter/material.dart';
import 'package:metro_map/src/layout.dart';

/// Linked [items] as a metro map: stations are items, rows are the distance
/// from the finish (the item that ends last), so parallel branches and
/// merges are visible. A line takes the colour of the station it leads to
/// and is faded until that station is done.
///
/// Vertical (start on top) by default; [horizontal] lays it out left to
/// right and sizes itself to its content, so put it in a horizontal
/// scroll view.
class MetroMap<T> extends StatelessWidget {
  /// Creates a metro map.
  const MetroMap({
    required this.items,
    required this.links,
    required this.idOf,
    required this.endOf,
    required this.titleOf,
    required this.colorOf,
    super.key,
    this.subtitleOf,
    this.isDone,
    this.onTap,
    this.horizontal = false,
    this.finishColor,
    this.finishIcon = Icons.flag_rounded,
    this.mutedColor,
    this.titleStyle,
  });

  /// The items to draw. An empty list draws nothing.
  final List<T> items;

  /// Undirected links between item ids.
  final List<(int, int)> links;

  /// The item's id, as used in [links].
  final int Function(T item) idOf;

  /// When the item ends; the latest one is the finish.
  final DateTime Function(T item) endOf;

  /// The station's label.
  final String Function(T item) titleOf;

  /// A smaller line under the label, e.g. a date.
  final String? Function(T item)? subtitleOf;

  /// The station's colour, and the colour of the line leading to it.
  final Color Function(T item) colorOf;

  /// Done stations are filled and their lines solid.
  final bool Function(T item)? isDone;

  /// Called when a station is tapped.
  final void Function(T item)? onTap;

  /// Left to right instead of top to bottom.
  final bool horizontal;

  /// The finish station's colour; the theme's primary colour by default.
  final Color? finishColor;

  /// The icon inside the finish station.
  final IconData finishIcon;

  /// Colour of subtitles and of done labels; the theme's hint colour by
  /// default.
  final Color? mutedColor;

  /// Style of the labels.
  final TextStyle? titleStyle;

  static const _rowHeight = 92.0;
  static const _colWidth = 150.0;
  static const _laneHeight = 96.0;
  static const _dot = 18.0;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final byId = {for (final item in items) idOf(item): item};
    final layout = layoutMetro(
      ends: {for (final item in items) idOf(item): endOf(item)},
      links: links,
    );
    final perRow = <int, int>{};
    for (final s in layout.stations.values) {
      perRow[s.row] = (perRow[s.row] ?? 0) + 1;
    }
    final lanes = perRow.values.fold(1, (m, n) => n > m ? n : m);
    bool done(T item) => isDone?.call(item) ?? false;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = horizontal
            ? layout.rows * _colWidth
            : constraints.maxWidth;
        final height = horizontal
            ? (lanes + 1) * _laneHeight * 0.75
            : layout.rows * _rowHeight;
        Offset at(MetroStation s) => horizontal
            ? Offset(s.row * _colWidth + _colWidth / 2, s.x * height)
            : Offset(s.x * width, s.row * _rowHeight + _dot / 2 + 4);

        return SizedBox(
          width: width,
          height: height,
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _LinesPainter(
                    horizontal: horizontal,
                    lines: [
                      for (final (u, l) in layout.edges)
                        (
                          at(layout.stations[u]!),
                          at(layout.stations[l]!),
                          colorOf(byId[l] as T),
                          done(byId[l] as T),
                        ),
                    ],
                  ),
                ),
              ),
              for (final s in layout.stations.values)
                _Station(
                  center: at(s),
                  labelWidth: horizontal
                      ? _colWidth - 14
                      : (width / (perRow[s.row]! + 1)).clamp(80, 180),
                  title: titleOf(byId[s.id] as T),
                  subtitle: subtitleOf?.call(byId[s.id] as T),
                  color: s.id == layout.finishId
                      ? finishColor ?? theme.colorScheme.primary
                      : colorOf(byId[s.id] as T),
                  filled: done(byId[s.id] as T),
                  finishIcon: s.id == layout.finishId ? finishIcon : null,
                  muted: mutedColor ?? theme.hintColor,
                  background: theme.scaffoldBackgroundColor,
                  titleStyle: titleStyle,
                  onTap: onTap == null ? null : () => onTap!(byId[s.id] as T),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _Station extends StatelessWidget {
  const _Station({
    required this.center,
    required this.labelWidth,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.filled,
    required this.finishIcon,
    required this.muted,
    required this.background,
    required this.titleStyle,
    required this.onTap,
  });

  final Offset center;
  final double labelWidth;
  final String title;
  final String? subtitle;
  final Color color;
  final bool filled;

  /// Non-null on the finish station.
  final IconData? finishIcon;
  final Color muted;
  final Color background;
  final TextStyle? titleStyle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    const dot = MetroMap._dot;
    final finish = finishIcon != null;
    return Positioned(
      left: center.dx - labelWidth / 2,
      top: center.dy - dot / 2,
      width: labelWidth,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: MouseRegion(
          cursor: onTap == null ? MouseCursor.defer : SystemMouseCursors.click,
          child: Column(
            spacing: 4,
            children: [
              Container(
                width: finish ? dot + 4 : dot,
                height: finish ? dot + 4 : dot,
                decoration: BoxDecoration(
                  color: filled || finish ? color : background,
                  shape: finish ? BoxShape.rectangle : BoxShape.circle,
                  borderRadius: finish ? BorderRadius.circular(7) : null,
                  border: Border.all(color: color, width: 4),
                ),
                child: finish
                    ? Icon(finishIcon, size: 12, color: Colors.white)
                    : null,
              ),
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12.5,
                  height: 1.2,
                  fontWeight: FontWeight.w600,
                ).merge(titleStyle).copyWith(color: filled ? muted : null),
              ),
              if (subtitle != null)
                Text(subtitle!, style: TextStyle(fontSize: 11, color: muted)),
            ],
          ),
        ),
      ),
    );
  }
}

class _LinesPainter extends CustomPainter {
  _LinesPainter({required this.lines, required this.horizontal});

  final bool horizontal;

  /// (upper, lower, colour of the lower station, lower is done)
  final List<(Offset, Offset, Color, bool)> lines;

  @override
  void paint(Canvas canvas, Size size) {
    for (final (a, b, color, done) in lines) {
      final path = Path()..moveTo(a.dx, a.dy);
      if (horizontal) {
        final midX = (a.dx + b.dx) / 2;
        path.cubicTo(midX, a.dy, midX, b.dy, b.dx, b.dy);
      } else {
        final midY = (a.dy + b.dy) / 2;
        path.cubicTo(a.dx, midY, b.dx, midY, b.dx, b.dy);
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = done ? color : color.withValues(alpha: 0.45)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_LinesPainter old) => old.lines != lines;
}
