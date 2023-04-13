import 'package:easy_forms/easy_forms.dart';
import 'package:flutter/widgets.dart';

/// A [ValueListenableBuilder] listens to a [FormPart]'s [FormPartState].
/// Provided [node] may be a field [FieldController] or a form [FormControllerMixin].
///
/// Use this widget to build a widget that depends on the [FormPart]'s [ValidationState].
class FormPartBuilder extends StatelessWidget {
  const FormPartBuilder({
    super.key,
    required this.node,
    required this.builder,
    this.child,
  });

  /// The [FormPart] to which this [FormPartBuilder] is attached.
  ///
  /// The [FormPart] may be a field [FieldController] or a form [FormControllerMixin].
  final FormPart node;
  final ValueWidgetBuilder<ValidationState> builder;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<FormPartState>(
      valueListenable: node,
      child: child,
      builder: (context, nodeState, child) {
        return builder(context, nodeState.validationState, child);
      },
    );
  }
}
