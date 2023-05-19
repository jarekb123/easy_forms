import 'package:easy_forms_validation/easy_forms_validation.dart';
import 'package:flutter/material.dart';

class EasyTextField<VE> extends StatelessWidget {
  const EasyTextField({
    super.key,
    required this.field,
    required this.hintText,
    required this.localizeError,
  });

  final String hintText;
  final TextFieldController<VE> field;
  final String Function(BuildContext context, VE validationError) localizeError;

  @override
  Widget build(BuildContext context) {
    return TextFieldBuilder(
      field: field,
      builder: (context, controller, state) {
        final error = state.error;

        return TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            errorText: error == null ? null : localizeError(context, error),
          ),
        );
      },
    );
  }
}
