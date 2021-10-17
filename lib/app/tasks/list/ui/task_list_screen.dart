import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskmaster_mobile/app/tasks/add/ui/task_add_screen.dart';
import 'package:taskmaster_mobile/app/tasks/list/providers.dart';
import 'package:taskmaster_mobile/app/tasks/models.dart';

class TaskListScreen extends ConsumerWidget {
  const TaskListScreen({Key? key}) : super(key: key);

  static const String routeName = "/tasks";

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskState = ref.watch(apiTaskListProvider);

    // Show notification once the list is refreshed...
    // @TODO: Investigate why this doesn't work!
    // taskState.maybeWhen(
    //     data: (data) {
    //   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
    //   content: Text('Task list refreshed successfully...'),
    // ));
    //     },
    //     orElse: () {});

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(apiTaskListProvider),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () =>
                Navigator.of(context).pushNamed(TaskAddScreen.routeName),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.all(16.0),
          alignment: Alignment.topCenter,
          child: taskState.when(
            loading: (_) => const Center(
              child: CircularProgressIndicator(),
            ),
            error: (ex, st, _) => Center(
              child: Text(
                'Error Message: $ex',
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
            data: (taskList) {
              // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              //   content: Text('Task list refreshed successfully...'),
              // ));
              return TaskList(tasks: taskList.data);
            },
          ),
        ),
      ),
    );
  }
}

class TaskList extends StatelessWidget {
  final List<Task> tasks;
  const TaskList({required this.tasks, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return Center(
        child: Text(
          'You have not added any tasks yet!',
          style: Theme.of(context).textTheme.headline6,
        ),
      );
    }
    return Flexible(
      child: ListView.builder(
        itemBuilder: (builderContext, index) => TaskItem(tasks[index]),
        itemCount: tasks.length,
      ),
    );
  }
}

class TaskItem extends ConsumerWidget {
  final Task task;
  const TaskItem(this.task, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      title: Text(task.title),
      subtitle: Text(task.content),
      trailing: Icon(task.isCompleted
          ? Icons.check_box_outlined
          : Icons.check_box_outline_blank),
    );
  }
}
