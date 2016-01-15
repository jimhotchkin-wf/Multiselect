import 'package:test/test.dart';

import '../lib/src/multiselect.dart';

void main() {
  group('Base list functionality', () {
    MultiSelectList baseList;

    setUp(() {
      baseList = new MultiSelectList();
    });

    test('should add a single item to the list', () {
      baseList.add('C');
      expect(baseList, ['C']);
    });

    test('should add multiple items to the list', () {
      baseList.addAll(['A', 'B', 'C', 'D', 'E']);
      expect(baseList, ['A', 'B', 'C', 'D', 'E']);
    });

    test('should return the length of the list', () {
      baseList.addAll(['A', 'C', 'D', 'E']);
      expect(baseList.length, 4);
    });

    test('should return an item at a given index of the list', () {
      baseList.addAll(['A', 'C', 'D', 'E']);
      expect(baseList[1], 'C');
    });
  });

  group('Single selection toggle', () {
    MultiSelectList singleSelections;

    setUp(() {
      singleSelections = new MultiSelectList()..addAll(['A', 'B', 'C', 'D', 'E']);
    });

    test('should add a single item to the selected items list', () {
      singleSelections.toggleSelect('C');
      expect(singleSelections.getSelected(), ['C']);
    });

    test('should remove a single item from the selected items list if its already added', () {
      singleSelections.toggleSelect('C');
      singleSelections.toggleSelect('D');
      expect(singleSelections.getSelected(), ['C', 'D']);
      singleSelections.toggleSelect('C');
      expect(singleSelections.getSelected(), ['D']);
      singleSelections.toggleSelect('D');
      expect(singleSelections.getSelected(), []);
    });
  });

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
