import 'package:easy_forms/easy_forms.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

abstract class _Listener<T> {
  void call(T value);
}

class MockListener<T> extends Mock implements _Listener<T> {}

abstract class _Future<T> {
  Future<T> call();
}

class MockFuture<T> extends Mock implements _Future<T> {}

void expectValidationError<T extends FieldControllerState>(
  T state,
  Object? error, {
  String? reason,
}) =>
    expect(state, hasValidationError(error), reason: reason);

void expectValidationState<T extends FormPartState>(
  T state,
  dynamic matcher, {
  String? reason,
}) =>
    expect(state.validationState, matcher, reason: reason);

void expectValue<T extends FieldControllerState>(
  T state,
  Object? value, {
  String? reason,
}) =>
    expect(state, hasValue(value), reason: reason);

Matcher hasValidationError<T extends FieldControllerState>(
  Object? error,
) {
  return predicate<T>(
    (state) => state.error == error,
    'should have error: $error',
  );
}

Matcher hasValidationState<T extends FormPartState>(
  ValidationState validationState,
) {
  return predicate<T>(
    (state) => state.validationState == validationState,
    'should have validationState: $validationState',
  );
}

Matcher hasValue<T extends FieldControllerState>(
  Object? value,
) {
  return predicate<T>(
    (state) => state.value == value,
    'should have value: $value',
  );
}
