import 'dart:async';

import 'package:easy_forms_validation/easy_forms_validation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import '../test_helpers.dart';

void main() {
  registerFallbackValue(_SubmitFormStateInitial());

  late _TestSubmitFormMixin submitForm;
  late MockListener<_SubmitFormState> stateListener;
  late MockFuture<String> submitAction;

  setUp(() {
    submitAction = MockFuture<String>();
    stateListener = MockListener<_SubmitFormState>();
    submitForm = _TestSubmitFormMixin(submitAction);
    submitForm.addListener(() => stateListener(submitForm.value));
  });

  test('does not perform submit if form is invalid', () {
    submitForm.form.field.updateValue('');
    submitForm.submit();
    expect(submitForm.value, isA<_SubmitFormStateInitial>());
    verifyNever(() => submitAction());
    verifyNever(() => stateListener(any()));
  });

  test('does not perform submit if form is already submitting', () async {
    final submit = Completer<String>();
    when(() => submitAction()).thenAnswer((_) => submit.future);

    submitForm.form.field.updateValue('not empty');
    await Future.wait(
      [
        submitForm.submit(),
        submitForm.submit(),
        Future(() => submit.complete('result')),
      ],
    );
    verify(() => submitAction()).called(1);
    verifyNoMoreInteractions(submitAction);
  });

  test('submit() performs submit and emit side effects (success path)',
      () async {
    when(() => submitAction()).thenAnswer((_) async => 'result');

    submitForm.form.field.updateValue('not empty');
    await submitForm.submit();
    expect(submitForm.value, isA<_SubmitFormStateSuccess>());

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

    submitForm.form.field.updateValue('not empty');
    await submitForm.submit();
    expect(submitForm.value, isA<_SubmitFormStateError>());

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
    with SubmitFormMixin<_TestForm, String> {
  _TestSubmitFormMixin(this._submitAction) : super(_SubmitFormStateInitial());

  final Future<String> Function() _submitAction;

  @override
  void onSubmitError(Object error, StackTrace stackTrace) {
    value = _SubmitFormStateError(
      error: error,
      stackTrace: stackTrace,
    );
  }

  @override
  void onSubmitted(String result) {
    value = _SubmitFormStateSuccess(result);
  }

  @override
  void onSubmitting() {
    value = _SubmitFormStateSubmitting();
  }

  @override
  Future<String> performSubmit() => _submitAction();

  @override
  final form = _TestForm();
}

class _TestForm with FormControllerMixin {
  final field = FieldController<String, String>(
    initialValue: '',
    validator: (value, _) => value.isEmpty ? 'empty' : null,
  );

  @override
  List<FormPart> get fields => [field];
}
