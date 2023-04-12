import 'dart:convert';

import 'package:easy_forms/easy_forms.dart';
import 'package:flutter/foundation.dart';

/// [FormControllerMixin] is a mixin for any class that needs form validation logic.
///
/// It can be used with any state management solution, eg. ChangeNotifier, Riverpod, flutter_bloc, etc.
///
/// {@template formcontrollermixin}
/// It can be used to validate the form and to get the validation state of its fields.
/// {@endtemplate}
///
/// {@macro formcontroller.fields}
mixin FormControllerMixin implements ValidationNode {
  /// The fields of the form.
  ///
  /// {@template formcontroller.fields}
  /// The fields can be grouped in subform with using another [FormController].
  /// This will make the form more modular and reusable.
  ///
  /// Example:
  /// ```
  /// class UserIdentityFormController with FormControllerMixin {
  ///   final email = EmailFieldController();
  ///   final password = PasswordFieldController();
  ///   List<ValidationNode> get fields => [email, password];
  /// }
  /// class RegisterFormController with FormControllerMixin {
  ///   final userIdentity = UserIdentityFormController();
  ///   final firstName = TextFieldController();
  ///   final lastName = TextFieldController();
  ///   List<ValidationNode> get fields => [userIdentity, firstName, lastName];
  /// }
  /// ```
  /// {@endtemplate}
  List<ValidationNode> get fields;

  String? get debugLabel => null;

  /// Validates all fields of the form.
  @override
  bool validate() {
    return fields.every((field) => field.validate());
  }

  bool _listened = false;
  late final _validationState = ValueNotifier(_computeValidationState());

  @override
  ValueListenable<ValidationState> get validationState {
    if (!_listened) {
      _listened = true;
      _listenToFields();
    }
    return _validationState;
  }

  /// Disposes the form.
  void dispose() {
    for (final field in fields) {
      field.validationState.removeListener(_onFieldValidationStateChanged);
    }
  }

  void _listenToFields() {
    for (final field in fields) {
      field.validationState.addListener(_onFieldValidationStateChanged);
    }
  }

  void _onFieldValidationStateChanged() {
    _validationState.value = _computeValidationState();
  }

  ValidationState _computeValidationState() {
    for (final field in fields) {
      final validationState = field.validationState.value;
      if (validationState == ValidationState.dirty) {
        return ValidationState.dirty;
      }
      if (validationState == ValidationState.invalid) {
        return ValidationState.invalid;
      }
    }
    return ValidationState.valid;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': '$runtimeType',
      'debugLabel': debugLabel,
      'hash': identityHashCode(this).toString(),
      'validationState': validationState.value.toString(),
      'fields': fields.map((field) => field.toJson()).toList(),
    };
  }

  @override
  String toString() {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(toJson());
  }
}
