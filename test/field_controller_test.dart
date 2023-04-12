import 'package:easy_forms/easy_forms.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'test_helpers.dart';

enum _FieldValidationError { empty, tooLong }

void main() {
  late MockListener<_FieldValidationError?> errorListener;
  late MockListener<String> valueListener;
  late MockListener<ValidationState> validationStateListener;

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
    errorListener = MockListener<_FieldValidationError?>();
    valueListener = MockListener<String>();
    validationStateListener = MockListener<ValidationState>();
  });

  group('non autovalidated field', () {
    late FieldController<String, _FieldValidationError> field;

    setUp(() {
      field = createField(initialValue: '');
      field.error.addListener(() => errorListener(field.error.value));
      field.value.addListener(() => valueListener(field.value.value));
      field.validationState.addListener(
        () => validationStateListener(field.validationState.value),
      );
    });

    test('is not validated immediately', () {
      expect(field.error.value, isNull);
      expect(field.validationState.value, ValidationState.dirty);
      verifyZeroInteractions(errorListener);
      verifyZeroInteractions(validationStateListener);
    });

    test('is not validated when value is updated', () {
      field.updateValue('123456');

      expect(field.value.value, '123456');
      verify(() => valueListener('123456')).called(1);
      expect(field.error.value, isNull);
      expect(field.validationState.value, ValidationState.dirty);
      verifyZeroInteractions(errorListener);
      verifyZeroInteractions(validationStateListener);
    });

    test('is validated when validate is called', () {
      // validates initial value
      expect(field.validate(), isFalse);
      expect(field.error.value, _FieldValidationError.empty);
      verify(() => errorListener(_FieldValidationError.empty)).called(1);
      expect(field.validationState.value, ValidationState.invalid);
      verify(() => validationStateListener(ValidationState.invalid)).called(1);

      field.updateValue('123456');
      verify(() => errorListener(null)).called(1);
      expect(
        field.error.value,
        isNull,
        reason: 'error is cleared when value is updated',
      );
      expect(field.validationState.value, ValidationState.dirty);
      verify(() => validationStateListener(ValidationState.dirty)).called(1);

      expect(field.validate(), isFalse);
      expect(field.error.value, _FieldValidationError.tooLong);
      verify(() => errorListener(_FieldValidationError.tooLong)).called(1);
      expect(field.validationState.value, ValidationState.invalid);
      verify(() => validationStateListener(ValidationState.invalid)).called(1);

      verifyNoMoreInteractions(errorListener);
      verifyNoMoreInteractions(validationStateListener);
    });

    test('overrideValidationError overrides error', () {
      // validates initial value
      expect(field.validate(), isFalse);
      expect(field.validationState.value, ValidationState.invalid);

      field.overrideValidationError(_FieldValidationError.tooLong);

      expect(field.error.value, _FieldValidationError.tooLong);
      verify(() => errorListener(_FieldValidationError.tooLong)).called(1);
      expect(field.validationState.value, ValidationState.invalid);
      verify(() => validationStateListener(ValidationState.invalid)).called(1);
    });
  });

  group('autovalidated field', () {
    late FieldController<String, _FieldValidationError> field;

    setUp(() {
      field = createField(initialValue: '', autoValidate: true);
      field.error.addListener(() => errorListener(field.error.value));
      field.value.addListener(() => valueListener(field.value.value));
      field.validationState.addListener(
        () => validationStateListener(field.validationState.value),
      );
    });

    test('initial value is validated on create', () {
      expect(field.error.value, _FieldValidationError.empty);
      expect(field.validationState.value, ValidationState.invalid);
    });

    test('is validated on every value change', () {
      field.updateValue('123456');
      expect(field.error.value, _FieldValidationError.tooLong);
      verify(() => errorListener(_FieldValidationError.tooLong)).called(1);
      expect(field.value.value, '123456');
      verify(() => valueListener('123456')).called(1);
      expect(field.validationState.value, ValidationState.invalid);
      // initial state is: invalid, so validation state is not changed
      verifyNever(() => validationStateListener(ValidationState.invalid));

      field.updateValue('12345');
      expect(field.error.value, isNull);
      verify(() => errorListener(null)).called(1);
      expect(field.value.value, '12345');
      verify(() => valueListener('12345')).called(1);
      verify(() => validationStateListener(ValidationState.valid)).called(1);

      field.updateValue('');
      expect(field.error.value, _FieldValidationError.empty);
      verify(() => errorListener(_FieldValidationError.empty)).called(1);
      expect(field.value.value, '');
      verify(() => valueListener('')).called(1);
      verify(() => validationStateListener(ValidationState.invalid)).called(1);

      verifyNoMoreInteractions(errorListener);
      verifyNoMoreInteractions(valueListener);

      verifyNever(() => validationStateListener(ValidationState.dirty));
      verifyNoMoreInteractions(validationStateListener);
    });

    test('overrideValidationError overrides error', () {
      expect(field.validationState.value, ValidationState.invalid);
      expect(field.error.value, _FieldValidationError.empty);

      field.overrideValidationError(_FieldValidationError.tooLong);

      expect(field.error.value, _FieldValidationError.tooLong);
      verify(() => errorListener(_FieldValidationError.tooLong)).called(1);
    });
  });
}
