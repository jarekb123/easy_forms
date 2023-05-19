import 'package:easy_forms/easy_forms.dart';
import 'package:flutter/foundation.dart';

/// Mixin that adds submit logic.
///
/// To use this mixin, override [form]
/// and implement [performSubmit], [onSubmitting], [onSubmitted] and [onSubmitError].
/// Optionally, override [concurrentSubmit] to allow concurrent submits.
///
/// It can be easily used with any state management solution, eg. Riverpod, BLoC, etc.
///
/// Example (using Cubit from flutter_bloc package):
/// ```dart
/// enum MyFormState { initial, submitting, success, error }
///
/// class MyFormCubit extends Cubit<MyFormState> with SubmitFormMixin<String> {
///   MyFormCubit() : super(MyFormState.initial);
///
///   @override
///   Future<String> performSubmit() async {
///     // perform submit logic
///   }
///
///   @override
///   void onSubmitting() {
///     emit(MyFormState.submitting);
///   }
///
///   @override
///   void onSubmitSuccess(String result) {
///     emit(MyFormState.success);
///   }
///
///   @override
///   void onSubmitError(Object error, StackTrace stackTrace) {
///     emit(MyFormState.error);
///   }
/// }
/// ```
mixin SubmitFormMixin<Form extends FormControllerMixin, Result> {
  /// Performs actual submit logic, eg. sending data to the server.
  ///
  /// It is called only if form is valid on the app side.
  @protected
  Future<Result> performSubmit();

  /// Called before performing submit.
  ///
  /// Can be used to show loading indicator, disable submit button, etc.
  void onSubmitting();

  /// Called when submit is submitted (eg. data is sent to backend).
  ///
  /// Can be used to hide loading indicator, show success message, etc.
  void onSubmitted(Result result);

  /// Called when submit fails.
  ///
  /// Can be used to hide loading indicator, show error message, etc.
  void onSubmitError(Object error, StackTrace stackTrace);

  /// The form that is being submitted.
  Form get form;

  /// If false, submit will be performed only if form is not already submitting.
  bool get concurrentSubmit => false;

  bool _submitting = false;

  /// Validates form, and if valid perform submit logic using [performSubmit].
  Future<void> submit() async {
    try {
      if (form.validate()) {
        if (!concurrentSubmit && _submitting) {
          return;
        }
        onSubmitting();
        _submitting = true;
        final result = await performSubmit();
        _submitting = false;
        onSubmitted(result);
      }
    } catch (error, stackTrace) {
      onSubmitError(error, stackTrace);
    }
  }
}
