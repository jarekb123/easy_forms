import 'package:easy_forms_validation/easy_forms_validation.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_helpers.dart';

enum _FieldValidationError { empty, tooLong }

void main() {
  group('RequiredNullableFieldController (non-autovalidated)', () {
    late _RequiredNullableField field;
    late MockListener<FieldControllerState<String?, _FieldValidationError?>>
        stateListener;

    setUp(() {
      field = _RequiredNullableField();
      stateListener = MockListener();
      field.addListener(() => stateListener(field.value));
    });

    test('requiredValue throws StateError if field is not validated', () {
      expectValidationState(field.value, ValidationState.dirty);
      expect(() => field.requiredValue, throwsStateError);
    });

    test('requiredValue throws StateError if field is invalid', () {
      field.validate();
      expectValidationState(field.value, ValidationState.invalid);
      expectValidationError(field.value, _FieldValidationError.empty);
      expect(() => field.requiredValue, throwsStateError);
    });

    test('requiredValue returns value if field is valid', () {
      field.updateValue('12345');
      field.validate();
      expectValidationState(field.value, ValidationState.valid);
      expectValidationError(field.value, isNull);
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

  static _FieldValidationError? _validate(String value, FieldRef ref) {
    if (value.length > 5) {
      return _FieldValidationError.tooLong;
    } else {
      return null;
    }
  }
}
