import 'package:easy_forms_validation/easy_forms_validation.dart';
import 'package:easy_forms_validation/src/widgets/form_part_builder.dart';
import 'package:flutter/widgets.dart';

class FieldBuilder<Value, ValidationError> extends StatelessWidget {
  /// Creates a widget that builds its child based on the state of a [FieldController].
  const FieldBuilder({
    Key? key,
    required this.field,
    required this.builder,
    this.child,
  }) : super(key: key);

  /// The [FieldController] that this widget will listen to.
  final FieldController<Value, ValidationError> field;

  /// A function that will be called every time the [field]'s state changes.
  /// The function should return a widget based on the current state of the [field].
  final Widget Function(
    BuildContext context,
    FieldControllerState<Value, ValidationError> state,
    Widget? child,
  ) builder;

  /// The widget below this [FieldBuilder] in the tree.
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return FormPartBuilder(
      node: field,
      builder: builder,
      child: child,
    );
  }
}
