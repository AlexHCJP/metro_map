import 'package:flutter/material.dart';
import 'package:metro_map/metro_map.dart';

void main() => runApp(const ExampleApp());

/// A task of a product launch: three branches that meet before the release.
typedef Task = ({int id, String title, int day, Status status});

enum Status {
  todo(Color(0xFFE5AC00)),
  inProgress(Color(0xFF2F9FD6)),
  done(Color(0xFF2FA866));

  const Status(this.color);

  final Color color;
}

const tasks = <Task>[
  (id: 1, title: 'Plan', day: 5, status: Status.done),
  (id: 2, title: 'Copy', day: 6, status: Status.done),
  (id: 3, title: 'Design', day: 6, status: Status.done),
  (id: 4, title: 'Domain', day: 6, status: Status.done),
  (id: 5, title: 'Localization', day: 8, status: Status.inProgress),
  (id: 6, title: 'Screenshots', day: 8, status: Status.inProgress),
  (id: 7, title: 'DNS', day: 7, status: Status.done),
  (id: 8, title: 'Code review', day: 9, status: Status.todo),
  (id: 9, title: 'Release', day: 10, status: Status.todo),
  (id: 10, title: 'Announce', day: 11, status: Status.todo),
];

/// Plan splits into three branches that meet at the code review.
const links = [
  (1, 2),
  (1, 3),
  (1, 4),
  (2, 5),
  (3, 6),
  (4, 7),
  (5, 8),
  (6, 8),
  (7, 8),
  (8, 9),
  (9, 10),
];

class ExampleApp extends StatefulWidget {
  const ExampleApp({super.key});

  @override
  State<ExampleApp> createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  var _horizontal = true;
  var _tapped = 'Tap a station';

  @override
  Widget build(BuildContext context) {
    final map = MetroMap<Task>(
      items: tasks,
      links: links,
      horizontal: _horizontal,
      idOf: (t) => t.id,
      endOf: (t) => DateTime(2026, 10, t.day),
      titleOf: (t) => t.title,
      subtitleOf: (t) => 'Oct ${t.day}',
      colorOf: (t) => t.status.color,
      isDone: (t) => t.status == Status.done,
      finishColor: const Color(0xFF8E7CF3),
      onTap: (t) => setState(() => _tapped = t.title),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF141314),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('metro_map'),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          actions: [
            IconButton(
              tooltip: 'Rotate',
              icon: Icon(_horizontal ? Icons.swap_vert : Icons.swap_horiz),
              onPressed: () => setState(() => _horizontal = !_horizontal),
            ),
          ],
        ),
        body: Column(
          children: [
            Text(_tapped, style: const TextStyle(color: Colors.white54)),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  scrollDirection: _horizontal
                      ? Axis.horizontal
                      : Axis.vertical,
                  padding: const EdgeInsets.all(32),
                  child: _horizontal
                      ? map
                      : ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 420),
                          child: map,
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
