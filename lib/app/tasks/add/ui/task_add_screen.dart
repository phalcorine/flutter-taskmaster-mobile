import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskmaster_mobile/app/auth/login/providers.dart';
import 'package:taskmaster_mobile/app/shared/ui/models/forms.dart';
import 'package:taskmaster_mobile/app/tasks/add/providers.dart';
import 'package:taskmaster_mobile/app/tasks/list/providers.dart';

class TaskAddScreen extends ConsumerStatefulWidget {
  const TaskAddScreen({Key? key}) : super(key: key);

  static const String routeName = '/tasks/add';

  @override
  ConsumerState<TaskAddScreen> createState() => _TaskAddScreenState();
}

class _TaskAddScreenState extends ConsumerState<TaskAddScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = ref.watch(addTaskFormViewModelProvider);
    final viewModel = ref.watch(addTaskFormViewModelProvider.notifier);

    ref.listen(addTaskFormViewModelProvider, (AddTaskFormModel state) {
      if (state.formState == AppFormState.success) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(state.successMessage)));
        ref.read(loginFormViewModelProvider.notifier).refresh();
        ref.refresh(apiTaskListProvider);
        Navigator.of(context).pop();
      }

      if (state.formState == AppFormState.failure) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(state.errorMessage)));
        ref.read(addTaskFormViewModelProvider.notifier).refresh();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Task'),
      ),
      body: SingleChildScrollView(
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  errorText: model.title.errorText,
                  labelText: 'Title',
                ),
                keyboardType: TextInputType.emailAddress,
                onChanged: viewModel.validateTitle,
              ),
              const SizedBox(
                height: 10,
              ),
              TextField(
                controller: _contentController,
                minLines: 4,
                maxLines: 8,
                decoration: InputDecoration(
                  errorText: model.content.errorText,
                  labelText: 'Content',
                ),
                keyboardType: TextInputType.visiblePassword,
                onChanged: viewModel.validateContent,
              ),
              const SizedBox(
                height: 15,
              ),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    bool isFormSubmitting = ref.watch(addTaskFormViewModelProvider
        .select((model) => model.formState == AppFormState.loading));
    if (isFormSubmitting) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    final canSubmit = ref
        .watch(addTaskFormViewModelProvider.select((model) => model.canSubmit));

    return ElevatedButton(
      onPressed: canSubmit
          ? ref.read(addTaskFormViewModelProvider.notifier).addTask
          : null,
      child: const Text('Save'),
    );
  }
}
