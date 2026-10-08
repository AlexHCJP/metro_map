![Frame](https://raw.githubusercontent.com/AlexHCJP/metro_map/main/screenshots/contributors.png)

# 🚇 Metro Map


<div align="center">
  <a href="https://pub.dev/packages/metro_map">
    <img src="https://img.shields.io/pub/v/metro_map?label=Pub&logo=dart" alt="Pub Package" />
  </a>
  <a href="https://pub.dev/packages/metro_map">
    <img src="https://img.shields.io/pub/likes/metro_map?style=flat&logo=dart&label=Likes" alt="Pub Likes" />
  </a>
  <a href="https://pub.dev/packages/metro_map/score">
    <img src="https://img.shields.io/pub/points/metro_map?label=Score&logo=dart" alt="Pub Score" />
  </a>
  <a href="https://pub.dev/packages/metro_map">
    <img src="https://img.shields.io/pub/dm/metro_map?style=flat&color=blue&logo=dart&label=Downloads" alt="Pub Monthly Downloads" />
  </a>
  <a href="https://github.com/AlexHCJP/metro_map">
    <img src="https://img.shields.io/github/stars/AlexHCJP/metro_map?style=flat&logo=github&colorB=deeppink&label=Stars" alt="Star on Github" />
  </a>
  <a href="https://github.com/AlexHCJP/metro_map">
    <img src="https://img.shields.io/github/forks/AlexHCJP/metro_map?color=orange&label=Forks&logo=github" alt="Forks on Github" />
  </a>
  <a href="https://github.com/AlexHCJP/metro_map/graphs/contributors">
    <img src="https://img.shields.io/github/contributors/AlexHCJP/metro_map?style=flat&logo=github&colorB=yellow&label=Contributors" alt="Contributors" />
  </a>
  <a href="https://github.com/AlexHCJP/metro_map/issues">
    <img src="https://img.shields.io/github/issues/AlexHCJP/metro_map?label=Issues&logo=github&color=purple" alt="Issues" />
  </a>
  <a href="https://github.com/AlexHCJP/metro_map">
    <img src="https://img.shields.io/github/languages/code-size/AlexHCJP/metro_map?logo=github&color=blue&label=Size" alt="Code size" />
  </a>
  <a href="https://github.com/AlexHCJP/metro_map/blob/HEAD/LICENSE">
    <img src="https://img.shields.io/github/license/AlexHCJP/metro_map?label=License&color=red&logo=Leanpub" alt="License" />
  </a>
  <a href="https://pub.dev/packages/metro_map">
    <img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web%20%7C%20macOS%20%7C%20Windows%20%7C%20Linux-blue.svg?logo=flutter" alt="Platform" />
  </a>
</div>

`metro_map` draws linked items as a metro map for Flutter. The item that ends last is the finish; every other item sits on a row by how many links it is from the finish, so branches that run in parallel share a row and you can see exactly where they merge. Depends on nothing but Flutter.

![A launch plan drawn by metro_map](https://raw.githubusercontent.com/AlexHCJP/metro_map/main/screenshots/metro.png)

---

## 📋 Features

- **Branches and merges at a glance**: items the same number of links from the finish share a row, so parallel work lines up and every merge is a visible junction.
- **Any data**: `MetroMap<T>` takes your own model and reads its id, end time, title and colour through callbacks — no wrapper classes.
- **Vertical or horizontal**: top to bottom for phones, left to right for wide screens, one flag.
- **Progress in the lines**: a line takes the colour of the station it leads to and stays faded until that station is done; the finish gets its own flag.
- **Fewer crossings**: inside a row, stations are ordered by the position of their neighbours above.
- **Tappable stations**: `onTap` gives you the item back.
- **Headless core**: `layoutMetro` is pure Dart — unit-test layouts or draw them with your own renderer.

---

## 🚀 Installation

Add the dependency in your `pubspec.yaml`:

```yaml
dependencies:
  metro_map: ^latest_version
```

Then run:

```bash
flutter pub get
```

---

## 📖 Usage

### 1. Describe your items

The type parameter is whatever you want to show on a station — a model, a record, anything. Each item needs an `int` id and an end time:

```dart
import 'package:metro_map/metro_map.dart';

typedef Task = ({int id, String title, DateTime due, Color color, bool done});
```

### 2. List the links

Links are pairs of ids. They are undirected: `(1, 2)` and `(2, 1)` are the same line. Links to ids that are not among the items, and links from an item to itself, are ignored:

```dart
const links = [(1, 2), (1, 3), (2, 4), (3, 4)];
```

### 3. Show it

```dart
MetroMap<Task>(
  items: tasks,
  links: links,
  idOf: (t) => t.id,
  endOf: (t) => t.due,           // the latest one becomes the finish
  titleOf: (t) => t.title,
  subtitleOf: (t) => DateFormat.MMMd().format(t.due),
  colorOf: (t) => t.color,       // station and the line leading to it
  isDone: (t) => t.done,         // filled station, solid line
  onTap: (t) => openTask(t),
)
```

The vertical map takes the width it is given and sizes its height to the rows, so put it in a vertical scroll view.

### 4. Go horizontal

```dart
SingleChildScrollView(
  scrollDirection: Axis.horizontal,
  child: MetroMap<Task>(
    horizontal: true,
    // ...the same callbacks
  ),
)
```

A horizontal map sizes its width to the rows, so it goes in a horizontal scroll view.

### 5. Style it

```dart
MetroMap<Task>(
  // ...
  finishColor: Colors.deepPurple,      // default: colorScheme.primary
  finishIcon: Icons.rocket_launch,     // default: Icons.flag_rounded
  mutedColor: Colors.grey,             // subtitles and done labels; default: hintColor
  titleStyle: const TextStyle(fontFamily: 'Inter'),
)
```

### Full example

```dart
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
```

---

## ⚙️ How the layout works

* the finish is the item that ends last; on a tie, the one with the higher id;
* every item's row is its distance in links from the finish, found by a breadth-first search, so the finish is the last row and the start is the first;
* items that cannot reach the finish go on the top row;
* inside a row, stations are sorted by the mean position of their neighbours in the rows above, then by end time, which keeps crossings down;
* each link is drawn once, from the upper station to the lower one, as a smooth curve in the colour of the lower station.

Because a row is the *shortest* distance to the finish, a branch that skips ahead (a link straight from an early item to a late one) pulls its start closer to the finish.

---

## 📚 API Reference

* **`MetroMap<T>`** — the widget

    * `items`, `links`
    * `idOf(item)`, `endOf(item)`, `titleOf(item)`, `subtitleOf(item)`, `colorOf(item)`, `isDone(item)`
    * `onTap(item)`, `horizontal`
    * `finishColor`, `finishIcon`, `mutedColor`, `titleStyle`

* **`layoutMetro({ends, links})`** — the headless layout, returns a `MetroLayout`

* **`MetroLayout`** — `stations`, `edges` (upper, lower), `finishId`, `rows`

* **`MetroStation`** — `id`, `row` (0 is the top), `x` (0..1 across the row)
