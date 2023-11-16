import 'package:flutter/foundation.dart';

/// [FormPart] represents a part of the form that can be validated.
/// It can be a field, a group of fields, or a whole form.
///
/// Listenable [value] contains the current validation state of the node.
abstract class FormPart<T extends FormPartState> implements ValueListenable<T> {
  /// Validates the node.
  ///
  /// Returns true if the node is valid, false otherwise.
  /// Sets [autoValidate] if given
  bool validate({bool? autoValidate});

  /// Used to dump the state of the node.
  Map<String, dynamic> toMap();
}

abstract class FormPartState {
  ValidationState get validationState;
}

enum ValidationState {
  /// The node has been changed since the last validation.
  /// It needs to be validated.
  dirty,

  /// The node has been validated and is not valid.
  invalid,

  /// The node has been validated and is valid.
  valid,
}
