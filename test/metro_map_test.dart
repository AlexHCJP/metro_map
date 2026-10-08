import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metro_map/metro_map.dart';

typedef _Task = ({int id, String title, int day, Color color, bool done});

void main() {
  const green = Color(0xFF2FA866);
  const blue = Color(0xFF2F9FD6);
  const yellow = Color(0xFFE5AC00);
  _Task task(int id, String title, int day, Color color) =>
      (id: id, title: title, day: day, color: color, done: color == green);
  final tasks = [
    task(1, 'Plan', 5, green),
    task(2, 'Copy', 6, green),
    task(3, 'Design', 6, green),
    task(4, 'Domain', 7, green),
    task(5, 'Localization', 8, blue),
    task(6, 'Screenshots', 8, blue),
    task(7, 'Code review', 9, yellow),
    task(8, 'Release', 10, yellow),
    task(9, 'Announce', 11, yellow),
  ];
  const links = [
    (1, 2),
    (1, 3),
    (1, 4),
    (2, 5),
    (3, 6),
    (5, 7),
    (6, 7),
    (7, 8),
    (4, 8),
    (8, 9),
  ];

  for (final horizontal in [false, true]) {
    testWidgets('renders ${horizontal ? 'horizontally' : 'vertically'}', (
      tester,
    ) async {
      tester.view.physicalSize = horizontal
          ? const Size(1300, 520)
          : const Size(390, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      var tapped = '';
      final map = MetroMap<_Task>(
        items: tasks,
        links: links,
        horizontal: horizontal,
        idOf: (t) => t.id,
        endOf: (t) => DateTime(2026, 10, t.day),
        titleOf: (t) => t.title,
        subtitleOf: (t) => 'Oct ${t.day}',
        colorOf: (t) => t.color,
        isDone: (t) => t.done,
        onTap: (t) => tapped = t.title,
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              scrollDirection: horizontal ? Axis.horizontal : Axis.vertical,
              child: map,
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(find.text('Announce'), findsOneWidget);
      expect(find.byIcon(Icons.flag_rounded), findsOneWidget);
      await tester.tap(find.text('Screenshots'));
      expect(tapped, 'Screenshots');
    });
  }

  testWidgets('draws nothing without items', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MetroMap<_Task>(
          items: const [],
          links: const [],
          idOf: (t) => t.id,
          endOf: (t) => DateTime(2026),
          titleOf: (t) => t.title,
          colorOf: (t) => t.color,
        ),
      ),
    );
    expect(
      find.descendant(
        of: find.byType(MetroMap<_Task>),
        matching: find.byType(CustomPaint),
      ),
      findsNothing,
    );
  });
}
