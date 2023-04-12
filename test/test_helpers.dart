import 'package:mocktail/mocktail.dart';

abstract class _Listener<T> {
  void call(T value);
}

class MockListener<T> extends Mock implements _Listener<T> {}

abstract class _Future<T> {
  Future<T> call();
}

class MockFuture<T> extends Mock implements _Future<T> {}
