import 'dart:math';
import 'dart:collection';

class MultiSelectList<E> extends ListBase<E> {
  List baseList = new List();

  // custom properties
  int _anchorIndex;
  List<E> _singleSelections = [];
  List<E> _rangeSelections = [];

  // custom functions
  get anchor => _anchorIndex;

  // handler for a range selection, e.g. a shift-click
  void rangeSelect(E selection) {
    int upperBoundary;
    int lowerBoundary;
    bool reverseRange;
    List<E> trimmedItems = [];
    List<int> trimmedIndices = [];
    List<int> trimmedIndicesFromSelection = [];
    List<int> trimmedIndicesFromAnchor = [];

    // determine the index of the selected item
    int selectionIndex = baseList.indexOf(selection);

    // if there are no previously selected items, select all items
    // in the collection, up to and including the range-selected item
    if (_singleSelections.isEmpty) {
      lowerBoundary = 0;
      upperBoundary = selectionIndex;
      // set the anchor index to the first item in the collection
      _anchorIndex = 0;
    } else {
      // determine the range direction by comparing the range-selection index to the anchor index
      reverseRange = anchor > selectionIndex;

      if (reverseRange) {
        // `above` previous selection
        lowerBoundary = selectionIndex;
        upperBoundary = anchor;
      } else {
        // `below` previous selection
        lowerBoundary = anchor;
        upperBoundary = selectionIndex;
      }

      // identify any selected indices which are contiguous beyond the range selection index,
      // in the direction of the range selection from the anchor index and vice versa

      // only trim from the newly selected index if it overlaps an existing selection
      if (_singleSelections.contains(selection)) {
        trimmedIndicesFromSelection = getContiguousIndices(selectionIndex, reverseRange);
      }

      trimmedIndicesFromAnchor = getContiguousIndices(anchor, !reverseRange);
      trimmedIndices = trimmedIndicesFromSelection..addAll(trimmedIndicesFromAnchor);

      if (trimmedIndices.isNotEmpty) {
        // get the items at the trimmed indices from the base list
        trimmedItems = getAtIndices(trimmedIndices);

        // and remove them from the selected items list
        _singleSelections.removeWhere((e) => trimmedItems.contains(e));
      }
    }

    // remove any existing range-selected items from the selected items list
    if (_rangeSelections.isNotEmpty) {
      _singleSelections.removeWhere((e) => _rangeSelections.contains(e));
    }

    // get the items within the selection range from the base list
    // TODO: excluding any entities which are being updated (e.g. with a `status` value)
    List<E> newlyCheckedEntities = baseList.getRange(lowerBoundary, upperBoundary + 1).toList();

    // set the range-selected collection
    if (newlyCheckedEntities.isNotEmpty) {
      _rangeSelections = newlyCheckedEntities;
    } else {
      _rangeSelections.clear();
    }

    // merge the range-selected items into the selected items list
    _singleSelections.addAll(_rangeSelections);
  }

  // toggle a single selection, e.g. left-click, checkbox selection
  void toggleSelect(E selection) {
    // get the index of the selection from the base list
    int selectionIndex = baseList.indexOf(selection);
    if (_singleSelections.contains(selection)) {
      // if already selected, remove from selected list
      _singleSelections.remove(selection);
      // find the next valid anchor index
      _anchorIndex = getNextAnchor(selectionIndex);
    } else {
      // add to single selected list
      _singleSelections.add(selection);
      // the selection sets the anchor index
      _anchorIndex = selectionIndex;
    }
  }

  // return all items considered selected
  List<E> getSelected() => baseList.where((i) => _singleSelections.contains(i)).toList();

  // get indices of all selected items
  List<int> getSelectedIndices() => _singleSelections.map((i) => baseList.indexOf(i)).toList()..sort();

  // get items at specified indices
  List<E> getAtIndices(List<int> indices) => indices.map((i) => baseList.elementAt(i)).toList();

  // find the next valid anchor index after an item is removed
  int getNextAnchor(int previousAnchor) {
    int nextIndex;
    List<int> indices = getSelectedIndices();

    int getNextIndex() {
      var i;
      for (i = 0; i < indices.length; i++) {
        if (indices[i] > previousAnchor) {
          return indices[i];
        }
      }
      // return default when anchor > selected indices
      return previousAnchor;
    }
    // reverse the incides, rather than traverse backwards
    int getPreviousIndex() {
      var i;
      for (i = indices.length; i > 0; i--) {
        if (indices[i] < previousAnchor) {
          return indices[i];
        }
      }
      // return default when anchor < selected indices
      return 0;
    }

    if (indices.isEmpty) {
      // no previous selections, so set the anchor to the first item
      return 0;
    } else if (previousAnchor < indices.reduce(max)) {
      // find the next-higher (+) selected index and use it as the anchor
      nextIndex = getNextIndex();
    } else {
      // find the next-lower (-) selected index and use it as the anchor
      nextIndex = getPreviousIndex();
    }

    return nextIndex;
  }

  List<int> getContiguousIndices(int startIndex, bool reverse) {
    List<int> selectedIndices = getSelectedIndices();
    List<int> trimmedIndices = [];
    bool continueChecking = false;
    int currentIndex = startIndex;

    // helper function to increment/decrement
    // could be a reversed-list
    int shiftIndex(currentIndex, reverse) {
      var shiftedIndex;
      if (reverse) {
        shiftedIndex = currentIndex - 1;
      } else {
        shiftedIndex = currentIndex + 1;
      }
      return shiftedIndex;
    }

    // note: the do/while loop will run a least one iteration
    // even if the while condition evaluates to false
    do {
      // shift the index value the desired direction
      currentIndex = shiftIndex(currentIndex, reverse);

      // if the next index is selected, mark it for removal and
      // continue checking for more contiguous selections
      if (selectedIndices.contains(currentIndex)) {
        trimmedIndices.add(currentIndex);
        continueChecking = true;
      } else {
        continueChecking = false;
      }
    } while (continueChecking);

    return trimmedIndices;
  }

  // Base class delegated functions
  int get length => baseList.length;

  void set length(int length) {
    baseList.length = length;
  }

  void operator []=(int index, E value) {
    baseList[index] = value;
  }

  E operator [](int index) => baseList[index];

  // Though not strictly necessary, for performance reasons
  // you should implement and delegate add and addAll.

  void add(E value) => baseList.add(value);

  void addAll(Iterable<E> all) => baseList.addAll(all);
}
