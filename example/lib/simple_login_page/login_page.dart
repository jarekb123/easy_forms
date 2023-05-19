import 'package:example/fields_ui/submit_button.dart';
import 'package:example/fields_ui/text_field.dart';
import 'package:example/simple_login_page/login_cubit.dart';
import 'package:example/simple_login_page/submit_form_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginCubit(),
      child: const _LoginPageView(),
    );
  }
}

class _LoginPageView extends StatelessWidget {
  const _LoginPageView();

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<LoginCubit>();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            EasyTextField(
              field: cubit.form.username,
              hintText: 'Username',
              localizeError: (context, error) => error,
            ),
            EasyTextField(
              field: cubit.form.password,
              hintText: 'Password',
              localizeError: (context, error) => error,
            ),
            const SizedBox(height: 16),
            if (cubit.state == SubmitStatus.submitting) ...[
              const SizedBox(height: 16),
              const Center(
                child: CircularProgressIndicator(),
              ),
              const SizedBox(height: 16),
            ],
            SubmitButton(
              form: cubit.form,
              onSubmit: () => cubit.submit(),
            ),
          ],
        ),
      ),
    );
  }
}
