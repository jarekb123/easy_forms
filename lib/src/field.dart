// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:easy_forms/easy_forms.dart';

typedef FieldValidator<Value, ValidationError> = ValidationError? Function(
  Value value,
);

/// [FieldController] is a controller for a field in a form.
class FieldController<Value, ValidationError>
    implements FormPart<FieldControllerState<Value, ValidationError>> {
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
  })  : _value = ValueNotifier(
          FieldControllerState<Value, ValidationError>(
            value: initialValue,
            error: autoValidate ? validator(initialValue) : null,
            validationState: autoValidate
                ? validator(initialValue) == null
                    ? ValidationState.valid
                    : ValidationState.invalid
                : ValidationState.dirty,
          ),
        ),
        _validator = validator;

  /// {@macro field_controller_state}
  @override
  FieldControllerState<Value, ValidationError> get value => _value.value;
  final ValueNotifier<FieldControllerState<Value, ValidationError>> _value;

  /// Whether the field is validated on every change of its value.
  final bool autoValidate;

  /// The validator of the field.
  /// It is called when the field is validated.
  ///
  /// It should return null if the field is valid.
  final FieldValidator<Value, ValidationError> _validator;

  /// The debug label of the field.
  /// It is used in [toString]/[toMap] to identify the field.
  final String? debugLabel;

  @override
  void addListener(VoidCallback listener) {
    _value.addListener(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    _value.removeListener(listener);
  }

  /// Updates the value of the field.
  ///
  /// If [autoValidate] is true, the field will be validated immediately.
  void updateValue(Value value) {
    if (autoValidate) {
      final error = _validator(value);
      _value.value = FieldControllerState(
        value: value,
        error: error,
        validationState:
            error == null ? ValidationState.valid : ValidationState.invalid,
      );
    } else {
      _value.value = FieldControllerState(
        value: value,
        error: null,
        validationState: ValidationState.dirty,
      );
    }
  }

  /// Validates the field.
  ///
  /// Returns true if the field is valid, false otherwise.
  @override
  bool validate() {
    final error = _validator(value.value);
    _value.value = FieldControllerState(
      value: value.value,
      error: error,
      validationState:
          error == null ? ValidationState.valid : ValidationState.invalid,
    );
    return error == null;
  }

  /// Overrides the validation state of the field.
  ///
  /// It is useful when the local validation of the field is not enough,
  /// eg. some validation is performed on the server.
  void overrideValidationError(ValidationError error) {
    _value.value = FieldControllerState(
      value: value.value,
      error: error,
      validationState: ValidationState.invalid,
    );
  }

  /// Used to dump the state of the field.
  @override
  Map<String, String> toMap() {
    return {
      'type': '$runtimeType',
      'debugLabel': debugLabel.toString(),
      'hash': identityHashCode(this).toString(),
      'value': value.value.toString(),
      'error': value.error.toString(),
      'validationState': value.validationState.toString(),
    };
  }

  @override
  String toString() {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(toMap());
  }
}

/// {@template field_controller_state}
/// The state of the field.
/// It contains the current value, error and validation state.
/// {@endtemplate}
class FieldControllerState<Value, ValidationError> implements FormPartState {
  /// {@macro field_controller_state}
  const FieldControllerState({
    required this.value,
    required this.error,
    required this.validationState,
  });

  /// The current value of the field.
  final Value value;

  /// The current validation error of the field.
  final ValidationError? error;

  /// The current validation state of the node.
  @override
  final ValidationState validationState;

  @override
  bool operator ==(
    covariant FieldControllerState<Value, ValidationError> other,
  ) {
    if (identical(this, other)) return true;

    return other.value == value &&
        other.error == error &&
        other.validationState == validationState;
  }

  @override
  int get hashCode => Object.hash(value, error, validationState);

  @override
  String toString() {
    return 'FieldControllerState(value: $value, error: $error, validationState: $validationState)';
  }
}
