// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:easy_forms_validation/easy_forms_validation.dart';
import 'package:flutter/foundation.dart';

typedef FieldValidator<Value, ValidationError> = ValidationError? Function(
  Value value,
  FieldRef ref,
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
    FieldValidator<Value, ValidationError>? validator,
    this.debugLabel,
    bool autoValidate = false,
  }) : _validator = validator ?? _defaultValidator {
    _ref = FieldRef(this);

    _value = ValueNotifier(
      FieldControllerState<Value, ValidationError>(
        initialValue: initialValue,
        value: initialValue,
        autoValidate: autoValidate,
        error: autoValidate
            ? (validator ?? _defaultValidator).call(initialValue, _ref)
            : null,
        validationState: autoValidate
            ? (validator ?? _defaultValidator).call(initialValue, _ref) == null
                ? ValidationState.valid
                : ValidationState.invalid
            : ValidationState.dirty,
      ),
    );
  }

  // Creates a validator that always returns null (field's value is always valid)
  static ValidationError? _defaultValidator<Value, ValidationError>(
    Value value,
    FieldRef ref,
  ) =>
      null;

  /// {@macro field_controller_state}
  @override
  FieldControllerState<Value, ValidationError> get value => _value.value;

  late final ValueNotifier<FieldControllerState<Value, ValidationError>> _value;

  /// The value of the field.
  Value get fieldValue => value.value;

  // ignore: invalid_use_of_protected_member
  bool get hasListeners => _value.hasListeners;

  /// The validator of the field.
  /// It is called when the field is validated.
  ///
  /// It should return null if the field is valid.
  final FieldValidator<Value, ValidationError> _validator;

  late final FieldRef _ref;

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

  void dispose() {
    _ref.dispose();
    _value.dispose();
  }

  /// Updates the value of the field.
  ///
  /// If [autoValidate] is true, the field will be validated immediately.
  void updateValue(Value value) {
    final autoValidate = _value.value.autoValidate;

    if (autoValidate) {
      final error = _validator(value, _ref);
      _value.value = FieldControllerState(
        initialValue: _value.value.initialValue,
        value: value,
        error: error,
        validationState:
            error == null ? ValidationState.valid : ValidationState.invalid,
        autoValidate: autoValidate,
      );
    } else {
      _value.value = FieldControllerState(
        initialValue: _value.value.initialValue,
        value: value,
        error: null,
        validationState: ValidationState.dirty,
        autoValidate: autoValidate,
      );
    }
  }

  /// Validates the node.
  ///
  /// Returns true if the node is valid, false otherwise.
  /// Sets [autoValidate] if given
  @override
  bool validate({bool? autoValidate}) {
    final error = _validator(value.value, _ref);
    _value.value = FieldControllerState(
      initialValue: _value.value.initialValue,
      value: value.value,
      error: error,
      validationState:
          error == null ? ValidationState.valid : ValidationState.invalid,
      autoValidate: autoValidate ?? _value.value.autoValidate,
    );
    return error == null;
  }

  /// Overrides the validation state of the field.
  ///
  /// It is useful when the app-side validation of the field is not enough,
  /// eg. some validation is performed on the server.
  void overrideValidationError(ValidationError error) {
    _value.value = FieldControllerState(
      initialValue: _value.value.initialValue,
      value: value.value,
      error: error,
      validationState: ValidationState.invalid,
      autoValidate: _value.value.autoValidate,
    );
  }

  /// Sets autoValidate in the [_value].
  ///
  /// If autoValidate is true and [_value.validationState] is [ValidationState.dirty], validate is called.
  /// Otherwise only autoValidate field is updated.

  void setAutovalidate(bool autoValidate) {
    if (autoValidate && value.validationState == ValidationState.dirty) {
      validate(autoValidate: autoValidate);
    } else {
      _value.value = FieldControllerState(
        autoValidate: autoValidate,
        error: value.error,
        initialValue: value.initialValue,
        validationState: value.validationState,
        value: value.value,
      );
    }
  }

  /// Sets error as null
  void clearError() {
    _value.value = FieldControllerState(
      autoValidate: value.autoValidate,
      error: null,
      initialValue: value.initialValue,
      validationState: value.validationState,
      value: value.value,
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
    required this.initialValue,
    required this.value,
    required this.error,
    required this.validationState,
    required this.autoValidate,
  });

  /// The initial value of the field.
  final Value initialValue;

  /// The current value of the field.
  final Value value;

  /// The current validation error of the field.
  final ValidationError? error;

  /// The current validation state of the node.
  @override
  final ValidationState validationState;

  /// The current auto validation state.
  final bool autoValidate;

  @override
  bool operator ==(
    covariant FieldControllerState<Value, ValidationError> other,
  ) {
    if (identical(this, other)) return true;

    return other.value == value &&
        other.error == error &&
        other.validationState == validationState &&
        other.autoValidate == autoValidate &&
        initialValue == initialValue;
  }

  @override
  int get hashCode =>
      Object.hash(value, error, validationState, autoValidate, initialValue);

  @override
  String toString() {
    return 'FieldControllerState(value: $value, error: $error, validationState: $validationState, autoValidate: $autoValidate, initialValue: $initialValue)';
  }
}

/// It is used to watch the state of another field.
/// It is useful to create fields validators that depend on other fields.
class FieldRef {
  final FieldController _parent;

  final _dependencies = <FieldController>[];

  FieldRef(
    this._parent,
  );

  FieldControllerState<T, ValidationError> watch<T, ValidationError>(
    FieldController<T, ValidationError> field,
  ) {
    _listenToDependency(field);

    return field.value;
  }

  void dispose() {
    for (final field in _dependencies) {
      field.removeListener(_validate);
    }
  }

  void _listenToDependency(FieldController field) {
    if (!_dependencies.contains(field)) {
      _dependencies.add(field);
      field.addListener(_validate);
    }
  }

  void _validate() {
    if (_parent.value.autoValidate) {
      _parent.validate();
    }
  }
}
