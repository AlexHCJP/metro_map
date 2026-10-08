# metro_map

Draws linked items as a metro map. The item that ends last is the finish.
Every other item sits on a row by how many links it is from the finish, so
branches that run in parallel share a row and you can see where they merge.

- Vertical (start on top) or horizontal (start on the left).
- A line takes the colour of the station it leads to and stays faded until
  that station is done.
- Works with any item type: you say how to read its id, end time, title and
  colour.
- The layout is pure Dart (`layoutMetro`) if you want to draw it yourself.

## Usage

```dart
MetroMap<Task>(
  items: tasks,
  links: const [(1, 2), (1, 3), (2, 4), (3, 4)],
  idOf: (t) => t.id,
  endOf: (t) => t.dueAt,
  titleOf: (t) => t.title,
  subtitleOf: (t) => DateFormat.MMMd().format(t.dueAt),
  colorOf: (t) => t.status.color,
  isDone: (t) => t.status.isDone,
  onTap: (t) => openTask(t),
)
```

The vertical map takes the width it is given and sizes its height to the
rows, so put it in a vertical scroll view. With `horizontal: true` it sizes
its width to the rows, so put it in a horizontal scroll view.

Links are undirected: `(1, 2)` and `(2, 1)` are the same line. Links to ids
that are not in `items` are ignored.

## Layout only

```dart
final layout = layoutMetro(
  ends: {1: DateTime(2026, 10, 5), 2: DateTime(2026, 10, 9)},
  links: const [(1, 2)],
);
layout.finishId;          // 2
layout.stations[1]!.row;  // 0, the top row
layout.stations[1]!.x;    // 0.5, position across the row in 0..1
```
