import 'package:easy_forms_validation/easy_forms_validation.dart';
import 'package:flutter/material.dart';

class SubmitButton extends StatelessWidget {
  const SubmitButton({
    super.key,
    required this.form,
    required this.onSubmit,
  });

  final EasyForm form;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return FormPartBuilder(
      node: form,
      builder: (context, state, child) {
        final enabled = state.validationState != ValidationState.invalid;

        return ElevatedButton(
          onPressed: enabled ? onSubmit : null,
          child: const Text('Submit'),
        );
      },
    );
  }
}
