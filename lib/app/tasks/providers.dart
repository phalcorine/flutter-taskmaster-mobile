import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart';

import 'package:taskmaster_mobile/app/shared/exception/app_http_exception.dart';
import 'package:taskmaster_mobile/app/shared/persistence/api_token_storage.dart';
import 'package:taskmaster_mobile/app/shared/providers/api_server.dart';
import 'package:taskmaster_mobile/app/shared/providers/http.dart';
import 'package:taskmaster_mobile/app/shared/static/http_status.dart';

import 'models.dart';

final apiTaskServiceProvider = Provider<ApiTaskService>((ref) {
  final baseUrl = ref.watch(apiBaseUrlProvider);
  final httpClient = ref.watch(httpClientProvider);
  final tokenStorageManager = ref.watch(apiTokenStorageProvider);

  return ApiTaskService(
    baseUrl: baseUrl,
    httpClient: httpClient,
    tokenStorageManager: tokenStorageManager,
  );
});

class ApiTaskService {
  final String baseUrl;
  final Client httpClient;
  final TokenStorageController tokenStorageManager;

  ApiTaskService({
    required this.baseUrl,
    required this.tokenStorageManager,
    required this.httpClient,
  });

  Future<TaskListResponseDto> getTasks() async {
    try {
      final url = Uri.parse('$baseUrl/tasks/list');
      final tokenStorage = await tokenStorageManager.getTokenStorage();
      final response = await httpClient.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${tokenStorage.accessToken}"
        },
      );

      print('Task List Response: ');
      print(response.body);
      if (HttpStatus.fromCode(response.statusCode).isOk) {
        return TaskListResponseDto.fromJson(response.body);
      } else {
        throw AppException.fromHttpResponse(response);
      }
    } on AppException {
      rethrow;
    } catch (ex) {
      throw AppException(message: ex.toString());
    }
  }

  Future<AddTaskResponseDto> addTask(AddTaskRequestDto dto) async {
    try {
      final url = Uri.parse('$baseUrl/tasks');
      final tokenStorage = await tokenStorageManager.getTokenStorage();
      final response = await httpClient.post(
        url,
        body: dto.toJson(),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${tokenStorage.accessToken}"
        },
      );

      print('Add Task Response: ');
      print(response.body);
      if (HttpStatus.fromCode(response.statusCode).isOk) {
        return AddTaskResponseDto.fromJson(response.body);
      } else {
        throw AppException.fromHttpResponse(response);
      }
    } on AppException {
      rethrow;
    } catch (ex) {
      throw AppException(message: ex.toString());
    }
  }
}

// DTOs

class TaskListResponseDto {
  final List<Task> data;

  TaskListResponseDto({
    required this.data,
  });

  Map<String, dynamic> toMap() {
    return {
      'data': data.map((x) => x.toMap()).toList(),
    };
  }

  factory TaskListResponseDto.fromMap(Map<String, dynamic> map) {
    return TaskListResponseDto(
      data: List<Task>.from(map['data']?.map((x) => Task.fromMap(x))),
    );
  }

  String toJson() => json.encode(toMap());

  factory TaskListResponseDto.fromJson(String source) =>
      TaskListResponseDto.fromMap(json.decode(source));
}

class AddTaskRequestDto {
  final String title;
  final String content;

  AddTaskRequestDto({
    required this.title,
    required this.content,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
    };
  }

  factory AddTaskRequestDto.fromMap(Map<String, dynamic> map) {
    return AddTaskRequestDto(
      title: map['title'],
      content: map['content'],
    );
  }

  String toJson() => json.encode(toMap());

  factory AddTaskRequestDto.fromJson(String source) =>
      AddTaskRequestDto.fromMap(json.decode(source));
}

class AddTaskResponseDto {
  final Task data;

  AddTaskResponseDto({
    required this.data,
  });

  Map<String, dynamic> toMap() {
    return {
      'data': data.toMap(),
    };
  }

  factory AddTaskResponseDto.fromMap(Map<String, dynamic> map) {
    return AddTaskResponseDto(
      data: Task.fromMap(map['data']),
    );
  }

  String toJson() => json.encode(toMap());

  factory AddTaskResponseDto.fromJson(String source) =>
      AddTaskResponseDto.fromMap(json.decode(source));
}
