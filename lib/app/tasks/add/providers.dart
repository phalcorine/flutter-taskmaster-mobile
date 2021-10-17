import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskmaster_mobile/app/shared/ui/models/forms.dart';
import 'package:taskmaster_mobile/app/tasks/providers.dart';

// Providers
final addTaskFormViewModelProvider =
    StateNotifierProvider<AddTaskFormViewModel, AddTaskFormModel>((ref) {
  final taskService = ref.watch(apiTaskServiceProvider);

  return AddTaskFormViewModel(taskService);
});

// Models

class AddTaskFormModel {
  final FormControlModel title;
  final FormControlModel content;
  final AppFormState formState;
  final String errorMessage;
  final String successMessage;

  AddTaskFormModel({
    required this.title,
    required this.content,
    required this.formState,
    required this.errorMessage,
    required this.successMessage,
  });

  bool get canSubmit => title.isValid && content.isValid;

  AddTaskFormModel copyWith({
    FormControlModel? title,
    FormControlModel? content,
    AppFormState? formState,
    String? errorMessage,
    String? successMessage,
  }) {
    return AddTaskFormModel(
      title: title ?? this.title,
      content: content ?? this.content,
      formState: formState ?? this.formState,
      errorMessage: errorMessage ?? this.errorMessage,
      successMessage: successMessage ?? this.successMessage,
    );
  }

  factory AddTaskFormModel.initial() {
    return AddTaskFormModel(
      title: FormControlModel.initial(),
      content: FormControlModel.initial(),
      formState: AppFormState.initial,
      errorMessage: '',
      successMessage: '',
    );
  }
}

// View Models / Notifier

class AddTaskFormViewModel extends StateNotifier<AddTaskFormModel> {
  final ApiTaskService taskService;

  AddTaskFormViewModel(this.taskService) : super(AddTaskFormModel.initial());

  void validateTitle(String title) {
    String? errorText;
    bool isValid = false;
    if (title.trim().isNotEmpty && title.trim().length >= 3) {
      isValid = true;
    } else {
      errorText = 'Title should be at least three (3) characters...';
    }

    state = state.copyWith(
      title: state.title
          .copyWith(errorText: errorText, value: title, isValid: isValid),
    );
  }

  void validateContent(String content) {
    String? errorText;
    bool isValid = false;
    if (content.trim().isNotEmpty && content.trim().length >= 3) {
      isValid = true;
    } else {
      errorText = 'Content should be at least three (3) characters...';
    }

    state = state.copyWith(
      content: state.content
          .copyWith(errorText: errorText, value: content, isValid: isValid),
    );
  }

  void addTask() async {
    state = state.copyWith(formState: AppFormState.loading);
    try {
      final response = await taskService.addTask(AddTaskRequestDto(
        title: state.title.value,
        content: state.content.value,
      ));

      state = state.copyWith(
        formState: AppFormState.success,
        successMessage: 'Task added successfully...',
      );
    } catch (ex) {
      state = state.copyWith(
        formState: AppFormState.failure,
        errorMessage: ex.toString(),
      );
    }
  }

  void refresh() {
    state = state.copyWith(formState: AppFormState.initial);
  }
}
