import 'package:test/test.dart';

import '../lib/src/multiselect.dart';

void main() {
  group('Range selections', () {
    MultiSelectList rangeSelections;

    setUp(() {
      rangeSelections = new MultiSelectList()..addAll(['A', 'B', 'C', 'D', 'E']);
    });

    test('should begin at the start of the list if no previous selections were made', () {
      rangeSelections.rangeSelect('C');
      expect(rangeSelections.getSelected(), ['A', 'B', 'C']);
    });

    test('should begin at the last-selected index if previous selections were made', () {
      rangeSelections.toggleSelect('B');
      rangeSelections.rangeSelect('C');
      expect(rangeSelections.getSelected(), ['B', 'C']);
    });

    test('should respect last-selected index between range selections', () {
      rangeSelections.toggleSelect('A');
      rangeSelections.rangeSelect('C');
      expect(rangeSelections.getSelected(), ['A', 'B', 'C']);
      rangeSelections.rangeSelect('E');
      expect(rangeSelections.getSelected(), ['A', 'B', 'C', 'D', 'E']);
      rangeSelections.rangeSelect('B');
      expect(rangeSelections.getSelected(), ['A', 'B']);
    });

    group('directionality', () {
      test('should be inferred from last-selected index', () {
        rangeSelections.toggleSelect('C');
        rangeSelections.rangeSelect('E');
        expect(rangeSelections.getSelected(), ['C', 'D', 'E']);
        rangeSelections.rangeSelect('A');
        expect(rangeSelections.getSelected(), ['A', 'B', 'C']);
      });
    });

    group('contiguous ranges', () {
      test('should be trimmed from new range if they overlap', () {
        rangeSelections.toggleSelect('C');
        rangeSelections.rangeSelect('E');
        expect(rangeSelections.getSelected(), ['C', 'D', 'E']);

        rangeSelections.toggleSelect('A');
        rangeSelections.rangeSelect('C');
        expect(rangeSelections.getSelected(), ['A', 'B', 'C']);
      });

      test('should be trimmed from new range if they overlap (reverse)', () {
        rangeSelections.toggleSelect('A');
        rangeSelections.rangeSelect('C');
        expect(rangeSelections.getSelected(), ['A', 'B', 'C']);

        rangeSelections.toggleSelect('E');
        rangeSelections.rangeSelect('C');
        expect(rangeSelections.getSelected(), ['C', 'D', 'E']);
      });

      test('should be not be included in the new range', () {
        rangeSelections.toggleSelect('C');
        rangeSelections.rangeSelect('D');
        expect(rangeSelections.getSelected(), ['C', 'D']);

        rangeSelections.toggleSelect('A');
        rangeSelections.rangeSelect('B');
        expect(rangeSelections.getSelected(), ['A', 'B']);
      });
    });
  });
}
