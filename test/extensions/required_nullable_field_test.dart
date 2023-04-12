import 'package:easy_forms/easy_forms.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_helpers.dart';

enum _FieldValidationError { empty, tooLong }

void main() {
  group('RequiredNullableFieldController (non-autovalidated)', () {
    late MockListener<_FieldValidationError?> errorListener;
    late MockListener<ValidationState> validationStateListener;
    late _RequiredNullableField field;
    late MockListener<String?> valueListener;

    setUp(() {
      field = _RequiredNullableField();
      valueListener = MockListener();
      errorListener = MockListener();
      validationStateListener = MockListener();

      field.error.addListener(() => errorListener(field.error.value));
      field.value.addListener(() => valueListener(field.value.value));
      field.validationState.addListener(
        () => validationStateListener(field.validationState.value),
      );
    });

    test('requiredValue throws StateError if field is not validated', () {
      expect(field.validationState.value, ValidationState.dirty);
      expect(() => field.requiredValue, throwsStateError);
    });

    test('requiredValue throws StateError if field is invalid', () {
      field.validate();
      expect(field.validationState.value, ValidationState.invalid);
      expect(field.error.value, _FieldValidationError.empty);
      expect(() => field.requiredValue, throwsStateError);
    });

    test('requiredValue returns value if field is valid', () {
      field.updateValue('12345');
      field.validate();
      expect(field.validationState.value, ValidationState.valid);
      expect(field.error.value, isNull);
      expect(field.requiredValue, '12345');
    });
  });
}

class _RequiredNullableField
    extends RequiredNullableFieldController<String, _FieldValidationError> {
  _RequiredNullableField()
      : super(
          initialValue: null,
          validator: _validate,
          nullValueError: _FieldValidationError.empty,
        );

  static _FieldValidationError? _validate(String value) {
    if (value.length > 5) {
      return _FieldValidationError.tooLong;
    } else {
      return null;
    }
  }
}
