import 'package:easy_forms/easy_forms.dart';
import 'package:flutter/widgets.dart';

class FieldBuilder<Value, ValidationError> extends StatefulWidget {
  /// Creates a widget that builds its child based on the state of a [FieldController].
  const FieldBuilder({
    Key? key,
    required this.controller,
    required this.builder,
    this.child,
  }) : super(key: key);

  /// The [FieldController] that this widget will listen to.
  final FieldController<Value, ValidationError> controller;

  /// A function that will be called every time the [controller]'s state changes.
  /// The function should return a widget based on the current state of the [controller].
  final Widget Function(
    BuildContext context,
    Value value,
    ValidationError? error,
    ValidationState validationState,
  ) builder;

  /// The widget below this [FieldBuilder] in the tree.
  final Widget? child;

  @override
  State<FieldBuilder<Value, ValidationError>> createState() =>
      _FieldBuilderState<Value, ValidationError>();
}

class _FieldBuilderState<Value, ValidationError>
    extends State<FieldBuilder<Value, ValidationError>> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<FieldControllerState<Value, ValidationError>>(
      valueListenable: widget.controller,
      child: widget.child,
      builder: (context, state, child) {
        return widget.builder(
          context,
          state.value,
          state.error,
          state.validationState,
        );
      },
    );
  }
}
