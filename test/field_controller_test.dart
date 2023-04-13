import 'package:easy_forms/easy_forms.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'test_helpers.dart';

enum _FieldValidationError { empty, tooLong }

typedef _TestFieldState = FieldControllerState<String, _FieldValidationError>;

void main() {
  registerFallbackValue(
    const _TestFieldState(
      value: '',
      error: null,
      validationState: ValidationState.dirty,
    ),
  );
  late MockListener<FieldControllerState<String, _FieldValidationError>>
      stateListener;

  FieldController<String, _FieldValidationError> createField({
    required String initialValue,
    bool autoValidate = false,
  }) {
    return FieldController(
      initialValue: initialValue,
      validator: (value) {
        if (value.isEmpty) {
          return _FieldValidationError.empty;
        } else if (value.length > 5) {
          return _FieldValidationError.tooLong;
        } else {
          return null;
        }
      },
      autoValidate: autoValidate,
    );
  }

  setUp(() {
    stateListener = MockListener();
  });

  group('non autovalidated field', () {
    late FieldController<String, _FieldValidationError> field;

    setUp(() {
      field = createField(initialValue: '');
      field.addListener(
        () => stateListener(field.value),
      );
    });

    test('is not validated immediately', () {
      expect(
        field.value,
        const _TestFieldState(
          value: '',
          error: null,
          validationState: ValidationState.dirty,
        ),
      );
      verifyZeroInteractions(stateListener);
    });

    test('is not validated when value is updated', () {
      field.updateValue('123456');

      const expectedState = _TestFieldState(
        value: '123456',
        error: null,
        validationState: ValidationState.dirty,
      );
      expect(field.value, expectedState);
      verify(() => stateListener(expectedState)).called(1);
      verifyNoMoreInteractions(stateListener);
    });

    test('is validated when validate is called', () {
      // validates initial value
      expect(field.validate(), isFalse);
      const expectedFirstState = _TestFieldState(
        value: '',
        error: _FieldValidationError.empty,
        validationState: ValidationState.invalid,
      );
      expect(field.value, expectedFirstState);
      verify(() => stateListener(expectedFirstState)).called(1);

      field.updateValue('123456');
      const expectedSecondState = _TestFieldState(
        value: '123456',
        error: null, // error is cleared when value is updated
        validationState: ValidationState.dirty,
      );
      expect(
        field.value,
        expectedSecondState,
        reason: 'value is updated and error is cleared when value is updated',
      );
      verify(() => stateListener(expectedSecondState)).called(1);

      expect(field.validate(), isFalse);
      const expectedThirdState = _TestFieldState(
        value: '123456',
        error: _FieldValidationError.tooLong,
        validationState: ValidationState.invalid,
      );
      expect(field.value, expectedThirdState);
      verify(() => stateListener(expectedThirdState)).called(1);

      verifyNoMoreInteractions(stateListener);
    });

    test('overrideValidationError overrides error', () {
      // validates initial value
      expect(field.validate(), isFalse);
      verify(
        () => stateListener(
          any(that: hasValidationState(ValidationState.invalid)),
        ),
      ).called(1);

      expectValidationState(field.value, ValidationState.invalid);

      field.overrideValidationError(_FieldValidationError.tooLong);

      expectValidationError(field.value, _FieldValidationError.tooLong);
      verify(
        () => stateListener(
          any(
            that: allOf(
              hasValidationError(_FieldValidationError.tooLong),
              hasValidationState(ValidationState.invalid),
            ),
          ),
        ),
      ).called(1);

      verifyNoMoreInteractions(stateListener);
    });
  });

  group('autovalidated field', () {
    late FieldController<String, _FieldValidationError> field;

    setUp(() {
      field = createField(initialValue: '', autoValidate: true);
      field.addListener(
        () => stateListener(field.value),
      );
    });

    test('initial value is validated on create', () {
      expect(
        field.value,
        allOf(
          hasValidationError(_FieldValidationError.empty),
          hasValidationState(ValidationState.invalid),
        ),
      );
    });

    test('is validated on every value change', () {
      field.updateValue('123456');
      verify(
        () => stateListener(
          const _TestFieldState(
            value: '123456',
            error: _FieldValidationError.tooLong,
            validationState: ValidationState.invalid,
          ),
        ),
      ).called(1);
      verifyNoMoreInteractions(stateListener);

      field.updateValue('12345');
      verify(
        () => stateListener(
          const _TestFieldState(
            value: '12345',
            error: null,
            validationState: ValidationState.valid,
          ),
        ),
      ).called(1);
      verifyNoMoreInteractions(stateListener);

      field.updateValue('');
      verify(
        () => stateListener(
          const _TestFieldState(
            value: '',
            error: _FieldValidationError.empty,
            validationState: ValidationState.invalid,
          ),
        ),
      ).called(1);
      verifyNoMoreInteractions(stateListener);
    });

    test('overrideValidationError overrides error', () {
      expect(
        field.value,
        allOf(
          hasValidationError(_FieldValidationError.empty),
          hasValidationState(ValidationState.invalid),
        ),
      );

      field.overrideValidationError(_FieldValidationError.tooLong);

      expectValidationError(field.value, _FieldValidationError.tooLong);
      verify(
        () => stateListener(
          any(
            that: allOf(
              hasValidationError(_FieldValidationError.tooLong),
              hasValidationState(ValidationState.invalid),
            ),
          ),
        ),
      ).called(1);
      verifyNoMoreInteractions(stateListener);
    });
  });
}
