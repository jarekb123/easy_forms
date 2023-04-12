import 'dart:async';

import 'package:easy_forms/easy_forms.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import '../test_helpers.dart';

void main() {
  registerFallbackValue(_SubmitFormStateInitial());

  late _TestSubmitFormMixin form;
  late MockListener<_SubmitFormState> stateListener;
  late MockFuture<String> submitAction;

  setUp(() {
    submitAction = MockFuture<String>();
    stateListener = MockListener<_SubmitFormState>();
    form = _TestSubmitFormMixin(submitAction);
    form.addListener(() => stateListener(form.value));
  });

  test('does not perform submit if form is invalid', () {
    form.field.updateValue('');
    form.submit();
    expect(form.value, isA<_SubmitFormStateInitial>());
    verifyNever(() => submitAction());
    verifyNever(() => stateListener(any()));
  });

  test('does not perform submit if form is already submitting', () async {
    final submit = Completer<String>();
    when(() => submitAction()).thenAnswer((_) => submit.future);

    form.field.updateValue('not empty');
    await Future.wait(
      [
        form.submit(),
        form.submit(),
        Future(() => submit.complete('result')),
      ],
    );
    verify(() => submitAction()).called(1);
    verifyNoMoreInteractions(submitAction);
  });

  test('submit() performs submit and emit side effects (success path)',
      () async {
    when(() => submitAction()).thenAnswer((_) async => 'result');

    form.field.updateValue('not empty');
    await form.submit();
    expect(form.value, isA<_SubmitFormStateSuccess>());

    verifyInOrder([
      () => stateListener(any(that: isA<_SubmitFormStateSubmitting>())),
      () => stateListener(
            any(
              that: isA<_SubmitFormStateSuccess>().having(
                (state) => state.result,
                'has result',
                'result',
              ),
            ),
          ),
    ]);
    verifyNoMoreInteractions(stateListener);
  });

  test('submit() performs submit and emit side effects (error path)', () async {
    when(() => submitAction()).thenAnswer(
      (_) async => throw 'error',
    );

    form.field.updateValue('not empty');
    await form.submit();
    expect(form.value, isA<_SubmitFormStateError>());

    verifyInOrder([
      () => stateListener(any(that: isA<_SubmitFormStateSubmitting>())),
      () => stateListener(
            any(
              that: isA<_SubmitFormStateError>()
                  .having(
                    (state) => state.error,
                    'has error',
                    'error',
                  )
                  .having(
                    (state) => state.stackTrace,
                    'has stackTrace',
                    isNotNull,
                  ),
            ),
          ),
    ]);
    verifyNoMoreInteractions(stateListener);
  });
}

abstract class _SubmitFormState {}

class _SubmitFormStateInitial extends _SubmitFormState {}

class _SubmitFormStateSubmitting extends _SubmitFormState {}

class _SubmitFormStateError extends _SubmitFormState {
  final Object error;
  final StackTrace stackTrace;

  _SubmitFormStateError({
    required this.error,
    required this.stackTrace,
  });
}

class _SubmitFormStateSuccess extends _SubmitFormState {
  final String result;

  _SubmitFormStateSuccess(this.result);
}

class _TestSubmitFormMixin extends ValueNotifier<_SubmitFormState>
    with FormControllerMixin, SubmitFormMixin<String> {
  _TestSubmitFormMixin(this._submitAction) : super(_SubmitFormStateInitial());

  final field = FieldController<String, String>(
    initialValue: '',
    validator: (value) => value.isEmpty ? 'empty' : null,
  );

  final Future<String> Function() _submitAction;

  @override
  List<ValidationNode> get fields => [field];

  @override
  void onSubmitError(Object error, StackTrace stackTrace) {
    value = _SubmitFormStateError(
      error: error,
      stackTrace: stackTrace,
    );
  }

  @override
  void onSubmitSuccess(String result) {
    value = _SubmitFormStateSuccess(result);
  }

  @override
  void onSubmitting() {
    value = _SubmitFormStateSubmitting();
  }

  @override
  Future<String> performSubmit() => _submitAction();

  @override
  FormControllerMixin get form => this;
}
