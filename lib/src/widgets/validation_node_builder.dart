import 'package:easy_forms/easy_forms.dart';
import 'package:flutter/widgets.dart';

/// A [ValueListenableBuilder] listens to a [ValidationNode]'s [ValidationNodeState].
/// Provided [validationNode] may be a field [FieldController] or a form [FormControllerMixin].
///
/// Use this widget to build a widget that depends on the [ValidationNode]'s [ValidationState].
class ValidationNodeBuilder extends StatelessWidget {
  const ValidationNodeBuilder({
    super.key,
    required this.validationNode,
    required this.builder,
    this.child,
  });

  /// The [ValidationNode] to which this [ValidationNodeBuilder] is attached.
  ///
  /// The [ValidationNode] may be a field [FieldController] or a form [FormControllerMixin].
  final ValidationNode validationNode;
  final ValueWidgetBuilder<ValidationState> builder;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ValidationNodeState>(
      valueListenable: validationNode,
      child: child,
      builder: (context, nodeState, child) {
        return builder(context, nodeState.validationState, child);
      },
    );
  }
}
