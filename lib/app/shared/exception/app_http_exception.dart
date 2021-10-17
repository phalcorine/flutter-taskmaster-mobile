import 'dart:convert';

import 'package:http/http.dart';

class AppException implements Exception {
  final String message;
  AppException({
    required this.message,
  });

  Map<String, dynamic> toMap() {
    return {
      'message': message,
    };
  }

  factory AppException.fromMap(Map<String, dynamic> map) {
    return AppException(
      message: map['message'],
    );
  }

  String toJson() => json.encode(toMap());

  factory AppException.fromJson(String source) =>
      AppException.fromMap(json.decode(source));

  factory AppException.fromHttpResponse(Response response) {
    try {
      return AppException.fromJson(response.body);
    } catch (ex) {
      return AppException(
          message:
              'Some error occurred on the server but the data is malformed...');
    }
  }

  @override
  String toString() {
    return message;
  }
}
