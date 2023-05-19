import 'package:easy_forms/easy_forms.dart';
import 'package:easy_forms/src/widgets/form_part_builder.dart';
import 'package:flutter/widgets.dart';

class TextFieldBuilder<ValidationError> extends StatefulWidget {
  /// Creates a widget that builds its child based on the state of a [TextFieldController].
  const TextFieldBuilder({
    Key? key,
    required this.field,
    required this.builder,
    this.child,
    this.controller,
  }) : super(key: key);

  /// The [TextFieldController] that this widget will listen to.
  final TextFieldController<ValidationError> field;

  /// A function that will be called every time the [field]'s state changes.
  /// The function should return a widget based on the current state of the [field].
  final Widget Function(
    BuildContext context,
    TextEditingController controller,
    FieldControllerState<String, ValidationError> state,
  ) builder;

  /// The widget below this [TextFieldBuilder] in the tree.
  final Widget? child;

  final TextEditingController? controller;

  @override
  State<TextFieldBuilder<ValidationError>> createState() =>
      _TextFieldBuilderState<ValidationError>();
}

class _TextFieldBuilderState<ValidationError>
    extends State<TextFieldBuilder<ValidationError>> {
  TextEditingController? _controller;

  TextEditingController get _effectiveController =>
      widget.controller ?? _controller!;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller == null
        ? widget.controller!
        : TextEditingController(text: widget.field.value.value);
    _effectiveController.addListener(_onFieldStateChanged);
  }

  @override
  void dispose() {
    _effectiveController.removeListener(_onFieldStateChanged);
    _controller?.dispose();
    super.dispose();
  }

  void _onFieldStateChanged() {
    if (_effectiveController.text != widget.field.fieldValue) {
      _effectiveController.text = widget.field.fieldValue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormPartBuilder<FieldControllerState<String, ValidationError>>(
      node: widget.field,
      builder: (context, state, child) =>
          widget.builder(context, _effectiveController, state),
    );
  }
}
