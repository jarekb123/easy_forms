import 'package:flutter/foundation.dart';

/// Validation node represents a part of the form that can be validated.
abstract class ValidationNode {
  /// The current validation state of the node.
  ValueListenable<ValidationState> get validationState;

  /// Validates the node.
  ///
  /// Returns true if the node is valid, false otherwise.
  bool validate();

  /// Used to dump the state of the node.
  Map<String, dynamic> toJson();
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
