/// Places linked items on a metro map. The finish is the item that ends
/// last; every other item sits on a row by its distance (in links) from the
/// finish, so parallel branches share a row and merges are visible.
/// Pure Dart: the widget only scales the result to pixels.
library;

/// Where one item sits on the map.
class MetroStation {
  /// Creates a station.
  const MetroStation({required this.id, required this.row, required this.x});

  /// The item's id.
  final int id;

  /// 0 is the top (furthest from the finish); the finish is the last row.
  final int row;

  /// Position across the row, in 0..1.
  final double x;
}

/// The result of [layoutMetro].
class MetroLayout {
  /// Creates a layout.
  const MetroLayout({
    required this.stations,
    required this.edges,
    required this.finishId,
    required this.rows,
  });

  /// Every item's station, by id.
  final Map<int, MetroStation> stations;

  /// Links between items, each once, as (upper, lower) by row.
  final List<(int, int)> edges;

  /// The id of the item that ends last.
  final int finishId;

  /// How many rows the map has.
  final int rows;
}

/// Lays out items given each one's end time ([ends], by id) and the
/// undirected [links] between them. Links to unknown ids and self-links are
/// ignored; items not reachable from the finish go on the top row.
MetroLayout layoutMetro({
  required Map<int, DateTime> ends,
  required List<(int, int)> links,
}) {
  assert(ends.isNotEmpty, 'A metro map needs at least one item.');
  final ids = ends.keys.toList()..sort();
  final adj = {for (final id in ids) id: <int>{}};
  for (final (a, b) in links) {
    if (!adj.containsKey(a) || !adj.containsKey(b) || a == b) continue;
    adj[a]!.add(b);
    adj[b]!.add(a);
  }

  // Finish: the task that ends last; ties go to the higher id (made later).
  final finish = ids.reduce(
    (a, b) =>
        ends[a]!.isAfter(ends[b]!) || (ends[a] == ends[b] && a > b) ? a : b,
  );

  // Distance from the finish (BFS).
  final dist = {finish: 0};
  final queue = [finish];
  for (var i = 0; i < queue.length; i++) {
    for (final n in adj[queue[i]]!) {
      if (dist.containsKey(n)) continue;
      dist[n] = dist[queue[i]]! + 1;
      queue.add(n);
    }
  }
  final maxDist = dist.values.fold(0, (m, d) => d > m ? d : m);
  for (final id in ids) {
    dist.putIfAbsent(id, () => maxDist + 1); // unreachable: top row
  }
  final top = dist.values.fold(0, (m, d) => d > m ? d : m);
  int rowOf(int id) => top - dist[id]!;

  // Rows top to bottom; inside a row, order by the mean x of neighbours in
  // the row above (fewer crossings), then by end time.
  final byRow = <int, List<int>>{};
  for (final id in ids) {
    byRow.putIfAbsent(rowOf(id), () => []).add(id);
  }
  final x = <int, double>{};
  for (var r = 0; r <= top; r++) {
    final row = byRow[r] ?? const <int>[];
    double key(int id) {
      final above = adj[id]!.where((n) => rowOf(n) < r && x.containsKey(n));
      if (above.isEmpty) return 0.5;
      return above.map((n) => x[n]!).reduce((a, b) => a + b) / above.length;
    }

    row.sort((a, b) {
      final c = key(a).compareTo(key(b));
      return c != 0 ? c : ends[a]!.compareTo(ends[b]!);
    });
    for (var i = 0; i < row.length; i++) {
      x[row[i]] = (i + 1) / (row.length + 1);
    }
  }

  final seen = <(int, int)>{};
  final edges = <(int, int)>[];
  for (final (a, b) in links) {
    if (!adj.containsKey(a) || !adj.containsKey(b) || a == b) continue;
    final (u, l) = rowOf(a) <= rowOf(b) ? (a, b) : (b, a);
    if (seen.add((u, l))) edges.add((u, l));
  }

  return MetroLayout(
    stations: {
      for (final id in ids) id: MetroStation(id: id, row: rowOf(id), x: x[id]!),
    },
    edges: edges,
    finishId: finish,
    rows: top + 1,
  );
}
