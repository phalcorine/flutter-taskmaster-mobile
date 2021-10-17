import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';

final apiTaskListProvider = FutureProvider<TaskListResponseDto>((ref) async {
  final apiTaskService = ref.watch(apiTaskServiceProvider);

  return apiTaskService.getTasks();
});
