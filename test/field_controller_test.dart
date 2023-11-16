import 'package:easy_forms_validation/easy_forms_validation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'test_helpers.dart';

enum _FieldValidationError { empty, tooLong }

typedef _TestFieldState = FieldControllerState<String, _FieldValidationError>;

void main() {
  registerFallbackValue(
    const _TestFieldState(
      initialValue: '',
      value: '',
      error: null,
      validationState: ValidationState.dirty,
      autoValidate: false,
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
      validator: (value, ref) {
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
          initialValue: '',
          value: '',
          error: null,
          validationState: ValidationState.dirty,
          autoValidate: false,
        ),
      );
      verifyZeroInteractions(stateListener);
    });

    test('is not validated when value is updated', () {
      field.updateValue('123456');

      const expectedState = _TestFieldState(
        initialValue: '',
        value: '123456',
        error: null,
        validationState: ValidationState.dirty,
        autoValidate: false,
      );
      expect(field.value, expectedState);
      verify(() => stateListener(expectedState)).called(1);
      verifyNoMoreInteractions(stateListener);
    });

    test('is validated when validate is called', () {
      // validates initial value
      expect(field.validate(), isFalse);
      const expectedFirstState = _TestFieldState(
        initialValue: '',
        value: '',
        error: _FieldValidationError.empty,
        validationState: ValidationState.invalid,
        autoValidate: false,
      );
      expect(field.value, expectedFirstState);
      verify(() => stateListener(expectedFirstState)).called(1);

      field.updateValue('123456');
      const expectedSecondState = _TestFieldState(
        initialValue: '',
        value: '123456',
        error: null, // error is cleared when value is updated
        validationState: ValidationState.dirty,
        autoValidate: false,
      );
      expect(
        field.value,
        expectedSecondState,
        reason: 'value is updated and error is cleared when value is updated',
      );
      verify(() => stateListener(expectedSecondState)).called(1);

      expect(field.validate(), isFalse);
      const expectedThirdState = _TestFieldState(
        initialValue: '',
        value: '123456',
        error: _FieldValidationError.tooLong,
        validationState: ValidationState.invalid,
        autoValidate: false,
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
          _TestFieldState(
            initialValue: field.value.initialValue,
            value: '123456',
            error: _FieldValidationError.tooLong,
            validationState: ValidationState.invalid,
            autoValidate: field.value.autoValidate,
          ),
        ),
      ).called(1);
      verifyNoMoreInteractions(stateListener);

      field.updateValue('12345');
      verify(
        () => stateListener(
          _TestFieldState(
            initialValue: field.value.initialValue,
            value: '12345',
            error: null,
            validationState: ValidationState.valid,
            autoValidate: field.value.autoValidate,
          ),
        ),
      ).called(1);
      verifyNoMoreInteractions(stateListener);

      field.updateValue('');
      verify(
        () => stateListener(
          _TestFieldState(
            initialValue: field.value.initialValue,
            value: '',
            error: _FieldValidationError.empty,
            validationState: ValidationState.invalid,
            autoValidate: field.value.autoValidate,
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

  group(
    'autovalidated that uses other field values',
    () {
      late FieldController<String, String> passwordController;
      late FieldController<String, String> confirmPasswordController;

      setUp(
        () {
          passwordController = FieldController<String, String>(
            initialValue: '',
            validator: (value, ref) {
              if (value.isEmpty) {
                return 'Password is required';
              } else if (value.length < 6) {
                return 'Password must be at least 6 characters long';
              } else {
                return null;
              }
            },
          );

          confirmPasswordController = FieldController<String, String>(
            initialValue: '',
            autoValidate: true,
            validator: (value, ref) {
              final password = ref.watch(passwordController).value;

              if (value.isEmpty) {
                return 'Confirm password is required';
              } else if (value != password) {
                return 'Passwords do not match';
              } else {
                return null;
              }
            },
          );
        },
      );

      test('change password to non matching value', () {
        expect(
          confirmPasswordController.value,
          allOf(
            hasValidationError('Confirm password is required'),
            hasValidationState(ValidationState.invalid),
          ),
        );

        passwordController.updateValue('123456');
        confirmPasswordController.updateValue('123456');

        expect(
          confirmPasswordController.value,
          allOf(
            hasValidationError(null),
            hasValidationState(ValidationState.valid),
          ),
        );

        passwordController.updateValue('1234567');

        expect(
          confirmPasswordController.value,
          allOf(
            hasValidationError('Passwords do not match'),
            hasValidationState(ValidationState.invalid),
          ),
        );
      });

      test(
        'dispose controller removes listener on dependent field',
        () {
          confirmPasswordController.addListener(() {});
          expect(passwordController.hasListeners, isTrue);
          confirmPasswordController.dispose();
          expect(passwordController.hasListeners, isFalse);
        },
      );
    },
  );

  group('setAutovalidate with autoValidate == true', () {
    late FieldController<String, _FieldValidationError> field;

    setUp(() {
      field = createField(initialValue: '', autoValidate: false);
      field.addListener(
        () => stateListener(field.value),
      );
    });

    test(
      'and valid/invalid state only set autoValidate',
      () {
        field.setAutovalidate(true);
        expect(
          field.value,
          FieldControllerState<String, _FieldValidationError>(
            initialValue: field.value.initialValue,
            autoValidate: true,
            error: field.value.error,
            validationState: field.value.validationState,
            value: field.value.value,
          ),
        );
      },
    );
    test(
      'and dirty state calling validate once',
      () {
        field.updateValue('123');
        field.setAutovalidate(true);
        verify(() => stateListener.call(any(
              that: allOf(
                hasValidationError(null),
                hasValidationState(ValidationState.valid),
              ),
            ))).called(1);
      },
    );
  });
  group('setAutovalidate with autoValidate == false', () {
    late FieldController<String, _FieldValidationError> field;

    setUp(() {
      field = createField(initialValue: '', autoValidate: true);
      field.addListener(
        () => stateListener(field.value),
      );
    });

    test(
      'in any case only set autoValidate',
      () {
        field.setAutovalidate(false);
        expect(
          field.value,
          FieldControllerState<String, _FieldValidationError>(
            initialValue: field.value.initialValue,
            autoValidate: false,
            error: field.value.error,
            validationState: field.value.validationState,
            value: field.value.value,
          ),
        );
        field.updateValue('123123');
        expect(
          field.value,
          FieldControllerState<String, _FieldValidationError>(
            initialValue: field.value.initialValue,
            autoValidate: false,
            error: field.value.error,
            validationState: field.value.validationState,
            value: field.value.value,
          ),
        );
      },
    );
  });
  group('clear error', () {
    late FieldController<String, _FieldValidationError> field;

    setUp(() {
      field = createField(initialValue: '', autoValidate: true);
      field.addListener(
        () => stateListener(field.value),
      );
    });

    test(
      'sets error as null',
      () {
        field.updateValue('123123');
        field.clearError();
        expect(
          field.value,
          FieldControllerState<String, _FieldValidationError>(
            initialValue: field.value.initialValue,
            autoValidate: field.value.autoValidate,
            error: null,
            validationState: field.value.validationState,
            value: field.value.value,
          ),
        );
      },
    );
  });
}
