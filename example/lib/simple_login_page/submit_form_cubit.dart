import 'package:easy_forms_validation/easy_forms_validation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum SubmitStatus { initial, submitting, success, failure }

abstract class SubmitFormCubit<F extends FormControllerMixin, Result>
    extends Cubit<SubmitStatus> with SubmitFormMixin<F, Result> {
  SubmitFormCubit() : super(SubmitStatus.initial);

  @override
  void onSubmitting() {
    emit(SubmitStatus.submitting);
  }

  @override
  void onSubmitError(Object error, StackTrace stackTrace) {
    emit(SubmitStatus.failure);
  }
}
