import 'package:flutter_test/flutter_test.dart';
import 'package:metro_map/metro_map.dart';

void main() {
  DateTime d(int day) => DateTime(2026, 10, day);

  test('branching chain: parallel tasks share a row, finish is last', () {
    // plan → {copy, design, domain}; copy → loc; design → shots;
    // {loc, shots} → review; {review, domain} → release → announce
    final ends = {
      1: d(5),
      2: d(6),
      3: d(6),
      4: d(7),
      5: d(8),
      6: d(8),
      7: d(9),
      8: d(10),
      9: d(11),
    };
    final links = [
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
    final m = layoutMetro(ends: ends, links: links);

    expect(m.finishId, 9);
    expect(m.stations[9]!.row, m.rows - 1);
    expect(m.stations[8]!.row, m.rows - 2);
    // loc and shots are parallel: same row, different lanes
    expect(m.stations[5]!.row, m.stations[6]!.row);
    expect(m.stations[5]!.x, isNot(m.stations[6]!.x));
    // every link is drawn once, upper first
    expect(m.edges.length, links.length);
    for (final (u, l) in m.edges) {
      expect(m.stations[u]!.row, lessThan(m.stations[l]!.row));
    }
  });

  test('a two-task goal: the later one is the finish', () {
    final m = layoutMetro(ends: {1: d(9), 2: d(5)}, links: [(1, 2)]);
    expect(m.finishId, 1);
    expect(m.stations[2]!.row, 0);
    expect(m.stations[1]!.row, 1);
  });
}
