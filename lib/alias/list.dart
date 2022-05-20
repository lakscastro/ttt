extension IntListAlias on List<int> {
  void through(void Function(int, int) fn) {
    for (var i = 0; i < first; i++) {
      for (var j = 0; j < last; j++) {
        fn(i, j);
      }
    }
  }

  List<List<T>> fillMatrix<T>(T value) {
    return List.filled(first, List.filled(last, value));
  }

  List<List<T?>> fillNullableMatrix<T>([T? value]) {
    return fillMatrix<T?>(value);
  }

  List<List<T>> generateMatrix<T>(T Function(int, int) fn) {
    return List.generate(first, (i) => List.generate(last, (j) => fn(i, j)));
  }
}

extension ListAlias<T> on Iterable<T> {
  Iterable<E> rflatten<E>() {
    return expand(
      (element) => element is Iterable ? element.rflatten() : [element],
    ).cast<E>();
  }
}
