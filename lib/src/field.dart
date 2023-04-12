import 'dart:convert';

import 'package:easy_forms/easy_forms.dart';
import 'package:flutter/foundation.dart';

typedef FieldValidator<Value, ValidationError> = ValidationError? Function(
  Value value,
);

/// [FieldController] is a controller for a field in a form.
class FieldController<Value, ValidationError> implements ValidationNode {
  /// Creates a [FieldController].
  ///
  /// If [autoValidate] is set to true, the field will be validated on every its value change, so:
  /// * immediately with the initial value
  /// * when [updateValue] is called
  /// * when [validate] is called
  FieldController({
    required Value initialValue,
    required FieldValidator<Value, ValidationError> validator,
    this.debugLabel,
    this.autoValidate = false,
  })  : _value = ValueNotifier(initialValue),
        _validator = validator,
        _error = autoValidate
            ? ValueNotifier(validator(initialValue))
            : ValueNotifier(null),
        _validationState = autoValidate
            ? ValueNotifier(
                validator(initialValue) == null
                    ? ValidationState.valid
                    : ValidationState.invalid,
              )
            : ValueNotifier(ValidationState.dirty);

  /// The current value of the field.
  ValueListenable<Value> get value => _value;
  final ValueNotifier<Value> _value;

  /// Whether the field is validated on every change of its value.
  final bool autoValidate;

  /// The current validation error of the field.
  ValueListenable<ValidationError?> get error => _error;
  final ValueNotifier<ValidationError?> _error;

  /// The validator of the field.
  /// It is called when the field is validated.
  ///
  /// It should return null if the field is valid.
  final FieldValidator<Value, ValidationError> _validator;

  @override
  ValueListenable<ValidationState> get validationState => _validationState;
  final ValueNotifier<ValidationState> _validationState;

  /// The debug label of the field.
  /// It is used in [toString]/[toMap] to identify the field.
  final String? debugLabel;

  /// Updates the value of the field.
  ///
  /// If [autoValidate] is true, the field will be validated immediately.
  void updateValue(Value value) {
    _value.value = value;
    if (autoValidate) {
      validate();
    } else {
      _error.value = null;
      _validationState.value = ValidationState.dirty;
    }
  }

  /// Validates the field.
  ///
  /// Returns true if the field is valid, false otherwise.
  @override
  bool validate() {
    final result = _validator(value.value);
    _error.value = result;
    _validationState.value =
        result == null ? ValidationState.valid : ValidationState.invalid;
    return error.value == null;
  }

  /// Overrides the validation state of the field.
  ///
  /// It is useful when the local validation of the field is not enough,
  /// eg. some validation is performed on the server.
  void overrideValidationError(ValidationError error) {
    _error.value = error;
    _validationState.value = ValidationState.invalid;
  }

  /// Used to dump the state of the field.
  @override
  Map<String, String> toMap() {
    return {
      'type': '$runtimeType',
      'debugLabel': debugLabel.toString(),
      'hash': identityHashCode(this).toString(),
      'value': value.value.toString(),
      'error': error.value.toString(),
      'validationState': validationState.value.toString(),
    };
  }

  @override
  String toString() {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(toMap());
  }
}
