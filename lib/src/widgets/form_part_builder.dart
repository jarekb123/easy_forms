import 'package:easy_forms_validation/easy_forms_validation.dart';
import 'package:flutter/widgets.dart';

/// {@template form_part_builder}
/// A [ValueListenableBuilder] listens to a [FormPart]'s [FormPartState].
/// Provided [node] may be a field [FieldController] or a form [FormControllerMixin].
///
/// Use this widget to build a widget that depends on the [FormPart]'s [ValidationState].
/// Example:
///
/// ```dart
/// final formPart = FormPart<FormPartState>();
///
/// class SubmitButton extends StatelessWidget {
///   Widget build(BuildContext context) {
///     return FormPartBuilder(
///       node: formPart,
///       builder: (context, state, child) {
///         final enabled = state.validationState != ValidationState.invalid;
///         return ElevatedButton(
///           onPressed: enabled ? () => _submitAction() : null,
///           child: Text('Submit'),
///         );
///       },
///     );
///   }
/// }
/// ```
/// {@endtemplate}

class FormPartBuilder<T extends FormPartState> extends StatelessWidget {
  /// {@macro form_part_builder}
  const FormPartBuilder({
    super.key,
    required this.node,
    required this.builder,
    this.child,
  });

  /// The [FormPart] to which this [FormPartBuilder] is attached.
  ///
  /// The [FormPart] may be a field [FieldController] or a form [FormControllerMixin].
  final FormPart<T> node;
  final ValueWidgetBuilder<T> builder;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<T>(
      valueListenable: node,
      builder: builder,
      child: child,
    );
  }
}
